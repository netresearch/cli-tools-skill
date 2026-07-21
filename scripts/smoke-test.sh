#!/usr/bin/env bash
# smoke-test.sh — Executes the skill's shell scripts end-to-end.
#
# The eval suite (evals/evals.json) only checks LLM prompting behavior; it
# never actually runs install_tool.sh or check_environment.sh. That gap let a
# broken catalog path (scripts moved under skills/cli-tools/ without updating
# the relative path to catalog/) and a set -e/pipefail interaction bug ship
# for multiple releases despite being 100% reproducible. This script runs the
# real entry points against the real repo layout so path and control-flow
# regressions like those fail CI instead of shipping silently.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$DIR/.." && pwd)"
SCRIPTS="$REPO_ROOT/skills/cli-tools/scripts"

RED="\033[0;31m"
GREEN="\033[0;32m"
NC="\033[0m"

FAILURES=0

pass() { echo -e "${GREEN}✓${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; FAILURES=$((FAILURES + 1)); }

echo "=== smoke-test: catalog resolution ==="

# Every catalog entry must resolve via install_tool.sh's own lookup, proving
# the DIR/../../../catalog (via lib/root.sh) math matches the real layout.
catalog_count=$(find "$REPO_ROOT/catalog" -name '*.json' | wc -l)
if [ "$catalog_count" -lt 1 ]; then
  fail "catalog directory empty or missing at $REPO_ROOT/catalog"
else
  pass "catalog directory found ($catalog_count entries)"
fi

# A known-good tool must report a real install_method, not "No catalog entry
# found" (the exact symptom of the path bug).
if output=$(bash "$SCRIPTS/install_tool.sh" fd status 2>&1); then
  pass "install_tool.sh fd status: $output"
else
  fail "install_tool.sh fd status failed:"$'\n'"$output"
fi

# A genuinely unknown tool must still enumerate real catalog entries in its
# error message, not an empty list.
if output=$(bash "$SCRIPTS/install_tool.sh" __not_a_real_tool__ status 2>&1); then
  fail "install_tool.sh __not_a_real_tool__ status unexpectedly succeeded"
else
  if echo "$output" | grep -q "fd "; then
    pass "install_tool.sh reports real available tools on unknown-tool error"
  else
    fail "install_tool.sh did not list real catalog entries:"$'\n'"$output"
  fi
fi

echo ""
echo "=== smoke-test: full installer round-trip ==="

# Actually install a small, single-static-binary tool via the github_release_binary
# installer to prove the whole chain (catalog lookup -> installer dispatch ->
# download -> binary in place) works, not just the catalog lookup in isolation.
# PREFIX (read by lib/install_strategy.sh's get_install_dir) isolates the
# install to a scratch dir instead of touching the real ~/.local/bin.
TMP_PREFIX="$(mktemp -d)"
if PREFIX="$TMP_PREFIX" bash "$SCRIPTS/installers/github_release_binary.sh" fd >/tmp/smoke-fd-install.log 2>&1; then
  if [ -x "$TMP_PREFIX/bin/fd" ] && "$TMP_PREFIX/bin/fd" --version >/dev/null 2>&1; then
    pass "github_release_binary.sh installed a working fd: $("$TMP_PREFIX/bin/fd" --version)"
  else
    fail "github_release_binary.sh reported success but $TMP_PREFIX/bin/fd is missing or broken:"$'\n'"$(cat /tmp/smoke-fd-install.log)"
  fi
else
  fail "github_release_binary.sh fd install failed:"$'\n'"$(cat /tmp/smoke-fd-install.log)"
fi
rm -rf "$TMP_PREFIX"

echo ""
echo "=== smoke-test: check_environment.sh completes without aborting early ==="

# Must reach its final exit 0, not stop partway through because set -e
# aborted on a helper function's by-design nonzero "issue count" return.
if output=$(bash "$SCRIPTS/check_environment.sh" audit "$REPO_ROOT" 2>&1); then
  if echo "$output" | grep -q "Core Tools Status"; then
    pass "check_environment.sh audit ran to completion"
  else
    fail "check_environment.sh audit exited 0 but stopped before the Core Tools Status section:"$'\n'"$output"
  fi
else
  fail "check_environment.sh audit exited non-zero:"$'\n'"$output"
fi

echo ""
if [ "$FAILURES" -eq 0 ]; then
  echo -e "${GREEN}All smoke tests passed${NC}"
  exit 0
else
  echo -e "${RED}$FAILURES smoke test(s) failed${NC}"
  exit 1
fi
