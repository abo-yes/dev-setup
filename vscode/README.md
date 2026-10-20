# VS Code setup sync

Keeps VS Code settings, keybindings, and extensions in sync across machines.

## Apply this config on a (new) machine

Windows:

```powershell
.\vscode\setup.ps1
```

macOS:

```bash
./vscode/setup.sh
```

Installs all extensions in `extensions.txt` and copies `settings.json` /
`keybindings.json` / `snippets/` into the VS Code user folder
(`%APPDATA%\Code\User` on Windows, `~/Library/Application Support/Code/User`
on macOS). Any existing files there are backed up to `*.bak` first.

## Update the config after changing VS Code

Change settings/keybindings/extensions in VS Code as usual, then pull the
new state into this repo:

Windows:

```powershell
.\vscode\sync.ps1
```

macOS:

```bash
./vscode/sync.sh
```

Review the diff, commit, and push. Run `setup.ps1` / `setup.sh` on your
other machines to pick up the change.
