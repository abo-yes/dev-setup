#!/bin/bash
# battery-guard
# Locks the screen while the battery is low AND the Mac is unplugged,
# forcing you to plug in before you can keep using it.
# Runs every 60s via a LaunchAgent. Non-destructive: nothing is closed.

THRESHOLD=10   # lock at or below this battery %

batt=$(pmset -g batt)

# Current battery percentage (e.g. "38")
pct=$(echo "$batt" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')

# Charge state: "discharging" only when running on battery (unplugged)
state=$(echo "$batt" | grep -Eo 'discharging|charging|charged|finishing charge' | head -1)

# Act only when we have a reading, we're discharging, and at/under threshold
if [ -n "$pct" ] && [ "$state" = "discharging" ] && [ "$pct" -le "$THRESHOLD" ]; then
    osascript -e "display notification \"Battery at ${pct}% — plug in to keep working.\" with title \"Battery Guard\" sound name \"Funk\""
    sleep 2
    # Native Lock Screen shortcut: Control-Command-Q
    osascript -e 'tell application "System Events" to keystroke "q" using {control down, command down}'
fi
