#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# --- Path-safe context ---
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

mkdir -p "$PROJECT_ROOT/logs"
LOG="$PROJECT_ROOT/logs/install_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG") 2>&1

echo "[INFO] PROJECT_ROOT: $PROJECT_ROOT"
echo "[INFO] Installing Local Smart Agent dependencies..."

export DEBIAN_FRONTEND=noninteractive

# Обновление пакетов
sudo apt-get -yq update

# Базовые и дополнительные системные зависимости
# - poppler-utils/qpdf: надёжный PDF→images пайплайн для OCR
# - build-essential/python3-dev/libffi-dev/libssl-dev/pkg-config: сборка колёс (на будущее)
# - jq: удобен для CLI-инструментов агента
sudo apt-get -yq install \
  python3 python3-venv python3-pip \
  tesseract-ocr tesseract-ocr-eng tesseract-ocr-rus tesseract-ocr-pol \
  poppler-utils qpdf \
  build-essential python3-dev libffi-dev libssl-dev pkg-config \
  git curl jq

# Виртуальное окружение — строго в корне проекта
VENVDIR="$PROJECT_ROOT/.venv"
if [[ ! -d "$VENVDIR" ]]; then
  python3 -m venv "$VENVDIR"
fi
# shellcheck disable=SC1091
source "$VENVDIR/bin/activate"

python -m pip install --upgrade pip

REQ="$PROJECT_ROOT/requirements_rag.txt"
if [[ -f "$REQ" ]]; then
  echo "[INFO] Installing Python deps from $REQ"
  if ! python -m pip install -r "$REQ"; then
    echo "[ERR] pip failed to install requirements from $REQ" >&2
    echo "[HINT] Проверь содержимое файла зависимостей и сеть. Лог: $LOG" >&2
    exit 1
  fi
else
  echo "[WARN] requirements_rag.txt not found at $REQ — пропускаю установку Python-зависимостей"
fi

python -c 'import sys; print("[INFO] Python:", sys.version)'
pip --version || true

echo "[INFO] Installation complete. Log saved to: $LOG"
