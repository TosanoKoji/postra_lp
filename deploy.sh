#!/usr/bin/env bash
# deploy.sh — Safe LP deploy wrapper.
#
# Runs `wrangler deploy` then immediately verifies that no sensitive paths
# leaked through. Aborts with non-zero exit if verification fails.
#
# Usage: ./deploy.sh

set -euo pipefail

cd "$(dirname "$0")"

echo "=== Step 1/2: wrangler deploy ==="
npx wrangler deploy

echo
echo "=== Step 2/2: post-deploy security verification ==="
echo "  Waiting 5s for Cloudflare edge propagation..."
sleep 5
./verify-deploy.sh
