#!/usr/bin/env bash
# Собирает краткую сводку по логам нормализации/парсинга/очистки.
set -u
IFS=$'\n\t'
ROOT="/home/andrei-work/ai-agent/projects/local_smart_agent"
OUT="$ROOT/logs/ocr_summary.log"
: > "$OUT"

summ(){
  local name="$1" file="$2"
  if [[ -f "$file" ]]; then
    local ok fail
    ok=$(grep -c "\[OK\]" "$file" || echo 0)
    fail=$(grep -c "\[FAIL\]" "$file" || echo 0)
    printf "%-12s OK=%-4s FAIL=%-4s  (%s)\n" "$name" "$ok" "$fail" "$(basename "$file")" >> "$OUT"
  else
    printf "%-12s %s\n" "$name" "no log" >> "$OUT"
  fi
}

echo "=== OCR SUMMARY — $(date -Iseconds) ===" >> "$OUT"
summ "normalize" "$ROOT/logs/ocr_norm.log"
summ "parse"     "$ROOT/logs/ocr_parse.log"
summ "cleanup"   "$ROOT/logs/ocr_cleanup.log"
echo "Saved: $OUT"
cat "$OUT"
