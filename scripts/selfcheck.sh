#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENVDIR="$PROJECT_ROOT/.venv"
LOG="$PROJECT_ROOT/logs/selfcheck_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG") 2>&1

echo "[INFO] PROJECT_ROOT: $PROJECT_ROOT"
echo "[INFO] SELF-CHECK started…"

# 1) Бинарники
for cmd in tesseract pdftoppm qpdf python3; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "[ERR] Binary not found: $cmd"; exit 1
  else
    echo "[OK] $cmd: $(command -v "$cmd")"
  fi
done

# 2) Языки tesseract
langs="$(tesseract --list-langs 2>/dev/null | tr -d '\r')"
for need in eng rus pol deu ukr spa; do
  if ! grep -qx "$need" <<<"$langs"; then
    echo "[ERR] tesseract language missing: $need"; exit 1
  else
    echo "[OK] tesseract lang present: $need"
  fi
done

# 3) Python venv
if [[ ! -d "$VENVDIR" ]]; then
  echo "[ERR] VENV not found at $VENVDIR — сначала запусти scripts/install.sh"; exit 1
fi
# shellcheck disable=SC1091
source "$VENVDIR/bin/activate"
python -c 'import sys; print("[OK] Python in venv:", sys.executable, sys.version)'
python -m pip --version

echo "[INFO] SELF-CHECK passed. Log: $LOG"
