#!/usr/bin/env bash
# Renders the menu UI to docs/menu.png (light) and docs/menu-dark.png, unlocked.
# LOCKED=1 renders the free menu, with its Unlock row.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
PLUGINS=()   # SwiftUI macro plugins under Xcode, as in AppStore/build.sh
PLATFORM_PLUGINS="$(xcrun --sdk macosx --show-sdk-platform-path 2>/dev/null || true)/Developer/usr/lib/swift/host/plugins"
if [[ -d "$PLATFORM_PLUGINS" ]]; then PLUGINS=(-plugin-path "$PLATFORM_PLUGINS"); fi
# scripts/snapshot/Unlock.swift stands in for the files that need AmoreKit and Sparkle.
swiftc -O -parse-as-library "${PLUGINS[@]}" -sdk "$(xcrun --sdk macosx --show-sdk-path)" -target "$(uname -m)-apple-macos14.0" \
    $(ls Sources/*.swift | grep -v -E 'WheresMyMouseApp|Unlock|Updates') scripts/snapshot/main.swift scripts/snapshot/Unlock.swift \
    -o build/snapshot-menu
build/snapshot-menu docs/menu.png
build/snapshot-menu docs/menu-dark.png --dark
