#!/usr/bin/env bash
# Fails if an App Store build links or loads anything private. Run on the built app:
#
#   AppStore/check-public-api.sh "dist/AppStore/Where's My Mouse.app"
#
# Catches what the direct build relies on: private CoreGraphics/SkyLight calls (CGS…/SLS…),
# private UniversalAccess and AccessibilityFoundation functions, and private frameworks,
# whether linked directly or looked up by name at runtime. (dlsym itself isn't flagged:
# newer Swift toolchains' back-deployment support uses it.)
set -euo pipefail
APP="${1:?usage: $0 path/to/App.app}"
BIN="$APP/Contents/MacOS/$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$APP/Contents/Info.plist")"
failed=0

private_symbols="$(nm -u "$BIN" | grep -E '^_(CGS|SLS|_?AXInterface|AXF|CoreDock|DCS)' || true)"
if [[ -n "$private_symbols" ]]; then
    echo "✗ Private symbols:"; echo "$private_symbols" | sed 's/^/    /'; failed=1
fi

private_links="$(otool -L "$BIN" | grep -i 'PrivateFrameworks' || true)"
if [[ -n "$private_links" ]]; then
    echo "✗ Links private frameworks:"; echo "$private_links" | sed 's/^/    /'; failed=1
fi

# Names a dlsym lookup or a private call would carry as strings.
private_strings="$(strings -a "$BIN" | grep -E 'PrivateFrameworks|SetsCursorInBackground|com\.apple\.universalaccess|CGS[A-Z][A-Za-z]+|_?AXInterface|AXFCursor' || true)"
if [[ -n "$private_strings" ]]; then
    echo "✗ References private frameworks, functions or system pointer settings:"; echo "$private_strings" | sort -u | sed 's/^/    /'; failed=1
fi

entitlements="$(codesign -d --entitlements - --xml "$APP" 2>/dev/null || true)"
if ! grep -q 'com.apple.security.app-sandbox' <<<"$entitlements"; then
    echo "✗ Not sandboxed (no com.apple.security.app-sandbox entitlement)"; failed=1
fi

if [[ $failed == 0 ]]; then echo "✓ Public APIs only, sandboxed: $APP"; fi
exit $failed
