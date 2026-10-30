#!/usr/bin/env bash
# Renders the App Store screenshots to AppStore/screenshots/ (2880×1800 JPEGs): the demo slide
# with the app's own arrow, menu and Unlock offer drawn on it. Build dist/AppStore first (icon).
set -euo pipefail
cd "$(dirname "$0")/.."
OUT=build/storeshots
mkdir -p "$OUT"
cp AppStore/screenshots/src/Q3-Review.png "$OUT/"
sips -s format png -z 256 256 "$(ls "dist/AppStore/Where's My Mouse.app/Contents/Resources/"*.icns | head -1)" --out "$OUT/icon.png" >/dev/null
SHARED=(Preset Recipes PointerStore SuperShake RecipeMenu MenuView LaunchAtLogin)   # as in AppStore/build.sh
SOURCES=("${SHARED[@]/#/Sources/}")
PLUGINS=()   # SwiftUI macro plugins under Xcode, as in AppStore/build.sh
PLATFORM_PLUGINS="$(xcrun --sdk macosx --show-sdk-platform-path 2>/dev/null || true)/Developer/usr/lib/swift/host/plugins"
if [[ -d "$PLATFORM_PLUGINS" ]]; then PLUGINS=(-plugin-path "$PLATFORM_PLUGINS"); fi
swiftc -O -parse-as-library -D APP_STORE "${PLUGINS[@]}" -sdk "$(xcrun --sdk macosx --show-sdk-path)" -target "$(uname -m)-apple-macos13.0" \
    "${SOURCES[@]/%/.swift}" $(ls AppStore/Sources/*.swift | grep -v AppStoreApp.swift) AppStore/screenshots/src/main.swift \
    -o build/snapshot-store
build/snapshot-store "$OUT"
# The store won't take images with alpha.
for pair in 1-arrow:1-arrow 4-xl:2-extra-large 2-menu:3-menu 3-unlock:iap-review-unlock; do
    sips -s format jpeg -s formatOptions 92 "$OUT/store-${pair%%:*}.png" --out "AppStore/screenshots/${pair#*:}.jpg" >/dev/null
done
echo "Wrote AppStore/screenshots/"
