#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

BASE="${HOME}/ai-agent/projects/local_smart_agent"
INBOX="${BASE}/tasks/inbox"
DONE="${BASE}/tasks/done"
FAILED="${BASE}/tasks/failed"
DLQ="${BASE}/tasks/deadletter"
LOG="${BASE}/logs/inbox_watcher.log"

mkdir -p "${INBOX}" "${DONE}" "${FAILED}" "${DLQ}" "$(dirname "${LOG}")"

log(){ printf '%s %s\n' "$(date +'%F %T')" "$*" | tee -a "${LOG}"; }

# Конфиг: максимум попыток (по умолчанию 3)
MAX_RETRIES="${LSA_MAX_RETRIES:-3}"

normalize_json(){
  if command -v jq >/dev/null 2>&1; then
    jq -c '
      .version = (.version // 1)
      | .kind = (.kind // .task // "")
      | .params = (.params // {})
      | .params.count = (.params.count // .count // 1)
    ' "$1"
  else
    cat "$1"
  fi
}

run_with_retries(){
  local cmd="$1" taskfile="$2" try=1 rc=0 backoff=1
  while :; do
    eval "$cmd" && return 0
    rc=$?
    if [ "$try" -ge "${MAX_RETRIES}" ]; then
      return "$rc"
    fi
    log "[watcher] retry ${try}/${MAX_RETRIES} after ${backoff}s ← $(basename "$taskfile")"
    sleep "$backoff"
    backoff=$(( backoff * 2 ))
    try=$(( try + 1 ))
  done
}

process_file(){
  local f="$1" norm kind count
  norm="$(normalize_json "$f" 2>>"${LOG}")" || { log "[watcher] bad json → $(basename "$f")"; mv -f "$f" "${FAILED}/"; return 1; }
  kind="$(printf '%s' "$norm" | jq -r '.kind // ""' 2>>"${LOG}" || echo "")"
  count="$(printf '%s' "$norm" | jq -r '.params.count // 1' 2>>"${LOG}" || echo 1)"

  [ -z "$kind" ] && { log "[watcher] unsupported (no kind) → $(basename "$f")"; mv -f "$f" "${FAILED}/"; return 1; }

  case "$kind" in
    report_pack)
      log "[watcher] report_pack (count=${count}) ← $(basename "$f")"
      if run_with_retries "${BASE}/bin/report_pack.sh" "$f"; then
        mv -f "$f" "${DONE}/"
        log "[watcher] done → $(basename "$f")"
      else
        mv -f "$f" "${DLQ}/"
        log "[watcher] DLQ report_pack → $(basename "$f")"
        return 1
      fi
      ;;
    *)
      log "[watcher] unsupported kind='${kind}' → $(basename "$f")"
      mv -f "$f" "${FAILED}/"; return 1
      ;;
  esac
}

log "[watcher] start pid=$$ max_retries=${MAX_RETRIES}"
while true; do
  shopt -s nullglob
  for f in "${INBOX}"/*.json; do
    lock="${f}.lock"
    if ( set -o noclobber; : > "$lock" ) 2>/dev/null; then
      trap 'rm -f "$lock"' RETURN
      process_file "$f" || true
      rm -f "$lock"; trap - RETURN
    fi
  done
  sleep 1
done
