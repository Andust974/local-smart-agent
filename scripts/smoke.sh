#!/usr/bin/env bash
set -Eeuo pipefail
BASE="http://127.0.0.1:8766"
echo -n "HEALTH: "
curl -fsS "$BASE/health" | grep -q '"ok"' && echo "OK" || { echo "FAIL"; exit 1; }
echo "LIST (limit=5):"
code=$(curl -sS -w '%{http_code}' -o /tmp/_lsa_list.json "$BASE/reports/list?limit=5")
[ "$code" = "200" ] || { echo "HTTP $code"; journalctl --user -u task-api.service -n 120 --no-pager | sed -n '/Traceback/,$p' | tail -n 60; exit 2; }
sed -n '1,30p' /tmp/_lsa_list.json
echo "SMOKE OK"
