#!/usr/bin/env bash
# Regenerate assets/og-image.png from assets/og-template.html.
#
# OG 画像 (SNS シェア時のプレビュー画像) を再生成するスクリプト。
# LP のコピーやロゴを変更したときに、このスクリプトを実行すれば
# assets/og-image.png が新しい内容で書き換わります。
#
# 必要なもの:
#   - Google Chrome (macOS の通常パスにインストール済みであること)
#   - Python 3 + PIL (Pillow)  →  pip3 install Pillow で導入可能
#
# 使い方:
#   ./build-og.sh

set -euo pipefail

cd "$(dirname "$0")"

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
TEMPLATE="$PWD/assets/og-template.html"
RAW="/tmp/postra-og-raw.png"
OUT="$PWD/assets/og-image.png"

if [[ ! -x "$CHROME" ]]; then
  echo "Error: Google Chrome not found at $CHROME" >&2
  exit 1
fi

if [[ ! -f "$TEMPLATE" ]]; then
  echo "Error: template not found at $TEMPLATE" >&2
  exit 1
fi

echo "Rendering $TEMPLATE …"
"$CHROME" \
  --headless=new --hide-scrollbars --disable-gpu \
  --window-size=1200,750 --virtual-time-budget=3000 \
  --screenshot="$RAW" \
  "file://$TEMPLATE" >/dev/null 2>&1

if [[ ! -f "$RAW" ]]; then
  echo "Error: Chrome did not produce $RAW" >&2
  exit 1
fi

echo "Cropping to 1200x630 …"
python3 - "$RAW" "$OUT" <<'PY'
import sys
from PIL import Image
src, dst = sys.argv[1], sys.argv[2]
img = Image.open(src).crop((0, 0, 1200, 630))
img.save(dst)
PY

echo "Done: $OUT"
