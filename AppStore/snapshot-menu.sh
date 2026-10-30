#!/usr/bin/env bash
# Renders the App Store version's menu to AppStore/menu.png (light) and AppStore/menu-dark.png,
# with the same sample presets as scripts/snapshot-menu.sh. Useful for store screenshots.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
SHARED=(Preset Recipes PointerStore SuperShake RecipeMenu MenuView LaunchAtLogin)   # as in AppStore/build.sh
SOURCES=("${SHARED[@]/#/Sources/}")
PLUGINS=()   # SwiftUI macro plugins under Xcode, as in AppStore/build.sh
PLATFORM_PLUGINS="$(xcrun --sdk macosx --show-sdk-platform-path 2>/dev/null || true)/Developer/usr/lib/swift/host/plugins"
if [[ -d "$PLATFORM_PLUGINS" ]]; then PLUGINS=(-plugin-path "$PLATFORM_PLUGINS"); fi
swiftc -O -parse-as-library -D APP_STORE "${PLUGINS[@]}" -sdk "$(xcrun --sdk macosx --show-sdk-path)" -target "$(uname -m)-apple-macos13.0" \
    "${SOURCES[@]/%/.swift}" $(ls AppStore/Sources/*.swift | grep -v AppStoreApp.swift) scripts/snapshot/main.swift \
    -o build/snapshot-menu-appstore
# Unlocked, to show every feature. LOCKED=1 renders the free menu, with its Unlock row.
defaults write snapshot-menu-appstore unlocked -bool "$([[ -n "${LOCKED:-}" ]] && echo NO || echo YES)"
build/snapshot-menu-appstore AppStore/menu.png
build/snapshot-menu-appstore AppStore/menu-dark.png --dark
