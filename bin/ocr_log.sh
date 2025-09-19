#!/usr/bin/env bash
# Общий логгер для OCR-пайплайна. Подключать: source "$ROOT/bin/ocr_log.sh"
# Безопасен для set -u (nounset).

# Мягкие дефолты без обращения к несуществующим переменным
OCR_TAG="${OCR_TAG:-ocr-prod}"
# если OCR_LOG не задан, оставляем пустым (значит, писать только в stdout/journal)
OCR_LOG="${OCR_LOG-}"

_log_emit() {
  local lvl="$1"; shift
  local msg="$*"
  local ts; ts="$(date -Iseconds)"
  local line="[$ts] [$lvl] $msg"
  # в файл, только если OCR_LOG задан и не пуст
  if [ -n "${OCR_LOG:-}" ]; then
    printf "%s\n" "$line" >> "$OCR_LOG"
  fi
  # stdout
  printf "%s\n" "$line"
  # journal (если доступен systemd-cat)
  if command -v systemd-cat >/dev/null 2>&1; then
    printf "%s\n" "$line" | systemd-cat -t "$OCR_TAG"
  fi
}
log_info(){ _log_emit INFO "$@"; }
log_ok()  { _log_emit OK   "$@"; }
log_fail(){ _log_emit FAIL "$@"; }
