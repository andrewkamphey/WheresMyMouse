#!/usr/bin/env bash
# Runs the App Store version's checks (AppStore/Tests) against the shared and App Store sources.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
SHARED=(Preset Recipes PointerStore SuperShake RecipeMenu MenuView LaunchAtLogin)   # as in AppStore/build.sh
SOURCES=("${SHARED[@]/#/Sources/}")
PLUGINS=()   # SwiftUI macro plugins under Xcode, as in AppStore/build.sh
PLATFORM_PLUGINS="$(xcrun --sdk macosx --show-sdk-platform-path 2>/dev/null || true)/Developer/usr/lib/swift/host/plugins"
if [[ -d "$PLATFORM_PLUGINS" ]]; then PLUGINS=(-plugin-path "$PLATFORM_PLUGINS"); fi
swiftc -parse-as-library -D APP_STORE "${PLUGINS[@]}" -sdk "$(xcrun --sdk macosx --show-sdk-path)" -target "$(uname -m)-apple-macos13.0" \
    "${SOURCES[@]/%/.swift}" $(ls AppStore/Sources/*.swift | grep -v AppStoreApp.swift) AppStore/Tests/*.swift \
    -o build/wheresmymouse-appstore-tests
build/wheresmymouse-appstore-tests
