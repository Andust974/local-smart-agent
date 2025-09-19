#!/usr/bin/env bash
set -Eeuo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BASE_DIR"

LOG="logs/report_pack.log"
mkdir -p "$(dirname "$LOG")"

# Возьмём один json из inbox (самый новый)
f="$(ls -1t tasks/inbox/*.json 2>/dev/null | head -n1 || true)"

if [ -z "${f:-}" ]; then
  echo "[$(date +'%F %T')] [idle] no *.json in inbox" | tee -a "$LOG"
  exit 0
fi

echo "[$(date +'%F %T')] [pick] $f" | tee -a "$LOG"

# Прочитаем count (если нет jq — просто дефолт 1)
if command -v jq >/dev/null 2>&1; then
  count="$(jq -r '.count // 1' "$f" 2>/dev/null || echo 1)"
else
  count=1
fi

# «Обработка»: создадим маркер-репорт
bn="$(basename "$f" .json)"
out="reports/${bn}.done.txt"
echo "report_pack: count=$count; src=$f" > "$out"

# Переместим json в done/
mv -f -- "$f" "tasks/done/${bn}.json"

echo "[$(date +'%F %T')] [done] -> $out" | tee -a "$LOG"
