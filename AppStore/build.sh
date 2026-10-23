#!/usr/bin/env bash
# Builds the Mac App Store version, "dist/AppStore/Where's My Mouse.app", with the Command
# Line Tools (no Xcode), to try it out locally: sandboxed like the store build, signed ad-hoc.
# The build that goes to Apple comes from Xcode instead (AppStore/project.yml); see
# AppStore/SUBMISSION_CHECKLIST.md.
#
#   AppStore/build.sh          build, then check it uses public APIs only
#   AppStore/build.sh --run    build and open it
#
# Env:
#   ARCH=universal             build arm64 + x86_64 (default: this Mac's arch)
set -euo pipefail
cd "$(dirname "$0")/.."

# Sources/ files the App Store build shares with the direct build, and the ones it replaces
# (AppStore/Sources has its own entry point and CursorController). Every file in Sources/
# must be in one list, so a new file isn't silently left out of (or added to) this build.
SHARED=(Preset Recipes PointerStore SuperShake RecipeMenu MenuView LaunchAtLogin)
DIRECT_ONLY=(WheresMyMouseApp CursorController OverlayPointer)
for file in Sources/*.swift; do
    name="$(basename "$file" .swift)"
    if [[ ! " ${SHARED[*]} ${DIRECT_ONLY[*]} " =~ " $name " ]]; then
        echo "error: $file is in neither SHARED nor DIRECT_ONLY in $0 (and AppStore/project.yml)" >&2
        exit 1
    fi
done

# A setting from AppStore.xcconfig, the one place names and versions are set.
setting() { sed -n "s/^$1 = //p" AppStore/AppStore.xcconfig; }
EXECUTABLE="$(setting PRODUCT_NAME)"
BUNDLE_ID="$(setting PRODUCT_BUNDLE_IDENTIFIER)"
MIN_MACOS="$(setting MACOSX_DEPLOYMENT_TARGET)"
APP="dist/AppStore/$EXECUTABLE.app"
ARCH="${ARCH:-$(uname -m)}"
SDK="$(xcrun --show-sdk-path)"
SOURCES=("${SHARED[@]/#/Sources/}")
SOURCES=("${SOURCES[@]/%/.swift}" AppStore/Sources/*.swift)

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" build

compile() {
    swiftc -O -parse-as-library -D APP_STORE -sdk "$SDK" -target "$1-apple-macos$MIN_MACOS" "${SOURCES[@]}" -o "$2"
}

echo "Compiling App Store build ($ARCH)…"
if [[ "$ARCH" == universal ]]; then
    compile arm64 build/appstore-arm64
    compile x86_64 build/appstore-x86_64
    lipo -create build/appstore-arm64 build/appstore-x86_64 -output "$APP/Contents/MacOS/$EXECUTABLE"
else
    compile "$ARCH" "$APP/Contents/MacOS/$EXECUTABLE"
fi

# Fill in the $(…) build settings, as Xcode does.
sed -e "s/\$(EXECUTABLE_NAME)/$EXECUTABLE/" -e "s/\$(PRODUCT_BUNDLE_IDENTIFIER)/$BUNDLE_ID/" \
    -e "s/\$(MARKETING_VERSION)/$(setting MARKETING_VERSION)/" -e "s/\$(CURRENT_PROJECT_VERSION)/$(setting CURRENT_PROJECT_VERSION)/" \
    -e "s/\$(MACOSX_DEPLOYMENT_TARGET)/$MIN_MACOS/" AppStore/Info.plist > "$APP/Contents/Info.plist"
if grep -q '\$(' "$APP/Contents/Info.plist"; then echo "error: unfilled setting in Info.plist" >&2; exit 1; fi
cp Resources/AppIcon.icns AppStore/PrivacyInfo.xcprivacy "$APP/Contents/Resources/"
codesign --force --sign - --entitlements AppStore/WheresMyMouse.entitlements --identifier "$BUNDLE_ID" "$APP"
echo "Built $APP (ad-hoc signed, sandboxed)"

AppStore/check-public-api.sh "$APP"

if [[ "${1:-}" == "--run" ]]; then
    pkill -f "$APP/Contents/MacOS/$EXECUTABLE" 2>/dev/null || true
    open "$APP"
fi
