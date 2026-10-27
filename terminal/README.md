# Terminal setup

This folder installs [WezTerm](https://wezterm.org/) and links the shared config. WezTerm runs on Linux, macOS, and Windows, so the same terminal settings work across those systems.

## Install

macOS or Linux:

```bash
./terminal/setup.sh
```

Windows PowerShell:

```powershell
.\terminal\setup.ps1
```

The scripts install WezTerm when it is missing, then link `wezterm.lua` from this repo into the user config directory. Existing config files are moved to a `.bak` file first. The Windows script uses a symbolic link; if Windows blocks link creation, enable Developer Mode or run PowerShell as Administrator.

The macOS installer uses Homebrew. Linux uses the available native package manager (APT, pacman, DNF, or zypper), with Flatpak or Linuxbrew as fallbacks. Package availability can vary by distribution; see [WezTerm's Linux install guide](https://wezterm.org/install/linux.html) if your distro is not covered.

Edit `wezterm.lua` here, then restart WezTerm or reload its config with `Ctrl+Shift+R`.
