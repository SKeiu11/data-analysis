#!/bin/bash

echo "🔄 環境セットアップ開始..."

# ディレクトリ構成の定義
DIRECTORIES=(
    "sql_code"
    "scripts"
    "config"
    "data/raw"
    "data/processed"
    "data/results"
    "notebooks"
)

# 各ディレクトリを作成
for dir in "${DIRECTORIES[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo "✅ ディレクトリ作成: $dir"
    else
        echo "⚠️ 既に存在: $dir"
    fi
done

# 必要なファイルを作成
touch README.md .gitignore config/settings.yaml config/bigquery_config.json config/data_sources.yaml

# `.gitignore` をセットアップ
cat <<EOL > .gitignore
# Python関連（仮想環境やキャッシュ）
__pycache__/
*.pyc
*.pyo
venv/
.env

# データ関連（CSV, JSON, GeoJSON など）
data/
*.csv
*.json
*.parquet
*.geojson

# BigQuery の一時ファイル
*.bq
*.temp

# ログファイル & IDE 設定
*.log
.DS_Store
.vscode/
.idea/

# シェルスクリプトの一時ファイル
*.sh~
EOL

echo "✅ `.gitignore` を作成"

# `run_all.sh` を作成
#cat <<EOL > scripts/run_all.sh
#!/bin/bash

#echo "🔄 BigQuery処理を開始"

#for script in sql_code/*.sql; do
#  echo "🚀 実行中: \$script"
#  bq query --use_legacy_sql=false < "\$script"
#done

#echo "✅ すべての処理が完了しました！"
#EOL

#chmod +x scripts/run_all.sh
#echo "✅ `run_all.sh` を作成 & 実行権限を付与"

echo "🎉 環境セットアップ完了！"
