#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."
if [ -f ".venv/bin/activate" ]; then
  source ".venv/bin/activate"
fi
export PYTHONUNBUFFERED=1
exec python3 bin/task_api.py
