#!/usr/bin/env bash
set -euo pipefail

BANNER="Redmi Turbo 3 / POCO F6 (Peridot) Safe Debloat Script (Linux)\nBy Sahil (Improved)\n------------------------------------------------------------------------------"

echo -e "$BANNER"

# Check adb availability
if ! command -v adb >/dev/null 2>&1; then
  echo "Error: adb not found in PATH. Install Android platform-tools and try again." >&2
  exit 1
fi

# Start server and wait for a device
adb start-server >/dev/null 2>&1 || true

echo "Waiting for authorized device... (connect and authorize via USB)"
authorized=0
for _ in {1..60}; do
  if adb get-state 2>/dev/null | grep -qx "device"; then
    authorized=1
    break
  fi
  sleep 1
done

if [ "$authorized" -ne 1 ]; then
  echo "Error: No authorized device detected. Check USB cable and enable USB debugging." >&2
  adb devices
  exit 1
fi

# Safe packages to uninstall (user 0 only)
PACKAGES=(
  com.xiaomi.mipicks
  com.mi.globalminusscreen
  com.miui.cleaner
  com.google.facebook.system
  com.xiaomi.glgm
  com.xiaomi.discover
  com.miui.yellowpage
  com.preff.kb.xm
  com.mi.android.globalFileexplorer
  com.google.android.videos
  com.google.android.apps.docs
  com.facebook.appmanager
  com.facebook.services
  com.miui.player
)

fail_count=0
for pkg in "${PACKAGES[@]}"; do
  # Check if package exists
  if adb shell pm list packages | grep -q "$pkg"; then
    echo "Uninstalling for user 0: $pkg"
    if ! adb shell pm uninstall -k --user 0 "$pkg" >/dev/null 2>&1; then
      echo "  Failed to uninstall: $pkg"
      fail_count=$((fail_count+1))
    fi
  else
    echo "  Package not found / already removed: $pkg"
    fail_count=$((fail_count+1))
  fi
done

ok_count=$(( ${#PACKAGES[@]} - fail_count ))
echo "------------------------------------------------------------------------------"
echo "Completed. Success: $ok_count  Skipped/Not found: $fail_count"
echo "Note: This hides apps for user 0 only. Restore with:"
echo "  adb shell cmd package install-existing --user 0 <package>"
echo "------------------------------------------------------------------------------"