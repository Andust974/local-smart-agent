# patched for unified logging
#!/usr/bin/env bash
set -u
IFS=$'\n\t'

ROOT="/home/andrei-work/ai-agent/projects/local_smart_agent"
OCR_TAG="ocr-prod"; OCR_LOG="$LOG"; source "$ROOT/bin/ocr_log.sh" 2>/dev/null || true
OCR_DIR="$ROOT/reports/ocr"
BK_DIR="$ROOT/backup/ocr"
LOG="$ROOT/logs/ocr_cleanup.log"

KEEP="${KEEP:-200}"          # сколько последних папок оставить
MAX_AGE_DAYS="${MAX_AGE_DAYS:-0}"  # >0 — дополнительно отдать в кандидаты старше N дней
APPLY=0
PURGE=0

for a in "$@"; do
  case "$a" in
    --apply) APPLY=1 ;;
    --purge) PURGE=1 ;;  # без перемещения в backup — сразу rm -rf (ОСТОРОЖНО)
    --keep=*) KEEP="${a#*=}" ;;
    --max-age=*) MAX_AGE_DAYS="${a#*=}" ;;
    --help|-h)
      echo "usage: ocr_cleanup.sh [--apply] [--purge] [--keep=200] [--max-age=0]"
      echo "  --apply        выполнить действия (по умолчанию DRY-RUN)"
      echo "  --purge        удалять вместо перемещения в backup/ocr (только с --apply)"
      echo "  --keep=NUM     оставить последние NUM папок по времени модификации (default 200)"
      echo "  --max-age=D    дополнительно выбрать папки старше D дней (0=выкл)"
      exit 0;;
  esac
done

log(){ printf "%s %s\n" "[$(date -Iseconds)]" "$*" | tee -a "$LOG"; }

main(){
  mkdir -p "$(dirname "$LOG")" "$BK_DIR"
  log "=== OCR CLEANUP start (KEEP=$KEEP, MAX_AGE_DAYS=$MAX_AGE_DAYS, APPLY=$APPLY, PURGE=$PURGE) ==="
  if [[ ! -d "$OCR_DIR" ]]; then log "[INFO] нет каталога $OCR_DIR"; exit 0; fi

  # берём только директории первого уровня
  mapfile -t all_dirs < <(ls -1dt "$OCR_DIR"/*/ 2>/dev/null | sed 's#/$##')
  total=${#all_dirs[@]}
  [[ $total -eq 0 ]] && { log "[INFO] нет папок для очистки"; exit 0; }

  # оставляем последние KEEP
  mapfile -t keep_dirs < <(printf "%s\n" "${all_dirs[@]}" | head -n "$KEEP")
  # кандидаты — всё остальное
  mapfile -t cand_dirs < <(printf "%s\n" "${all_dirs[@]}" | tail -n +"$((KEEP+1))")

  # если задан MAX_AGE_DAYS>0 — сузим кандидатов теми, что старше
  if (( MAX_AGE_DAYS > 0 )) && ((${#cand_dirs[@]} > 0)); then
    now=$(date +%s)
    aged=()
    for d in "${cand_dirs[@]}"; do
      mt=$(stat -c %Y "$d" 2>/dev/null || echo "$now")
      age_days=$(( (now - mt) / 86400 ))
      (( age_days >= MAX_AGE_DAYS )) && aged+=("$d")
    done
    cand_dirs=("${aged[@]}")
  fi

  log "[INFO] всего: $total, оставляем: ${#keep_dirs[@]}, кандидатов: ${#cand_dirs[@]}"
  if ((${#cand_dirs[@]} == 0)); then
    log "[OK] кандидатов на очистку нет"
    exit 0
  fi

  # вывод кандидатов
  for d in "${cand_dirs[@]}"; do
    log "[CAND] $d"
  done

  if (( APPLY == 0 )); then
    log "[DRY-RUN] завершено без изменений"
    exit 0
  fi

  # применяем
  for d in "${cand_dirs[@]}"; do
    if (( PURGE == 1 )); then
      if rm -rf -- "$d" 2>>"$LOG"; then
        log "[DEL] $d"
      else
        log "[FAIL-DEL] $d"
      fi
    else
      base=$(basename "$d")
      dest="$BK_DIR/$base"
      # уникализируем, если уже есть
      if [[ -e "$dest" ]]; then dest="${dest}_$(date +%s)"; fi
      if mv -f -- "$d" "$dest" 2>>"$LOG"; then
        log "[MV] $d -> $dest"
      else
        log "[FAIL-MV] $d"
      fi
    fi
  done
  log "=== OCR CLEANUP done ==="
}

main "$@"
