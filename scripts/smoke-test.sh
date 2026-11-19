#!/usr/bin/env bash
# Usage: scripts/smoke-test.sh [base_url]   (default http://localhost:8080)
set -euo pipefail
BASE="${1:-http://localhost:8080}"
fail=0
check() { # name url expected_status
  code=$(curl -s -o /dev/null -w '%{http_code}' "$2" || true)
  if [ "$code" = "$3" ]; then echo "PASS $1 ($code)"; else echo "FAIL $1 expected $3 got $code"; fail=1; fi
}
check "home page"    "$BASE/"        200
check "health"       "$BASE/healthz" 200
check "custom 404"   "$BASE/missing" 404
check "status hidden from outside" "$BASE/nginx_status" 403
exit $fail
