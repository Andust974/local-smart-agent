#!/usr/bin/env bash
set -Eeuo pipefail
cd "$HOME/ai-agent/projects/local_smart_agent"
PY=".venv/bin/python"; [ -x "$PY" ] || PY="$(command -v python3)"
exec "$PY" bin/task_api.py --host 127.0.0.1 --port 8766
