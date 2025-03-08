#!/bin/bash

# 設定ファイルの読み込み
source config/sql_config.yaml

echo "🔄 BigQuery処理を開始: ${project_id}.${dataset}"

# SQLファイルを順番に実行
for script in sql_scripts/*.sql; do
  echo "🚀 実行中: $script"
  bq query --use_legacy_sql=false --project_id=${project_id} < "$script"
done

echo "✅ すべての処理が完了しました！"
