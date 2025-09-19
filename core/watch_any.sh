#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/ai-agent/projects/local_smart_agent"
IN="$ROOT/tasks/inbox"; DONE="$ROOT/tasks/done"; FAIL="$ROOT/tasks/failed"
RUN="$ROOT/core/task_runner.sh"
mkdir -p "$IN" "$DONE" "$FAIL"
echo "[watch_any] start"
while true; do
  for f in "$IN"/*.json; do
    [ -e "$f" ] || break
    name="$(basename "$f")"
    echo "[watch_any] process -> $name"
    if out="$(bash "$RUN" "$f" 2>&1)"; then
      mv -f "$f" "$DONE/$name"
      printf "%s\n" "$out" | sed 's/^/[watch_any] out: /'
    else
      mv -f "$f" "$FAIL/$name"
      printf "%s\n" "$out" | sed 's/^/[watch_any] err: /' >&2 || true
    fi
  done
  sleep 1
done
