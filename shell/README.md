# Enriched Zsh setup

This setup installs Zsh and [Oh My Zsh](https://ohmyz.sh/) on macOS or Linux, then links the repository's `zshrc` to `~/.zshrc`.

It includes the Git plugin, command autosuggestions, syntax highlighting, shared history, useful aliases, and a readable prompt. Existing `~/.zshrc` files are backed up before linking.

Run from the repository root:

```bash
./shell/setup.sh
```

Start a new terminal afterward, or run `exec zsh`.

The Windows equivalent is PowerShell, which has a separate profile model. The same aliases and prompt can be added there later without pretending that Oh My Zsh is a native Windows solution.
