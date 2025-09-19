#!/usr/bin/env bash
set -euo pipefail
systemctl --user restart task-api.service
sleep 1
curl -fsS http://127.0.0.1:8766/health | grep -q '"ok"'
curl -fsS "http://127.0.0.1:8766/reports/list?limit=3" | sed -n '1,40p'
echo "OK"
