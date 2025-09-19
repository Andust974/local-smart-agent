#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/ai-agent/projects/local_smart_agent"
IN="$ROOT/tasks/inbox"; mkdir -p "$IN"
inp="${1:-$ROOT/sandbox/test_valid.pdf}"
lang="${2:-eng+rus+pol}"
ts="$(date +%Y%m%d_%H%M%S)"
rel="$(realpath --relative-to="$ROOT" "$inp")"
printf '{ "kind":"ocr_scan", "path":"%s", "lang":"%s" }\n' "$rel" "$lang" > "$IN/task_${ts}_ocr.json"
echo "[enqueue] queued ocr_scan for $rel (lang=$lang)"
