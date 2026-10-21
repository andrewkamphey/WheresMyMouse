#!/usr/bin/env bash
# Runs the App Store version's checks (AppStore/Tests) against the shared and App Store sources.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
SHARED=(Preset Recipes PointerStore SuperShake RecipeMenu MenuView LaunchAtLogin)   # as in AppStore/build.sh
SOURCES=("${SHARED[@]/#/Sources/}")
swiftc -parse-as-library -D APP_STORE -sdk "$(xcrun --show-sdk-path)" -target "$(uname -m)-apple-macos13.0" \
    "${SOURCES[@]/%/.swift}" $(ls AppStore/Sources/*.swift | grep -v AppStoreApp.swift) AppStore/Tests/*.swift \
    -o build/wheresmymouse-appstore-tests
build/wheresmymouse-appstore-tests
