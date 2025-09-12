#!/bin/bash

# Strubloid::linux::npm

npm-cache-verify()
{
    npm cache verify
}

npm-cache-clean()
{
    npm cache clear --force
}

setup_npm_global() {
  local NPM_GLOBAL="$HOME/.npm-global"

  echo "📦 Setting up npm global prefix at: $NPM_GLOBAL"
  mkdir -p "$NPM_GLOBAL"

  echo "🔧 Configuring npm prefix..."
  npm config set prefix "$NPM_GLOBAL"

  # Pick the right shell rc file
  local SHELL_RC="$HOME/.bashrc"
  [ -n "$ZSH_VERSION" ] && SHELL_RC="$HOME/.zshrc"

  # Add PATH line if not already present
  if ! grep -q 'npm-global/bin' "$SHELL_RC"; then
    echo "export PATH=\$HOME/.npm-global/bin:\$PATH" >> "$SHELL_RC"
    echo "✅ Added PATH update to $SHELL_RC"
  else
    echo "ℹ️ PATH already configured in $SHELL_RC"
  fi

  echo "🔄 Reloading shell config..."
  source "$SHELL_RC"

  echo "🎉 Done! You can now install global npm packages without sudo."
  echo "Try: npm install -g cowsay && cowsay hello"
}
