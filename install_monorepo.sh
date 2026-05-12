#!/bin/bash

# ════════════════════════════════════════════════════════════════════════
# install_monorepo.sh
# Installs the monorepo.sh tool globally for the user (no sudo needed)
# Symlinks directly to source — edits in LocalStash reflect immediately
# Usage: Run install_monorepo.sh once, then use 'monorepo' command from anywhere
# ════════════════════════════════════════════════════════════════════════

set -e

# ─── Source directory (where this script lives) ─────────────────
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"

echo -e "🚀 Installing monorepo project scaffolder..."
echo -e "   Source: $SOURCE_DIR"
echo ""

# ─── Create ~/bin if it doesn't exist ───────────────────────────
mkdir -p "$HOME/bin"

# ─── Symlink directly to source — no copy needed ────────────────
ln -sf "$SOURCE_DIR/monorepo.sh" "$HOME/bin/monorepo"
chmod +x "$SOURCE_DIR/monorepo.sh"

echo -e "✅ Symlink created:"
echo -e "   $HOME/bin/monorepo → $SOURCE_DIR/monorepo.sh"
echo -e "   Any edits in $SOURCE_DIR will reflect immediately."
echo ""

# ─── Patch both zshrc and bashrc if they exist ──────────────────
echo -e "🔧 Checking shell configs..."

for SHELL_CONFIG in "$HOME/.zshrc" "$HOME/.bashrc"; do
  if [ -f "$SHELL_CONFIG" ]; then
    if ! grep -q 'HOME/bin' "$SHELL_CONFIG"; then
      {
        echo ""
        echo "# Added by monorepo installer"
        echo "export PATH=\"\$HOME/bin:\$PATH\""
      } >> "$SHELL_CONFIG"
      echo -e "✅ PATH updated in $SHELL_CONFIG"
    else
      echo -e "✅ PATH already set in $SHELL_CONFIG — skipping"
    fi
  fi
done

echo ""

# ─── Check if already active in current session ─────────────────
if [[ ":$PATH:" == *":$HOME/bin:"* ]]; then
  echo -e "✅ \$HOME/bin is already active in this session."
else
  echo -e "=> Reload your shell configs to activate:"
  echo -e "   source ~/.zshrc    # zsh terminal"
  echo -e "   source ~/.bashrc   # bash terminal"
fi

echo ""
echo -e "=> Then run from anywhere:"
echo -e "   monorepo                          # prompted for name"
echo -e "   monorepo my-app                   # name as argument"
echo -e "   monorepo my-app /custom/path      # name + custom path"