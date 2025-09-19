#!/usr/bin/env bash
set -Eeuo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BASE_DIR"
LOG="logs/inbox_watcher.log"
LOCK="$BASE_DIR/.inbox_watcher.lock"

mkdir -p logs tasks/inbox tasks/done tasks/failed

# одиночный запуск
exec 9>"$LOCK"
if ! flock -n 9; then
  echo "[$(date +'%F %T')] [skip] already running" | tee -a "$LOG"
  exit 0
fi

echo "[$(date +'%F %T')] [start] inbox_watcher one-shot" | tee -a "$LOG"

shopt -s nullglob
for f in tasks/inbox/*.json; do
  bn="$(basename "$f")"
  echo "[$(date +'%F %T')] [pick] $f" | tee -a "$LOG"
  # здесь твой реальный обработчик; пока просто перекладываем в done и пишем отчёт
  cp -f -- "$f" "tasks/done/$bn"
  echo "done: $bn" > "reports/${bn%.json}.done.txt"
  rm -f -- "$f"
  echo "[$(date +'%F %T')] [done] -> reports/${bn%.json}.done.txt" | tee -a "$LOG"
done

if compgen -G "tasks/inbox/*.json" > /dev/null; then
  : # уже обработали
else
  echo "[$(date +'%F %T')] [idle] no *.json in inbox" | tee -a "$LOG"
fi
