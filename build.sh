#!/usr/bin/env bash
# Builds "dist/Where's My Mouse.app", the direct download, with SwiftPM (Package.swift).
#
#   ./build.sh             build "dist/Where's My Mouse.app"
#   ./build.sh --install   build, copy to /Applications, and launch
#   ./build.sh --dmg       build, then make dist/WheresMyMouse.dmg (drag-to-Applications)
#   ./build.sh --notarize  --dmg, then notarize and staple it (needs a Developer ID identity
#                          and APPLE_ID, APPLE_TEAM_ID, APPLE_APP_PASSWORD)
#   ./build.sh --release   build, then `amore release` it: Amore notarizes, makes the DMG,
#                          signs the update and publishes it to the appcast Sparkle checks
#
# --dmg, --notarize and --release need Amore's values in Resources/Info.plist first
# (AmoreLicensingPublicKey, SUFeedURL, SUPublicEDKey).
#
# Env:
#   ARCH=universal         build arm64 + x86_64 (default: this Mac's arch; universal for --release)
#   SIGN_IDENTITY="Name"   codesign identity. Defaults to a "Developer ID Application" identity
#                          if one is in the keychain, else "WheresMyMouse Self-Signed"
#                          if scripts/setup-signing.sh has been run, else ad-hoc "-".
#                          A stable identity keeps Full Disk Access across rebuilds.
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="Where's My Mouse"   # the .app shown in Finder
EXECUTABLE=WheresMyMouse
BUNDLE_ID=com.wheresmymouse.WheresMyMouse
APP="dist/$APP_NAME.app"
ARCH="${ARCH:-$([[ "${1:-}" == --release ]] && echo universal || uname -m)}"
SELF_SIGNED="WheresMyMouse Self-Signed"
# Sparkle's own SwiftPM binary; SwiftPM's download of it hangs, so it's fetched here (Package.swift).
SPARKLE_VERSION=2.10.1
SPARKLE_SHA256=4c2e48a3e50ebcc2c88a58a4c7264a1a99c3c31857ce754357afb9cdb323022a

if [[ "${1:-}" =~ ^--(dmg|notarize|release)$ ]] && grep -q REPLACE_WITH Resources/Info.plist; then
    echo "error: put Amore's values in Resources/Info.plist first (see the REPLACE_WITH placeholders)" >&2
    exit 1
fi

