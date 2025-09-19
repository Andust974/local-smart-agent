#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Активация venv внутри контейнера (если он есть)
if [[ -d "$PROJECT_ROOT/.venv" ]]; then
  source "$PROJECT_ROOT/.venv/bin/activate"
fi

# Запуск API через uvicorn
exec uvicorn bin.task_api:app \
  --host 0.0.0.0 \
  --port 8766 \
  --workers 2
