#!/bin/bash
git add .
git commit -m "Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main
echo "✅ 自動プッシュ完了！"
