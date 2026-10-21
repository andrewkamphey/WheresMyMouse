#!/usr/bin/env bash
# Fails if an App Store build links or loads anything private. Run on the built app:
#
#   AppStore/check-public-api.sh "dist/AppStore/Where's My Mouse.app"
#
# Catches what the direct build relies on: private CoreGraphics/SkyLight calls (CGS…/SLS…),
# private UniversalAccess and AccessibilityFoundation functions, private frameworks, and
# dlopen/dlsym (how private functions get loaded at runtime).
set -euo pipefail
APP="${1:?usage: $0 path/to/App.app}"
BIN="$APP/Contents/MacOS/$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$APP/Contents/Info.plist")"
failed=0

private_symbols="$(nm -u "$BIN" | grep -E '^_(CGS|SLS|_?AXInterface|AXF|CoreDock|DCS)|^_dl(open|sym)$' || true)"
if [[ -n "$private_symbols" ]]; then
    echo "✗ Private or dynamic-loading symbols:"; echo "$private_symbols" | sed 's/^/    /'; failed=1
fi

private_links="$(otool -L "$BIN" | grep -i 'PrivateFrameworks' || true)"
if [[ -n "$private_links" ]]; then
    echo "✗ Links private frameworks:"; echo "$private_links" | sed 's/^/    /'; failed=1
fi

if strings -a "$BIN" | grep -q -E 'PrivateFrameworks|SetsCursorInBackground|com\.apple\.universalaccess'; then
    echo "✗ References private framework paths or system pointer settings"; failed=1
fi

entitlements="$(codesign -d --entitlements - --xml "$APP" 2>/dev/null || true)"
if ! grep -q 'com.apple.security.app-sandbox' <<<"$entitlements"; then
    echo "✗ Not sandboxed (no com.apple.security.app-sandbox entitlement)"; failed=1
fi

if [[ $failed == 0 ]]; then echo "✓ Public APIs only, sandboxed: $APP"; fi
exit $failed
