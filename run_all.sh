#!/bin/bash

# BigQuery プロジェクトIDとデータセットを指定
PROJECT_ID="rd-dapj-dev"
DATASET="raw_daimaruyu_data"

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
