#!/bin/bash

# BigQuery プロジェクトIDとデータセットを指定
PROJECT_ID="rd-dapj-dev"
DATASET="raw_daimaruyu_data"
LOCATION="asia-northeast1"

# 加工データ用データセットの作成（最初に実行）
echo "🔄 加工データ用データセットを作成中..."
bq mk --dataset --location=$LOCATION $PROJECT_ID:processed_daimaruyu_data

# クエリ実行時にロケーションを指定
export BIGQUERY_DATASET_LOCATION=$LOCATION

# ✅ 6日分のデータ（処理対象）
TABLE_NAMES=("PDP_20211007" "PDP_20211008" "PDP_20231015" "PDP_20231016" "PDP_20231023" "PDP_20231029")

# ✅ ワーカー判定用の5日分のデータ
WORKER_REF_TABLES=("PDP_20231009" "PDP_20231010" "PDP_20231011" "PDP_20231012" "PDP_20231013")

# GCSとBigQueryの同期待機
echo "🔄 GCSとBigQueryの同期を待機中..."
sleep 60  # 60秒待機

# テーブル更新状態の確認
for TABLE_NAME in "${TABLE_NAMES[@]}"; do
  echo "📊 テーブル確認: $TABLE_NAME"
  bq show $PROJECT_ID:$DATASET.$TABLE_NAME
done

# まずgeofence_sqlを実行
echo "🔄 Geofence SQLの実行を開始..."
for TABLE_NAME in "${TABLE_NAMES[@]}"; do
  echo "🚀 Geofence処理開始: $TABLE_NAME"
  
  for script in sql_code/geofence_sql/*.sql; do
    if [ -f "$script" ]; then
      echo "🔹 実行中: $script (対象テーブル: $TABLE_NAME)"
      sed -e "s/{TABLE_NAME}/$TABLE_NAME/g" "$script" > temp.sql
      bq query --use_legacy_sql=false --project_id="$PROJECT_ID" < temp.sql
      rm temp.sql
    fi
  done
done

# 次にattribute_sqlを実行
echo "🔄 Attribute SQLの実行を開始..."

WORKER_REF_TABLES_JOINED=$(IFS=','; echo "${WORKER_REF_TABLES[*]}")

echo "🚀 ワーカー判定用データセットを作成中..."
sed "s/{WORKER_REF_TABLES}/$WORKER_REF_TABLES_JOINED/g" sql_code/attribute_sql/000_create_worker_reference.sql > temp.sql
bq query --use_legacy_sql=false --project_id="$PROJECT_ID" < temp.sql
rm temp.sql
echo "✅ ワーカー判定データの準備が完了しました！"

for TABLE_NAME in "${TABLE_NAMES[@]}"; do
  echo "🚀 Attribute処理開始: $TABLE_NAME"
  
  for script in sql_code/attribute_sql/*.sql; do
    if [ -f "$script" ] && [[ $script != *"000_create_worker_reference.sql"* ]]; then
      echo "🔹 実行中: $script (対象テーブル: $TABLE_NAME)"
      sed -e "s/{TABLE_NAME}/$TABLE_NAME/g" -e "s/{WORKER_REF_TABLES}/$WORKER_REF_TABLES_JOINED/g" "$script" > temp.sql
      bq query --use_legacy_sql=false --project_id="$PROJECT_ID" < temp.sql
      rm temp.sql
    fi
  done
done

echo "🎉 すべての処理が完了しました！"

# ローデータ用
`rd-dapj-dev.raw_daimaruyu_data.{TABLE_NAME}`

# 加工データ用
`rd-dapj-dev.processed_daimaruyu_data.{TABLE_NAME}`

# 最終的な結果をraw_daimaruyu_dataに反映
for TABLE_NAME in "${TABLE_NAMES[@]}"; do
  echo "🔄 最終結果を反映中: $TABLE_NAME"
  
  bq query --use_legacy_sql=false --project_id="$PROJECT_ID" <<EOF
    CREATE OR REPLACE TABLE \`rd-dapj-dev.raw_daimaruyu_data.${TABLE_NAME}\` AS
    SELECT 
        r.*,  -- 既存のカラム
        a.geofence,
        a.visit_time,
        COALESCE(s.total_stay_duration, 0) AS stay_duration,
        COALESCE(w.visit_style, 'visitor') AS visit_style
    FROM \`rd-dapj-dev.raw_daimaruyu_data.${TABLE_NAME}\` r
    LEFT JOIN \`rd-dapj-dev.processed_daimaruyu_data.${TABLE_NAME}_attributes\` a
        ON r.uuid = a.uuid
    LEFT JOIN \`rd-dapj-dev.processed_daimaruyu_data.${TABLE_NAME}_stay_time\` s
        ON r.uuid = s.uuid
    LEFT JOIN \`rd-dapj-dev.processed_daimaruyu_data.${TABLE_NAME}_workers\` w
        ON r.uuid = w.uuid;
EOF
done
