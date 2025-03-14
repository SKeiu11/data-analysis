#!/bin/bash

# Homebrewのパスを設定
eval "$(/opt/homebrew/bin/brew shellenv)"

# Google Cloud SDKのパスを設定
export PATH="/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin:$PATH"

# Google Cloud SDKのパスを設定
source "$(brew --prefix)/share/google-cloud-sdk/path.bash.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.bash.inc"

# BigQuery プロジェクトIDとデータセットを指定
PROJECT_ID="rd-dapj-dev"
RAW_DATASET="raw_daimaruyu_data"
CLEAN_DATASET="clean_daimaruyu_data"
PROCESSED_DATASET="processed_daimaruyu_data"
LOCATION="asia-northeast1"

# データセットの作成
echo "🔄 データセット作成中..."
bq mk --dataset --location=$LOCATION $PROJECT_ID:$CLEAN_DATASET 2>/dev/null || true
bq mk --dataset --location=$LOCATION $PROJECT_ID:$PROCESSED_DATASET 2>/dev/null || true

# クエリ実行時にロケーションを指定
export BIGQUERY_DATASET_LOCATION=$LOCATION

# テーブル定義
TABLE_NAMES=("PDP_20211007" "PDP_20211008" "PDP_20231015" "PDP_20231016" "PDP_20231023" "PDP_20231029")
WORKER_REFERENCE_DATES=("PDP_20231009" "PDP_20231010" "PDP_20231011" "PDP_20231012" "PDP_20231013")

# 0. ジオフェンス領域テーブルの作成
echo "🔄 ジオフェンス領域テーブルを作成中..."
bq query --use_legacy_sql=false --project_id="$PROJECT_ID" <<EOF
CREATE OR REPLACE TABLE \`$PROJECT_ID.$PROCESSED_DATASET.geofence_regions\`
(
    region GEOGRAPHY,
    zone_name STRING
)
OPTIONS(
    description="ジオフェンスの領域定義"
);

INSERT INTO \`$PROJECT_ID.$PROCESSED_DATASET.geofence_regions\`
SELECT 
    region,
    zone_name
FROM \`$PROJECT_ID.$RAW_DATASET.dmy_buil_geojson_csv\`;
EOF

# 1. クリーンデータの作成
for TABLE_NAME in "${TABLE_NAMES[@]}"; do
    echo "🔄 クリーンデータ作成: $TABLE_NAME"
    bq query --use_legacy_sql=false --project_id="$PROJECT_ID" <<EOF
    CREATE OR REPLACE TABLE \`$PROJECT_ID.$CLEAN_DATASET.$TABLE_NAME\` AS
    SELECT 
        *,
        CAST(NULL AS STRING) AS most_visited_building,
        CAST(NULL AS FLOAT64) AS longest_stay_duration,
        CAST(NULL AS FLOAT64) AS distance_from_tokyo,
        CAST(NULL AS STRING) AS visit_style
    FROM \`$PROJECT_ID.$RAW_DATASET.$TABLE_NAME\`;
EOF
done

# 2. ワーカー判定用のリファレンスデータを作成
echo "🚀 ワーカー判定用データセットを作成中..."
WORKER_REF_TABLES_STR="'$(IFS=','; echo "${WORKER_REFERENCE_DATES[*]}" | sed "s/ /','/g")'"

# ワーカー関連のテーブルを順番に作成
for script in sql_code/attribute_sql/00{0,1,2}_*.sql; do
    echo "🔹 Worker Analysis実行中: $script"
    sed -e "s/{PROJECT_ID}/$PROJECT_ID/g" \
        -e "s/{PROCESSED_DATASET}/$PROCESSED_DATASET/g" \
        -e "s/{CLEAN_DATASET}/$CLEAN_DATASET/g" \
        -e "s/{WORKER_REF_TABLES}/$WORKER_REF_TABLES_STR/g" \
        "$script" > temp.sql
    bq query --use_legacy_sql=false --project_id="$PROJECT_ID" < temp.sql
    rm temp.sql
    sleep 2
done

# 3. home_location_mappingテーブルの作成
echo "🔄 home_location_mappingテーブル作成中..."
bq query --use_legacy_sql=false --project_id="$PROJECT_ID" <<EOF
CREATE OR REPLACE TABLE \`$PROJECT_ID.$PROCESSED_DATASET.home_location_mapping\` AS
SELECT 
    uuid,
    ST_GEOGPOINT(
        AVG(IF(EXTRACT(HOUR FROM TIMESTAMP(CAST(year AS STRING) || '-' || 
                                         LPAD(CAST(month AS STRING), 2, '0') || '-' || 
                                         LPAD(CAST(day AS STRING), 2, '0') || ' ' ||
                                         LPAD(CAST(hour AS STRING), 2, '0') || ':' ||
                                         LPAD(CAST(minute AS STRING), 2, '0') || ':00')) BETWEEN 1 AND 4, longitude, NULL)),
        AVG(IF(EXTRACT(HOUR FROM TIMESTAMP(CAST(year AS STRING) || '-' || 
                                         LPAD(CAST(month AS STRING), 2, '0') || '-' || 
                                         LPAD(CAST(day AS STRING), 2, '0') || ' ' ||
                                         LPAD(CAST(hour AS STRING), 2, '0') || ':' ||
                                         LPAD(CAST(minute AS STRING), 2, '0') || ':00')) BETWEEN 1 AND 4, latitude, NULL))
    ) as home_location
FROM \`$PROJECT_ID.$RAW_DATASET.*\`
GROUP BY uuid
HAVING home_location IS NOT NULL;
EOF

# 4. 各テーブルの処理
for TABLE_NAME in "${TABLE_NAMES[@]}"; do
    echo "🔄 処理開始: $TABLE_NAME"
    
    # Geofence SQLの実行
    for script in sql_code/geofence_sql/0*.sql; do
        if [[ $script != *"001_create_geofence_table.sql"* ]]; then
            echo "🔹 Geofence実行中: $script"
            sed -e "s/{PROJECT_ID}/$PROJECT_ID/g" \
                -e "s/{PROCESSED_DATASET}/$PROCESSED_DATASET/g" \
                -e "s/{CLEAN_DATASET}/$CLEAN_DATASET/g" \
                -e "s/{TABLE_NAME}/$TABLE_NAME/g" \
                "$script" > temp.sql
            bq query --use_legacy_sql=false --project_id="$PROJECT_ID" < temp.sql
            rm temp.sql
            sleep 2
        fi
    done
    
    # 残りのAttribute SQLの実行
    for script in sql_code/attribute_sql/00[3,4]_*.sql; do
        echo "🔹 Attribute実行中: $script"
        sed -e "s/{PROJECT_ID}/$PROJECT_ID/g" \
            -e "s/{PROCESSED_DATASET}/$PROCESSED_DATASET/g" \
            -e "s/{CLEAN_DATASET}/$CLEAN_DATASET/g" \
            -e "s/{TABLE_NAME}/$TABLE_NAME/g" \
            "$script" > temp.sql
        bq query --use_legacy_sql=false --project_id="$PROJECT_ID" < temp.sql
        rm temp.sql
        sleep 2
    done
done

echo "🎉 すべての処理が完了しました！"
