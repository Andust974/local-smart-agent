#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/ai-agent/projects/local_smart_agent"
IN="$ROOT/tasks/inbox"; mkdir -p "$IN"
txt="${1:-$ROOT/sandbox/test_valid.txt}"
ts="$(date +%Y%m%d_%H%M%S)"
printf '{ "kind":"text_summary", "txt":"%s" }\n' "$(realpath --relative-to="$ROOT" "$txt")" > "$IN/task_${ts}_summary.json"
echo "[enqueue] queued text_summary for $txt"
