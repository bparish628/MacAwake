#!/bin/bash
# Usage: scripts/build.sh [--install]
set -euo pipefail
cd "$(dirname "$0")/.."

for arch in arm64 x86_64; do
  swift build -c release --triple "$arch-apple-macosx14.0"
done
BIN="build/MacAwake-universal"
mkdir -p build
lipo -create -output "$BIN" \
  "$(swift build -c release --triple arm64-apple-macosx14.0 --show-bin-path)/MacAwake" \
  "$(swift build -c release --triple x86_64-apple-macosx14.0 --show-bin-path)/MacAwake"

APP="build/MacAwake.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/MacAwake"
cp Resources/Info.plist "$APP/Contents/Info.plist"
codesign --force --sign - "$APP"
echo "Built $APP"

if [[ "${1:-}" == "--install" ]]; then
  pkill -x MacAwake || true
  rm -rf /Applications/MacAwake.app
  cp -R "$APP" /Applications/
  open /Applications/MacAwake.app
  echo "Installed to /Applications and launched"
fi
