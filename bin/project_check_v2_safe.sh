#!/usr/bin/env bash
# НЕ жёсткие флаги: терминал не должен падать
set -u
IFS=$'\n\t'

ROOT="${1:-$(pwd)}"
LOG="$ROOT/logs/project_check.log"

log(){ printf "%s\n" "$*" | tee -a "$LOG"; }

log "=== ПРОВЕРКА ПРОЕКТА v2-safe — $(date) ==="
log "ROOT=$ROOT"
START_TS=$(date +%s)

# Общие исключения для find (без eval, без падений)
EXCL_DIRS="-path ./\.git -o -path ./\.venv -o -path ./node_modules -o -path ./backup -o -path ./dist -o -path ./build -o -path ./\.idea -o -path ./\.vscode -o -path */__pycache__"

# --- Markdown (только projekt_files) ---
log ""
log "--- Markdown (projekt_files/*.md) ---"
if [[ -d "$ROOT/projekt_files" ]]; then
  ( cd "$ROOT/projekt_files" && find . -type f -name "*.md" -printf "%9s  %p\n" 2>/dev/null ) | tee -a "$LOG"
else
  log "[WARN] Нет папки projekt_files — пропускаю Markdown"
fi

# --- Python syntax ---
log ""
log "--- Python syntax ---"
PY_FAIL=0
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  python3 -m py_compile "$f" 2>>"$LOG" || { log "[FAIL] python: $f"; PY_FAIL=$((PY_FAIL+1)); }
done < <( cd "$ROOT" && find . \( $EXCL_DIRS \) -prune -o -type f -name "*.py" -print | sort )
[[ $PY_FAIL -eq 0 ]] && log "[OK] Python — синтаксис чистый"

# --- JSON (jq) ---
log ""
log "--- JSON check (jq) ---"
JSON_FAIL=0
if command -v jq >/dev/null 2>&1; then
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    jq empty "$f" 2>>"$LOG" || { log "[FAIL] json: $f"; JSON_FAIL=$((JSON_FAIL+1)); }
  done < <( cd "$ROOT" && find . \( $EXCL_DIRS \) -prune -o -type f -name "*.json" -print | sort )
  [[ $JSON_FAIL -eq 0 ]] && log "[OK] JSON — все валидны"
else
  log "[WARN] jq не найден — секция JSON пропущена"
fi

# --- Bash syntax ---
log ""
log "--- Bash scripts syntax ---"
SH_FAIL=0
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  bash -n "$f" 2>>"$LOG" || { log "[FAIL] bash: $f"; SH_FAIL=$((SH_FAIL+1)); }
done < <( cd "$ROOT" && find . \( $EXCL_DIRS \) -prune -o -type f -name "*.sh" -print | sort )
[[ $SH_FAIL -eq 0 ]] && log "[OK] Bash — синтаксис чистый"

# --- YAML (optional yq) ---
log ""
log "--- YAML check (optional) ---"
YAML_FAIL=0
if command -v yq >/dev/null 2>&1; then
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    yq -o=json '.' "$f" >/dev/null 2>>"$LOG" || { log "[FAIL] yaml: $f"; YAML_FAIL=$((YAML_FAIL+1)); }
  done < <( cd "$ROOT" && find . \( $EXCL_DIRS \) -prune -o -type f \( -name "*.yml" -o -name "*.yaml" \) -print | sort )
  [[ $YAML_FAIL -eq 0 ]] && log "[OK] YAML — валидны"
else
  log "[WARN] yq не установлен — секция YAML пропущена"
fi

# --- systemd (optional) ---
log ""
log "--- systemd units (optional) ---"
UNIT_FAIL=0
if command -v systemd-analyze >/dev/null 2>&1; then
  USR_UNITS="$HOME/.config/systemd/user"
  if [[ -d "$USR_UNITS" ]]; then
    while IFS= read -r u; do
      [[ -z "$u" ]] && continue
      systemd-analyze verify "$u" 2>>"$LOG" || { log "[FAIL] systemd: $u"; UNIT_FAIL=$((UNIT_FAIL+1)); }
    done < <( find "$USR_UNITS" -maxdepth 1 -type f \( -name "*.service" -o -name "*.timer" -o -name "*.socket" \) | sort )
    [[ $UNIT_FAIL -eq 0 ]] && log "[OK] systemd — проверка пройдена"
  else
    log "[INFO] Нет каталога юзер-юнитов: $USR_UNITS"
  fi
else
  log "[WARN] systemd-analyze не найден — секция systemd пропущена"
fi

# --- Итог ---
END_TS=$(date +%s); DUR=$((END_TS-START_TS))
log ""
log "=== ИТОГ / SUMMARY ==="
log "Python FAILs:   $PY_FAIL"
log "JSON FAILs:     $JSON_FAIL"
log "Bash FAILs:     $SH_FAIL"
log "YAML FAILs:     $YAML_FAIL"
log "systemd FAILs:  $UNIT_FAIL"
log "Время: ${DUR}s"
if (( PY_FAIL + JSON_FAIL + SH_FAIL + YAML_FAIL + UNIT_FAIL == 0 )); then
  log "STATUS: ✅ CLEAN"
else
  log "STATUS: ❌ ERRORS — см. подробности выше"
fi
