# battery-guard

Forces you to charge a Mac before the battery drains fully. When you're
**unplugged** and at or below a threshold (default **10%**), it shows a
notification and **locks the screen**. You can log back in, but if you're still
under the threshold and unplugged it locks again within ~60s — so the only way
to keep working is to plug in. Non-destructive: nothing is closed, no shutdown,
no data loss.

## How it works

- `battery-guard.sh` reads `pmset -g batt`. If `state == discharging` and the
  percentage is `<= THRESHOLD`, it notifies and sends the native Lock Screen
  shortcut (`Control-Command-Q`).
- `com.abo.batteryguard.plist` is a LaunchAgent that runs the script every 60s
  (`StartInterval 60`, `RunAtLoad`).
- Installed **system-wide** so it applies to all user accounts:
  - script  -> `/Library/Scripts/battery-guard.sh`
  - agent   -> `/Library/LaunchAgents/com.abo.batteryguard.plist`

## Install

```bash
./setup.sh      # needs sudo; installs system-wide + loads for current session
```

## Accessibility permission (required, per user)

Sending a keystroke from a background agent requires Accessibility approval, and
macOS grants this **per user** — it cannot be set for another account.

- The first time the lock fires for a user, macOS shows a
  "…wants to control this computer using accessibility features" prompt — approve it.
- Or add it manually: **System Settings -> Privacy & Security -> Accessibility**,
  add `/bin/bash`, toggle on.
- To test on another account without waiting for a real low battery: log in as
  that user, temporarily set `THRESHOLD=100` in `/Library/Scripts/battery-guard.sh`,
  `sudo launchctl kickstart -k gui/$(id -u)/com.abo.batteryguard`, approve the
  prompt, then set the threshold back to `10`.

## Common tasks

```bash
# Change the cutoff (applies to all users)
sudo nano /Library/Scripts/battery-guard.sh      # edit THRESHOLD

# Pause / resume for the current session
sudo launchctl bootout   gui/$(id -u)/com.abo.batteryguard
sudo launchctl bootstrap gui/$(id -u) /Library/LaunchAgents/com.abo.batteryguard.plist

# Uninstall completely
sudo launchctl bootout gui/$(id -u)/com.abo.batteryguard
sudo rm /Library/LaunchAgents/com.abo.batteryguard.plist /Library/Scripts/battery-guard.sh
```

## Notes

- Only acts while **discharging** — plugged in at any level does nothing.
- macOS versioning: built/tested on macOS 26.x (Intel). The screensaver-based
  lock was avoided because the screen-lock grace period was 300s; the keystroke
  shortcut locks immediately regardless of that setting.
