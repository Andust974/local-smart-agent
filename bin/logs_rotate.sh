#!/usr/bin/env bash
set -Eeuo pipefail
D="$HOME/ai-agent/projects/local_smart_agent/logs"
mkdir -p "$D"
cd "$D"
for f in *.log; do
  [ -f "$f" ] || continue
  ts="$(date +%Y%m%d_%H%M%S)"
  cp "$f" "${f}.${ts}"
  : > "$f"
  gzip -f "${f}.${ts}"
done
# держать 7 архивов на файл
ls -1t *.log.*.gz 2>/dev/null | awk -F'.log.' '{print $1}' | sort -u | while read base; do
  ls -1t "${base}.log."*.gz 2>/dev/null | tail -n +8 | xargs -r rm -f
done
