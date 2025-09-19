#!/usr/bin/env bash
set -euo pipefail
U="${TASK_API_BASIC_USER:-lsa}"
P="${TASK_API_BASIC_PASS:-supersecret}"
curl -fsS -u "$U:$P" http://127.0.0.1:8766/health | grep -q '"ok"'
curl -fsS -u "$U:$P" "http://127.0.0.1:8766/reports/list?limit=3" | sed -n '1,40p'
echo "AUTH_SMOKE_OK"
