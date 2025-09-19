#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/ai-agent/projects/local_smart_agent"
EXTRA="$ROOT/skills/extra"
OUTEX="$ROOT/reports/extra"
OUTOCR="$ROOT/reports/ocr"
mkdir -p "$OUTEX" "$OUTOCR"

# -------- handlers --------
__handler_text_summary() {
  local json="$1" ts inp outp
  ts="$(date +%Y%m%d_%H%M%S)"
  inp="$(echo "$json" | jq -r '.txt')"
  [ -n "${inp:-}" ] && [ -f "$inp" ] || { echo "[text_summary] ERR: no file: $inp" >&2; return 1; }
  outp="$OUTEX/summary_${ts}.txt"
  "$EXTRA/text_summary.py" "$inp" "$outp"
  [ -f "$outp" ] && printf "%s" "$outp"
}

__handler_word_count() {
  local json="$1" ts inp outp
  ts="$(date +%Y%m%d_%H%M%S)"
  inp="$(echo "$json" | jq -r '.txt')"
  [ -n "${inp:-}" ] && [ -f "$inp" ] || { echo "[word_count] ERR: no file: $inp" >&2; return 1; }
  outp="$OUTEX/stats_${ts}.json"
  "$EXTRA/word_count.py" "$inp" "$outp"
  [ -f "$outp" ] && printf "%s" "$outp"
}

__handler_merge_txt() {
  local json="$1" ts outp
  ts="$(date +%Y%m%d_%H%M%S)"
  outp="$OUTEX/merged_${ts}.txt"
  mapfile -t inps < <(echo "$json" | jq -r '.inputs[]?')
  "$EXTRA/merge_txt.py" "$outp" "${inps[@]}"
  [ -f "$outp" ] && printf "%s" "$outp"
}

__handler_ocr_scan() {
  local json="$1" ts inp lang outdir
  ts="$(date +%Y%m%d_%H%M%S)"
  inp="$(echo "$json" | jq -r '.path // .pdf // .img // .input')"
  lang="$(echo "$json" | jq -r '.lang // empty')"
  [ -n "${inp:-}" ] || { echo "[ocr_scan] ERR: no input path" >&2; return 1; }
  [ -f "$inp" ] || { echo "[ocr_scan] ERR: file not found: $inp" >&2; return 1; }
  outdir="$OUTOCR/${ts}"
  if [ -n "${lang:-}" ] && [ "$lang" != "null" ]; then
    "$EXTRA/ocr_scan.py" "$inp" "$outdir" "$lang"
  else
    "$EXTRA/ocr_scan.py" "$inp" "$outdir"
  fi
  [ -f "$outdir/meta.json" ] && printf "%s" "$outdir/meta.json"
}

# -------- ENTRYPOINT --------
# read json from arg file or stdin
if [ "${1:-}" ] && [ -f "${1:-}" ]; then
  json="$(cat "$1")"
else
  json="$(cat)"
fi

# normalize kind/type
if echo "$json" | jq -e '.kind' >/dev/null 2>&1; then
  type="$(echo "$json" | jq -r '.kind')"
else
  type="$(echo "$json" | jq -r '.type')"
fi
[ -n "${type:-}" ] && [ "$type" != "null" ] || { echo "[runner] unsupported (no kind/type)" >&2; exit 2; }

# -------- dispatch --------
case "$type" in
  text_summary) __handler_text_summary "$json" ;;
  word_count)   __handler_word_count   "$json" ;;
  merge_txt)    __handler_merge_txt    "$json" ;;
  ocr_scan)     __handler_ocr_scan     "$json" ;;
  report_pack)
    type __handler_report_pack >/dev/null 2>&1 && __handler_report_pack "$json" || {
      echo "[runner] report_pack handler not present" >&2; exit 3; }
    ;;
  *) echo "[runner] unsupported type: $type" >&2; exit 4 ;;
esac
