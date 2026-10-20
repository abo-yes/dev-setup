# Mac keyboard on Windows

AutoHotkey v2 script that gives a MacBook keyboard Mac-style shortcuts on Windows.
Physical keys: Cmd = Win, Option = Alt.

```powershell
.\mac-keyboard\setup.ps1
```

Installs AutoHotkey (via winget), registers the script to start at login and runs it.
Run it from Windows PowerShell, not WSL. Edit `mac-keys.ahk` and re-run to reload.

| Mac | Sends | Notes |
| --- | --- | --- |
| Cmd + letter/number/symbol | Ctrl + same key | Copy, paste, save, find, new tab... Shift is kept |
| Cmd + C / V / T / W / F / N | Ctrl+Shift + same key | Windows Terminal only, so Ctrl+C stays SIGINT |
| Cmd + Left / Right | Home / End | |
| Cmd + Up / Down | Ctrl+Home / Ctrl+End | |
| Option + Left / Right | Ctrl + Left / Right | Word jump |
| Cmd + Backspace | Delete to line start | |
| Option + Backspace | Delete previous word | |
| Cmd + Q | Alt+F4 | |
| Cmd + Tab | Alt+Tab | |
| Cmd + Space | Start menu search | |
| Cmd + Shift + 3 / 4 | Print Screen / Snipping Tool | |
| Cmd + [ / ] | Back / forward | Browsers only |

## Notes

- Overriding `Win+<key>` disables the matching Windows shortcut (e.g. Win+E, Win+R).
  Delete the corresponding key from `keys` in the script if you need one back.
- VS Code keeps the IntelliJ keymap from `../vscode`; Cmd now behaves as Ctrl there.
- Install the MacBook Boot Camp / Apple keyboard drivers if Fn, brightness or volume keys misbehave.
- Alternatives: PowerToys Keyboard Manager (simple remaps only), Kinto (prebuilt AutoHotkey Mac keymap).
