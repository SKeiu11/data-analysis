#!/bin/bash

# BigQuery プロジェクトIDとデータセットを指定
PROJECT_ID="rd-dapj-dev"
DATASET="raw_daimaruyu_data"

# ✅ 6日分のデータ（処理対象）
TABLE_NAMES=("PDP_20211007" "PDP_20211008" "PDP_20231015" "PDP_20231016" "PDP_20231023" "PDP_20231029")

# ✅ ワーカー判定用の5日分のデータ
WORKER_REF_TABLES=("PDP_20231009" "PDP_20231010" "PDP_20231011" "PDP_20231012" "PDP_20231013")

SQL_DIR="sql_code/attribute_sql"

if [ ! -d "$SQL_DIR" ]; then
  echo "❌ 指定されたSQLフォルダが存在しません: $SQL_DIR"
  exit 1
fi

echo "🔄 BigQuery処理を開始: プロジェクト = $PROJECT_ID, データセット = $DATASET"

WORKER_REF_TABLES_JOINED=$(IFS=','; echo "${WORKER_REF_TABLES[*]}")

echo "🚀 ワーカー判定用データセットを作成中..."
sed "s/{WORKER_REF_TABLES}/$WORKER_REF_TABLES_JOINED/g" sql_code/00_create_worker_reference.sql > temp.sql
bq query --use_legacy_sql=false --project_id="$PROJECT_ID" < temp.sql
rm temp.sql
echo "✅ ワーカー判定データの準備が完了しました！"

# ✅ 各6日分のデータを処理
for TABLE_NAME in "${TABLE_NAMES[@]}"; do
  echo "🚀 テーブル処理開始: $TABLE_NAME"
  
  for script in "$SQL_DIR"/*.sql; do
    if [ -f "$script" ]; then
      echo "🔹 実行中: $script (対象テーブル: $TABLE_NAME)"
      sed -e "s/{TABLE_NAME}/$TABLE_NAME/g" -e "s/{WORKER_REF_TABLES}/$WORKER_REF_TABLES_JOINED/g" "$script" > temp.sql
      bq query --use_legacy_sql=false --project_id="$PROJECT_ID" < temp.sql
      rm temp.sql
    else
      echo "⚠️ SQLファイルが見つかりません: $script"
    fi
  done

  echo "✅ テーブル $TABLE_NAME の処理が完了しました！"
done

echo "🎉 すべてのテーブルの処理が完了しました！"
