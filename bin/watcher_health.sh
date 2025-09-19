#!/usr/bin/env bash
set -e
B="$HOME/ai-agent/projects/local_smart_agent"
[ -s "$B/logs/inbox_watcher.log" ] || { echo '{"status":"warn","msg":"no log"}'; exit 0; }
echo '{"status":"ok"}'
