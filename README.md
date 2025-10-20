# Peridot Debloatler for Linux

A pair of Linux shell scripts to debloat Redmi Turbo 3 / POCO F6 (codename `peridot`) safely via ADB. Removes selected preinstalled apps for the current user only and provides a one‑command restore.

- Debloat script: `peridot_debloat.sh`
- Restore script: `peridot_restore.sh`

## Why "Peridot"?
"Peridot" is Xiaomi's internal device codename for Redmi Turbo 3 / POCO F6. The tool targets that device/ROM profile; it can work on similar MIUI/HyperOS builds but package presence may vary by region.

## Requirements
- Linux host with `adb` (Android platform‑tools) installed and in PATH.
- Phone with Developer options enabled.
- USB cable connection.

Install ADB (Debian/Ubuntu):
```bash
a sudo apt-get install adb
```

## Enable USB Debugging
On the phone (Developer options):
- Enable "USB debugging".
- Enable "USB debugging (Security settings)".
- When you first connect, accept the RSA authorization prompt.

If authorization fails, you can revoke and re‑authorize:
- Developer options → Revoke USB debugging authorizations → reconnect USB → accept prompt again.

## Usage
Make scripts executable (one‑time):
```bash
chmod +x "./peridot_debloat.sh" "./peridot_restore.sh"
```

Run debloat:
```bash
bash "./peridot_debloat.sh"
```

Run restore (undo debloat):
```bash
bash "./peridot_restore.sh"
```

## What the scripts do
- Both scripts wait for an authorized device (`adb get-state == device`).
- Debloat uses `pm uninstall -k --user 0 <package>` for a curated list of Xiaomi/Google/Facebook preloads.
- Restore uses `cmd package install-existing --user 0 <package>` to re‑enable the same apps.

Notes:
- `--user 0` only affects the primary user; system APKs remain intact.
- `-k` keeps app data; you can fully clean data later if needed.

## Rollback and safety
- Fully reversible without root using the restore script.
- You can also restore individual apps manually:
```bash
adb shell cmd package install-existing --user 0 <package>
```

## Common issues
- "No authorized device detected":
  - Ensure both USB debugging toggles are ON (including Security settings).
  - Accept the RSA prompt on the phone.
  - Use a good USB cable/port; try `adb kill-server && adb start-server`.
- Package shows "Skipped or not present":
  - That package isn’t on your ROM/region; the script continues safely.

## Credits
- Original debloat list credited to Poco F6 community (Windows `.bat`).
