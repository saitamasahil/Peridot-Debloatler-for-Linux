#!/usr/bin/env bash
set -euo pipefail

BANNER="Redmi Turbo 3 / POCO F6 (Peridot) Restore Script (Linux)\nRe-enable previously debloated apps for user 0\n------------------------------------------------------------------------------"

echo -e "$BANNER"

# Check adb availability
if ! command -v adb >/dev/null 2>&1; then
  echo "Error: adb not found in PATH. Install Android platform-tools and try again." >&2
  exit 1
fi

# Start server and wait for a device
adb start-server >/dev/null 2>&1 || true

echo "Waiting for authorized device... (connect and authorize via USB)"
# Wait up to 60 seconds for an authorized device using adb get-state
authorized=0
for _ in {1..60}; do
  if adb get-state 2>/dev/null | grep -qx "device"; then
    authorized=1
    break
  fi
  sleep 1
done

# Verify authorized device is present
if [ "$authorized" -ne 1 ]; then
  echo "Error: No authorized device detected. Check USB cable, enable USB debugging AND USB debugging (Security settings) in Developer options, and authorize the PC (accept RSA prompt)." >&2
  adb devices
  exit 1
fi

# Package list to restore for current user (matches debloat list)
PACKAGES=(
  com.xiaomi.mipicks
  com.mi.globalminusscreen
  com.miui.cleaner
  com.xiaomi.glgm
  com.xiaomi.discover
  com.miui.yellowpage
  com.preff.kb.xm
  com.mi.android.globalFileexplorer
  com.google.android.apps.subscriptions.red
  com.google.android.videos
  com.google.android.mms
  com.google.android.apps.docs
  com.google.facebook.system
  com.google.android.apps.tachyon
  com.android.providers.downloads.ui
  com.miui.miservice
  com.facebook.appmanager
  com.facebook.services
  com.miui.player
  com.android.mms
)

# Restore (install-existing) for user 0
fail_count=0
for pkg in "${PACKAGES[@]}"; do
  echo "Restoring for user 0: $pkg"
  if ! adb shell cmd package install-existing --user 0 "$pkg" >/dev/null 2>&1; then
    echo "  Not found in system image or already present: $pkg"
    fail_count=$((fail_count+1))
  fi
 done

# Summary
ok_count=$(( ${#PACKAGES[@]} - fail_count ))
echo "------------------------------------------------------------------------------"
echo "Restore complete. Re-enabled: $ok_count  Not available/already present: $fail_count"
echo "If some apps do not appear, reboot the device."
echo "------------------------------------------------------------------------------"
