#!/usr/bin/env bash
# Install battery-guard system-wide (all users) on macOS.
# Locks the screen when unplugged and at/below THRESHOLD% battery,
# re-locking every 60s until you plug in. Needs sudo.

set -euo pipefail

guard_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

script_src="$guard_dir/battery-guard.sh"
plist_src="$guard_dir/com.abo.batteryguard.plist"

script_dst="/Library/Scripts/battery-guard.sh"
plist_dst="/Library/LaunchAgents/com.abo.batteryguard.plist"

if [ "$(uname -s)" != "Darwin" ]; then
    echo "battery-guard is macOS-only." >&2
    exit 1
fi

echo "Installing shared script -> $script_dst"
sudo cp "$script_src" "$script_dst"
sudo chown root:wheel "$script_dst"
sudo chmod 755 "$script_dst"

echo "Installing system LaunchAgent -> $plist_dst"
sudo cp "$plist_src" "$plist_dst"
sudo chown root:wheel "$plist_dst"
sudo chmod 644 "$plist_dst"

echo "Loading agent for the current session..."
sudo launchctl bootout "gui/$(id -u)/com.abo.batteryguard" 2>/dev/null || true
sudo launchctl bootstrap "gui/$(id -u)" "$plist_dst"

cat <<'EOF'

battery-guard installed system-wide.

IMPORTANT: Each user must approve Accessibility once (the lock is sent as a
keystroke). System Settings -> Privacy & Security -> Accessibility, then enable
/bin/bash (or approve the prompt that appears the first time it locks).

Change the threshold later:  sudo nano /Library/Scripts/battery-guard.sh
Uninstall:
  sudo launchctl bootout gui/$(id -u)/com.abo.batteryguard
  sudo rm /Library/LaunchAgents/com.abo.batteryguard.plist /Library/Scripts/battery-guard.sh
EOF
