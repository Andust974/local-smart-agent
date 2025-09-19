#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/ai-agent/projects/local_smart_agent"
err=0

say(){ printf "%s\n" "$*"; }
ok(){  printf "✅ %s\n" "$*"; }
bad(){ printf "⛔ %s\n" "$*"; err=1; }
warn(){ printf "⚠️  %s\n" "$*"; }

say "== OCR Doctor =="
# 1) Бинари
for b in tesseract pdftoppm pdftocairo pdftotext; do
  if command -v "$b" >/dev/null 2>&1; then ok "$b found: $(command -v $b)"; else bad "$b: NOT FOUND"; fi
done

# 2) Языки
if command -v tesseract >/dev/null 2>&1; then
  langs="$(tesseract --list-langs 2>/dev/null | sed '1d' | tr '\n' ' ')"
  say "langs installed: $langs"
  need=(eng rus pol)
  miss=()
  for l in "${need[@]}"; do
    if ! tesseract --list-langs 2>/dev/null | grep -qx "$l"; then miss+=("$l"); fi
  done
  if [ ${#miss[@]} -gt 0 ]; then
    bad "Missing languages: ${miss[*]}"
    say "→ install with: sudo apt-get install -y $(printf 'tesseract-ocr-%s ' "${miss[@]}")"
  else
    ok "Languages ok: eng+rus+pol"
  fi
fi

# 3) Права на отчёты
for d in "$ROOT/reports" "$ROOT/reports/ocr"; do
  [ -d "$d" ] || mkdir -p "$d"
  if touch "$d/.w" 2>/dev/null; then ok "writeable: $d"; rm -f "$d/.w"; else bad "not writeable: $d"; fi
done

# 4) Тестовый прогон (быстрый)
PDF="$ROOT/sandbox/ocr_test.pdf"
if [ -f "$PDF" ]; then
  say "-- quick run on sandbox/ocr_test.pdf --"
  printf '%s\n' '{ "type":"ocr_scan", "path":"sandbox/ocr_test.pdf", "lang":"eng+rus+pol" }' > "$ROOT/sandbox/_ocr_doctor.json"
  if out="$(bash "$ROOT/core/task_runner.sh" "$ROOT/sandbox/_ocr_doctor.json" 2>&1)"; then
    ok "runner ok"
  else
    bad "runner failed"; printf "%s\n" "$out"
  fi
  latest="$(ls -1dt "$ROOT"/reports/ocr/*/ 2>/dev/null | head -n1 || true)"
  if [ -n "$latest" ]; then
    say "latest: ${latest#$ROOT/}"
    head -n 5 "$latest/meta.json" || true
  else
    bad "no OCR report produced"
  fi
else
  warn "no sandbox/ocr_test.pdf — пропускаю быстрый прогон"
fi

# 5) Рекомендации по прод-настройкам
say "== Recommendations =="
say "- Ensure systemd: task-api.service active (uvicorn from .venv)"
say "- Dashboard /ui/ reachable; OCR Latest shows status 'ok'"
say "- For PDF raster errors, have both pdftoppm and pdftocairo"

exit "$err"
