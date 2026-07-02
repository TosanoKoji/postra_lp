#!/usr/bin/env bash
# verify-deploy.sh — Post-deploy security verification.
#
# Confirms that sensitive paths (.git, .claude, dev scripts, etc.) are NOT
# exposed publicly. Run this after every `wrangler deploy`. Fails non-zero
# if any forbidden path is reachable.
#
# Usage: ./verify-deploy.sh

set -uo pipefail

URLS=(
  "https://postra.link"
  "https://postra-lp.tosano-koji-0217.workers.dev"
)

# Paths that MUST return 404 (or 405). If any returns 200, exit 1.
FORBIDDEN=(
  /.git/HEAD
  /.git/index
  /.git/config
  /.git/COMMIT_EDITMSG
  /.git/logs/HEAD
  /.git/logs/refs/remotes/origin/main
  /.git/refs/heads/main
  /.git/objects/info/packs
  /.claude/launch.json
  /.wrangler/cache/cf.json
  /wrangler.jsonc
  /_worker.js
  /.gitignore
  /.assetsignore
  /package.json
  /package-lock.json
  /.env
  /.env.local
  /.DS_Store
  /HANDOFF.md
  /README.md
  /build-og.sh
  /_serve.py
  /assets/og-template.html
  /assets/og-template-ios.html
  /assets/videos/sns/sns/postra-hero-x-1x1.mp4
  /assets/og-image-original-text.png
)

# Paths that MUST return 200 (the LP itself). If any returns 404, exit 1.
REQUIRED=(
  /
  /ios
  /ios.html
  /ios.en.html
  /privacy.html
  /contact.html
  /tokushoho.html
  /releases.html
  /terms.html
  /tutorials.html
  /index.en.html
  /privacy.en.html
  /contact.en.html
  /releases.en.html
  /terms.en.html
  /tutorials.en.html
  /assets/og-image.png
  /assets/og-image-en.png
  /assets/og-image-ios.png
  /assets/og-image-ios-en.png
  /assets/ios/ip-collage.jpg
  /colors_and_type.css
)

failures=0

for URL in "${URLS[@]}"; do
  echo "=== ${URL} ==="
  for P in "${FORBIDDEN[@]}"; do
    cb="?cb=$(date +%s%N)"
    code=$(curl -sI -o /dev/null -w "%{http_code}" "${URL}${P}${cb}")
    if [ "$code" = "200" ]; then
      printf "  ❌ EXPOSED  %s -> %s\n" "$P" "$code"
      failures=$((failures + 1))
    fi
  done
  for P in "${REQUIRED[@]}"; do
    cb="?cb=$(date +%s%N)"
    code=$(curl -sI -o /dev/null -w "%{http_code}" "${URL}${P}${cb}")
    if [ "$code" != "200" ]; then
      printf "  ❌ MISSING  %s -> %s\n" "$P" "$code"
      failures=$((failures + 1))
    fi
  done
  echo "  (paths not shown passed ✅)"
done

echo
if [ "$failures" -eq 0 ]; then
  echo "✅ All checks passed. Deploy is safe."
  exit 0
else
  echo "🚨 ${failures} check(s) failed. Inspect output above."
  exit 1
fi
