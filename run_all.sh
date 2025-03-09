#!/bin/bash

# BigQuery プロジェクトIDとデータセットを指定
PROJECT_ID="rd-dapj-dev"
DATASET="raw_daimaruyu_data"

# 実行するSQLファイルが入ったディレクトリ
SQL_DIR="sql_code"

# SQL ディレクトリの存在を確認
if [ ! -d "$SQL_DIR" ]; then
  echo "❌ 指定されたSQLフォルダが存在しません: $SQL_DIR"
  exit 1
fi

echo "🔄 BigQuery処理を開始: プロジェクト = $PROJECT_ID, データセット = $DATASET"

# SQL ファイルを順番に実行
for script in "$SQL_DIR"/*.sql; do
  if [ -f "$script" ]; then
    echo "🚀 実行中: $script"
    bq query --use_legacy_sql=false --project_id="$PROJECT_ID" --dataset_id="$DATASET" < "$script"
  else
    echo "⚠️ SQLファイルが見つかりません: $script"
  fi
done

echo "✅ すべての処理が完了しました！"
