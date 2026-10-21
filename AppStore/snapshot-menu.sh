#!/usr/bin/env bash
# Renders the App Store version's menu to AppStore/menu.png (light) and AppStore/menu-dark.png,
# with the same sample presets as scripts/snapshot-menu.sh. Useful for store screenshots.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
SHARED=(Preset Recipes PointerStore SuperShake RecipeMenu MenuView LaunchAtLogin)   # as in AppStore/build.sh
SOURCES=("${SHARED[@]/#/Sources/}")
swiftc -O -parse-as-library -D APP_STORE -sdk "$(xcrun --show-sdk-path)" -target "$(uname -m)-apple-macos13.0" \
    "${SOURCES[@]/%/.swift}" $(ls AppStore/Sources/*.swift | grep -v AppStoreApp.swift) scripts/snapshot/main.swift \
    -o build/snapshot-menu-appstore
build/snapshot-menu-appstore AppStore/menu.png
build/snapshot-menu-appstore AppStore/menu-dark.png --dark
