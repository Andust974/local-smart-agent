#!/usr/bin/env bash
set -Eeuo pipefail

BASE="http://127.0.0.1:${TASK_API_PORT:-8766}"

# Берём env юнита и аккуратно вырезаем USER/PASS (снятие кавычек и \r)
ENV_LINE="$(systemctl --user show task-api.service -p Environment | sed 's/^Environment=//')"
U="$(sed -n 's/.*TASK_API_BASIC_USER=\("\([^"]*\)"\|\([^ ]*\)\).*/\2\3/p' <<<"$ENV_LINE")"
P_RAW="$(sed -n 's/.*TASK_API_BASIC_PASS=\("\([^"]*\)"\|\([^ ]*\)\).*/\2\3/p' <<<"$ENV_LINE")"
P="$(printf '%s' "$P_RAW" | sed 's/^"//; s/"$//' | tr -d '\r')"

echo "[debug] U=\"$U\" (len=${#U})  P(len)=${#P}"

echo "== /health =="
curl -fsS "$BASE/health" | grep -q '"status"' || { echo "[FAIL] /health"; exit 1; }

echo "== /report_pack (no auth) =="
code=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/report_pack?count=1")
[ "$code" = "401" ] || { echo "[FAIL] expected 401, got $code"; exit 1; }

echo "== /report_pack (with auth) =="
resp=$(curl -fsS --user "$U:$P" "$BASE/report_pack?count=1") || { echo "[FAIL] curl auth"; exit 1; }
echo "$resp" | grep -q '"queued"' || { echo "[FAIL] no queued in resp: $resp"; exit 1; }

echo "[OK] All tests passed."
