#!/bin/bash

# プロジェクトを指定
PROJECT_NAME="\$1"

if [ -z "\$PROJECT_NAME" ]; then
  echo "❌ プロジェクト名を指定してください！"
  echo "例: ./scripts/run_all.sh project1"
  exit 1
fi

SQL_DIR="sql_code/\$PROJECT_NAME"

if [ ! -d "\$SQL_DIR" ]; then
  echo "❌ 指定されたプロジェクトのフォルダが存在しません: \$SQL_DIR"
  exit 1
fi

echo "🔄 BigQuery処理を開始: プロジェクト = \$PROJECT_NAME"

for script in "\$SQL_DIR"/*.sql; do
  echo "🚀 実行中: \$script"
  bq query --use_legacy_sql=false < "\$script"
done

echo "✅ すべての処理が完了しました！"
