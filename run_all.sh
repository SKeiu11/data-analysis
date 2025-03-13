#!/bin/bash

# BigQuery プロジェクトIDとデータセットを指定
PROJECT_ID="rd-dapj-dev"
RAW_DATASET="raw_daimaruyu_data"
CLEAN_DATASET="clean_daimaruyu_data"
PROCESSED_DATASET="processed_daimaruyu_data"
LOCATION="asia-northeast1"

# データセットの作成
echo "🔄 データセット作成中..."
bq mk --dataset --location=$LOCATION $PROJECT_ID:$CLEAN_DATASET
bq mk --dataset --location=$LOCATION $PROJECT_ID:$PROCESSED_DATASET

# クエリ実行時にロケーションを指定
export BIGQUERY_DATASET_LOCATION=$LOCATION

# テーブル定義
TABLE_NAMES=("PDP_20211007" "PDP_20211008" "PDP_20231015" "PDP_20231016" "PDP_20231023" "PDP_20231029")
WORKER_REFERENCE_DATES=("PDP_20231009" "PDP_20231010" "PDP_20231011" "PDP_20231012" "PDP_20231013")

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

# 2. 以降の処理（geofence_sql, attribute_sql）

# 加工データ用データセットの作成（最初に実行）
echo "🔄 加工データ用データセットを作成中..."
bq mk --dataset --location=$LOCATION $PROJECT_ID:$PROCESSED_DATASET

# テーブル定義
TABLE_NAMES=("PDP_20211007" "PDP_20211008" "PDP_20231015" "PDP_20231016" "PDP_20231023" "PDP_20231029")
WORKER_REF_TABLES=("PDP_20231009" "PDP_20231010" "PDP_20231011" "PDP_20231012" "PDP_20231013")

# 1. ワーカー判定用のリファレンスデータを作成
echo "🚀 ワーカー判定用データセットを作成中..."
WORKER_REF_TABLES_JOINED=$(IFS=','; echo "${WORKER_REF_TABLES[*]}")
sed "s/{WORKER_REF_TABLES}/$WORKER_REF_TABLES_JOINED/g" sql_code/attribute_sql/000_create_worker_reference.sql > temp.sql
bq query --use_legacy_sql=false --project_id="$PROJECT_ID" < temp.sql
rm temp.sql

# 2. 各テーブルの処理
for TABLE_NAME in "${TABLE_NAMES[@]}"; do
    echo "🔄 処理開始: $TABLE_NAME"
    
    # Geofence SQLの実行（順序通りに）
    for script in sql_code/geofence_sql/0*.sql; do
        echo "🔹 Geofence実行中: $script"
        sed "s/{TABLE_NAME}/$TABLE_NAME/g" "$script" > temp.sql
        bq query --use_legacy_sql=false --project_id="$PROJECT_ID" < temp.sql
        rm temp.sql
        sleep 2  # テーブル作成の完了を待機
    done
    
    # Attribute SQLの実行（順序通りに）
    for script in sql_code/attribute_sql/0*.sql; do
        if [[ $script != *"000_create_worker_reference.sql"* ]]; then
            echo "🔹 Attribute実行中: $script"
            sed "s/{TABLE_NAME}/$TABLE_NAME/g" "$script" > temp.sql
            bq query --use_legacy_sql=false --project_id="$PROJECT_ID" < temp.sql
            rm temp.sql
            sleep 2  # テーブル作成の完了を待機
        fi
    done
    
    # 最終結果の反映
    echo "🔄 最終結果を反映中: $TABLE_NAME"
    bq query --use_legacy_sql=false --project_id="$PROJECT_ID" <<EOF
        CREATE OR REPLACE TABLE \`$PROJECT_ID.$CLEAN_DATASET.$TABLE_NAME\` AS
        SELECT 
            r.*,
            a.geofence AS most_visited_building,
            s.total_stay_duration AS longest_stay_duration,
            d.distance_from_tokyo,
            COALESCE(w.visit_style, 'visitor') AS visit_style
        FROM \`$PROJECT_ID.$CLEAN_DATASET.$TABLE_NAME\` r
        LEFT JOIN \`$PROJECT_ID.$PROCESSED_DATASET.${TABLE_NAME}_attributes\` a
            ON r.uuid = a.uuid
        LEFT JOIN \`$PROJECT_ID.$PROCESSED_DATASET.${TABLE_NAME}_stay_time\` s
            ON r.uuid = s.uuid
        LEFT JOIN \`$PROJECT_ID.$PROCESSED_DATASET.${TABLE_NAME}_workers\` w
            ON r.uuid = w.uuid
        LEFT JOIN \`$PROJECT_ID.$PROCESSED_DATASET.${TABLE_NAME}_distance\` d
            ON r.uuid = d.uuid;
EOF
    
    sleep 2  # 最終テーブル作成の完了を待機
done

echo "🎉 すべての処理が完了しました！"
