#!/usr/bin/env bash
set -Eeuo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BASE_DIR"

mkdir -p tasks/inbox tasks/done tasks/failed logs

LOG="logs/inbox_watcher.log"
LOCK="$BASE_DIR/.inbox_watcher.lock"

log(){ echo "[$(date +'%F %T')] $*" | tee -a "$LOG" ; }

# одиночный запуск с локом
exec 9>"$LOCK"
if ! flock -n 9; then
  log "[skip] already running"
  exit 0
fi

log "[start] inbox_watcher one-shot"

# берём самый старый *.json (если нет — idle)
file="$(ls -1t tasks/inbox/*.json 2>/dev/null | tail -n1 || true)"
if [[ -z "${file:-}" ]]; then
  log "[idle] no *.json in inbox"
  exit 0
fi
log "[pick] $file"

# читаем поля (jq уже стоит у тебя)
kind="$(jq -r '.kind // empty'    "$file" 2>/dev/null || true)"
count="$(jq -r '.count // empty'   "$file" 2>/dev/null || true)"

if [[ -z "${kind:-}" ]]; then
  log "[err] no 'kind' in $file -> move to failed"
  mv -f -- "$file" "tasks/failed/$(basename "$file")"
  exit 1
fi

case "$kind" in
  report_pack)
    log "[run] bin/report_pack.sh count=${count:-1}"
    if bin/report_pack.sh "${count:-1}" >>"$LOG" 2>&1; then
      log "[ok] report_pack done"
      mv -f -- "$file" "tasks/done/$(basename "$file")"
      exit 0
    else
      rc=$?
      log "[fail] report_pack rc=$rc"
      mv -f -- "$file" "tasks/failed/$(basename "$file")"
      exit $rc
    fi
    ;;
  *)
    log "[err] unsupported kind=$kind -> failed"
    mv -f -- "$file" "tasks/failed/$(basename "$file")"
    exit 2
    ;;
esac
