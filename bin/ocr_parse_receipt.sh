#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG="$ROOT/logs/ocr_parser.log"
PY="$ROOT/tools/ocr_parser/parse_receipt.py"

mkdir -p "$ROOT/logs"
touch "$LOG"

run_one() {
  local d="$1"
  echo "[RUN] $d" | tee -a "$LOG"
  python3 "$PY" "$d" | tee -a "$LOG"
}

if [[ "${1:-}" == "" ]]; then
  # по умолчанию — 10 последних отчётов
  mapfile -t dirs < <(ls -1dt "$ROOT/reports/ocr"/* 2>/dev/null | head -n 10 || true)
  if [[ ${#dirs[@]} -eq 0 ]]; then
    echo "Нет папок в reports/ocr/* — сначала запусти OCR" | tee -a "$LOG"
    exit 0
  fi
  for d in "${dirs[@]}"; do run_one "$d"; done
else
  run_one "$1"
fi
echo "[DONE] ocr_parse_receipt" | tee -a "$LOG"
