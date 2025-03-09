#!/bin/bash

# BigQuery プロジェクトIDとデータセットを指定
PROJECT_ID="rd-dapj-dev"
DATASET="raw_daimaruyu_data"

# 実行するテーブル名を引数から取得
TABLE_NAME="$1"

if [ -z "$TABLE_NAME" ]; then
  echo "❌ テーブル名を指定してください！"
  echo "例: ./scripts/run_all.sh PDP_20211007"
  exit 1
fi

# SQL スクリプトディレクトリ
SQL_DIR="sql_code/geofence_sql"

# フォルダの存在を確認
if [ ! -d "$SQL_DIR" ]; then
  echo "❌ 指定されたSQLフォルダが存在しません: $SQL_DIR"
  exit 1
fi

echo "🔄 BigQuery処理を開始: プロジェクト = $PROJECT_ID, データセット = $DATASET, テーブル = $TABLE_NAME"

# SQL ファイルを順番に実行（テーブル名を動的に置換）
for script in "$SQL_DIR"/*.sql; do
  if [ -f "$script" ]; then
    echo "🚀 実行中: $script"
    sed "s/{TABLE_NAME}/$TABLE_NAME/g" "$script" > temp.sql
    bq query --use_legacy_sql=false --project_id="$PROJECT_ID" --dataset_id="$DATASET" < temp.sql
    rm temp.sql
  else
    echo "⚠️ SQLファイルが見つかりません: $script"
  fi
done

echo "✅ すべての処理が完了しました！"
