#!/usr/bin/env bash
set -Eeuo pipefail

# Рабочая директория = корень проекта
cd "$(dirname "$0")/.."

LOG_DIR="logs"
INBOX="tasks/inbox"
DONE="tasks/done"
FAILED="tasks/failed"
RUN_DIR="run"

mkdir -p "$LOG_DIR" "$INBOX" "$DONE" "$FAILED" "$RUN_DIR"
LOG="$LOG_DIR/task_worker.log"

# Один инстанс через flock
exec 9>"$RUN_DIR/task_worker.lock"
if ! flock -n 9; then
  echo "$(date +'%F %T') [worker] already running" | tee -a "$LOG"
  exit 0
fi

trap 'echo "$(date +'%F %T') [worker] stopping" >> "$LOG"' INT TERM
echo "$(date +'%F %T') [worker] start" >> "$LOG"

shopt -s nullglob
while true; do
  for f in "$INBOX"/task_*.json; do
    b="$(basename "$f")"
    w="$RUN_DIR/$b"

    # Берём файл в обработку
    if ! mv -f -- "$f" "$w" 2>/dev/null; then
      continue
    fi
    echo "$(date +'%F %T') [worker] picked $b" >> "$LOG"

    # По умолчанию: поддерживаем kind=report_pack
    if jq -e '.kind=="report_pack"' "$w" >/dev/null 2>&1; then
      if [ -x "bin/report_pack.sh" ]; then
        if bin/report_pack.sh "$w" >>"$LOG" 2>&1; then
          mv -f -- "$w" "$DONE/$b"
          echo "$(date +'%F %T') [worker] done $b (handler)" >> "$LOG"
        else
          mv -f -- "$w" "$FAILED/$b"
          echo "$(date +'%F %T') [worker] failed $b (handler exit)" >> "$LOG"
        fi
      else
        # Если хэндлера нет — просто перекладываем в done
        mv -f -- "$w" "$DONE/$b"
        echo "$(date +'%F %T') [worker] done $b (default)" >> "$LOG"
      fi
    else
      mv -f -- "$w" "$FAILED/$b"
      echo "$(date +'%F %T') [worker] failed $b (unknown kind)" >> "$LOG"
    fi
  done
  sleep 2
done
