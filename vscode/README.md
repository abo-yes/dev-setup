# VS Code setup sync

Keeps VS Code settings, keybindings, and extensions in sync across machines.

## Apply this config on a (new) machine

```powershell
.\vscode\setup.ps1
```

Installs all extensions in `extensions.txt` and copies `settings.json` /
`keybindings.json` / `snippets/` into `%APPDATA%\Code\User`. Any existing
files there are backed up to `*.bak` first.

## Update the config after changing VS Code

Change settings/keybindings/extensions in VS Code as usual, then pull the
new state into this repo:

```powershell
.\vscode\sync.ps1
```

Review the diff, commit, and push. Run `setup.ps1` on your other machines
to pick up the change.