if [[ -z "${SIGN_IDENTITY:-}" ]]; then
    DEVELOPER_ID="$(security find-identity -v -p codesigning | sed -n 's/.*"\(Developer ID Application: [^"]*\)".*/\1/p' | head -1)"
    if [[ -n "$DEVELOPER_ID" ]]; then
        SIGN_IDENTITY="$DEVELOPER_ID"
    elif security find-certificate -c "$SELF_SIGNED" >/dev/null 2>&1; then
        SIGN_IDENTITY="$SELF_SIGNED"
    else
        SIGN_IDENTITY="-"
        echo "Note: ad-hoc signing. Run scripts/setup-signing.sh once so Full Disk Access survives rebuilds."
    fi
fi

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$APP/Contents/Frameworks" build

if [[ "$(cat build/Sparkle.version 2>/dev/null)" != "$SPARKLE_VERSION" ]]; then
    echo "Downloading Sparkle $SPARKLE_VERSION…"
    curl -fsSL -o build/sparkle.zip \
        "https://github.com/sparkle-project/Sparkle/releases/download/$SPARKLE_VERSION/Sparkle-for-Swift-Package-Manager.zip"
    echo "$SPARKLE_SHA256  build/sparkle.zip" | shasum -a 256 -c - >/dev/null
    rm -rf build/Sparkle.xcframework build/sparkle
    unzip -q build/sparkle.zip -d build/sparkle
    mv build/sparkle/Sparkle.xcframework build/
    rm -rf build/sparkle build/sparkle.zip
    echo "$SPARKLE_VERSION" > build/Sparkle.version
fi

echo "Compiling ($ARCH)…"
if [[ "$ARCH" == universal ]]; then ARCHS=(--arch arm64 --arch x86_64); else ARCHS=(--arch "$ARCH"); fi
swift build -c release "${ARCHS[@]}"
BIN="$(swift build -c release "${ARCHS[@]}" --show-bin-path)"
cp "$BIN/$EXECUTABLE" "$APP/Contents/MacOS/$EXECUTABLE"
ditto build/Sparkle.xcframework/macos-arm64_x86_64/Sparkle.framework "$APP/Contents/Frameworks/Sparkle.framework"

cp Resources/Info.plist "$APP/Contents/Info.plist"
[[ -f Resources/AppIcon.icns ]] && cp Resources/AppIcon.icns "$APP/Contents/Resources/"

# Inside out: Sparkle's helpers, Sparkle, then the app.
SIGN=(codesign --force --sign "$SIGN_IDENTITY")
if [[ "$SIGN_IDENTITY" == "Developer ID Application:"* ]]; then
    SIGN+=(--options runtime --timestamp) # notarization requires the hardened runtime and a secure timestamp
fi
SPARKLE="$APP/Contents/Frameworks/Sparkle.framework"
"${SIGN[@]}" "$SPARKLE/Versions/B/XPCServices/Installer.xpc"
"${SIGN[@]}" --preserve-metadata=entitlements "$SPARKLE/Versions/B/XPCServices/Downloader.xpc"
"${SIGN[@]}" "$SPARKLE/Versions/B/Autoupdate"
"${SIGN[@]}" "$SPARKLE/Versions/B/Updater.app"
"${SIGN[@]}" "$SPARKLE"
"${SIGN[@]}" --identifier "$BUNDLE_ID" "$APP"
echo "Built $APP (signed: $SIGN_IDENTITY)"

if [[ "${1:-}" == "--dmg" || "${1:-}" == "--notarize" ]]; then
    STAGING="build/dmg"
    rm -rf "$STAGING" "dist/$EXECUTABLE.dmg"
    mkdir -p "$STAGING"
    cp -R "$APP" "$STAGING/"
    ln -s /Applications "$STAGING/Applications"
    hdiutil create -volname "$APP_NAME" -srcfolder "$STAGING" -ov -format UDZO "dist/$EXECUTABLE.dmg" >/dev/null
    rm -rf "$STAGING"
    [[ "$SIGN_IDENTITY" != "-" ]] && codesign --force --timestamp --sign "$SIGN_IDENTITY" "dist/$EXECUTABLE.dmg"
    echo "Built dist/$EXECUTABLE.dmg"
fi

if [[ "${1:-}" == "--notarize" ]]; then
    : "${APPLE_ID:?}" "${APPLE_TEAM_ID:?}" "${APPLE_APP_PASSWORD:?}"
    echo "Notarizing (usually a few minutes)…"
    xcrun notarytool submit "dist/$EXECUTABLE.dmg" --apple-id "$APPLE_ID" --team-id "$APPLE_TEAM_ID" \
        --password "$APPLE_APP_PASSWORD" --wait --timeout 30m
    xcrun stapler staple "dist/$EXECUTABLE.dmg"
    xcrun stapler staple "$APP"   # the DMG's ticket covers the app too, for the zip
    spctl --assess --type open --context context:primary-signature -v "dist/$EXECUTABLE.dmg"
    echo "Notarized dist/$EXECUTABLE.dmg"
fi

if [[ "${1:-}" == "--release" ]]; then
    command -v amore >/dev/null || { echo "error: install Amore's command line tool (Amore → Settings → Command Line)" >&2; exit 1; }
    amore release "$APP"
fi

if [[ "${1:-}" == "--install" ]]; then
    pkill -x "$EXECUTABLE" 2>/dev/null || true
    rm -rf "/Applications/$APP_NAME.app"
    cp -R "$APP" /Applications/
    open "/Applications/$APP_NAME.app"
    echo "Installed to /Applications/$APP_NAME.app"
fi
