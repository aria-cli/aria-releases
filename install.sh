#!/bin/sh
# ARIA CLI installer
# Usage: curl -fsSL https://raw.githubusercontent.com/hoang17/aria/main/scripts/install.sh | sh
#
# Installs the ARIA standalone binary to ~/.local/bin/aria
# No Node.js, npm, or bun required.

set -e

REPO="aria-cli/aria-releases"
INSTALL_DIR="${ARIA_INSTALL_DIR:-$HOME/.local/bin}"
BINARY_NAME="aria"

# ─── Detect platform ─────────────────────────────────────────────────────────

OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Darwin)  PLATFORM="darwin" ;;
  Linux)   PLATFORM="linux" ;;
  *)       echo "Error: Unsupported OS: $OS" >&2; exit 1 ;;
esac

case "$ARCH" in
  x86_64|amd64)  ARCH="x64" ;;
  arm64|aarch64) ARCH="arm64" ;;
  *)             echo "Error: Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

TARGET="${PLATFORM}-${ARCH}"

# ─── Fetch latest version ────────────────────────────────────────────────────

echo "⚡ Installing ARIA ($TARGET)"
echo ""

if command -v curl >/dev/null 2>&1; then
  FETCH="curl -fsSL"
elif command -v wget >/dev/null 2>&1; then
  FETCH="wget -qO-"
else
  echo "Error: curl or wget required" >&2; exit 1
fi

# Get latest release tag
LATEST=$($FETCH "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | sed 's/.*"v\(.*\)".*/\1/' 2>/dev/null || echo "")

if [ -z "$LATEST" ]; then
  # Fallback: get version from npm
  LATEST=$(npm view @aria-cli/cli version 2>/dev/null || echo "1.0.23")
fi

echo "  Version: $LATEST"
echo "  Target:  $TARGET"
echo "  Install: $INSTALL_DIR/$BINARY_NAME"
echo ""

# ─── Download binary ─────────────────────────────────────────────────────────

DOWNLOAD_URL="https://github.com/$REPO/releases/download/v${LATEST}/aria-${TARGET}"

mkdir -p "$INSTALL_DIR"

echo "  Downloading..."
DOWNLOAD_OK=false

# Method 1: gh CLI (works for private repos — most reliable)
if command -v gh >/dev/null 2>&1; then
  gh release download "v${LATEST}" --repo "$REPO" --pattern "aria-${TARGET}" --dir "$INSTALL_DIR" --clobber 2>/dev/null \
    && mv "$INSTALL_DIR/aria-${TARGET}" "$INSTALL_DIR/$BINARY_NAME" 2>/dev/null \
    && DOWNLOAD_OK=true
fi

# Method 2: curl with GITHUB_TOKEN (CI/automation)
if [ "$DOWNLOAD_OK" = false ] && [ -n "$GITHUB_TOKEN" ]; then
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/octet-stream" \
      "$DOWNLOAD_URL" -o "$INSTALL_DIR/$BINARY_NAME" 2>/dev/null && DOWNLOAD_OK=true
  fi
fi

# Method 3: Direct download (public repos only)
if [ "$DOWNLOAD_OK" = false ]; then
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL -L "$DOWNLOAD_URL" -o "$INSTALL_DIR/$BINARY_NAME" 2>/dev/null && DOWNLOAD_OK=true
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$DOWNLOAD_URL" -O "$INSTALL_DIR/$BINARY_NAME" 2>/dev/null && DOWNLOAD_OK=true
  fi
fi

if [ "$DOWNLOAD_OK" = false ] || [ ! -f "$INSTALL_DIR/$BINARY_NAME" ] || [ ! -s "$INSTALL_DIR/$BINARY_NAME" ]; then
  rm -f "$INSTALL_DIR/$BINARY_NAME" 2>/dev/null
  echo ""
  echo "  Binary not available yet for $TARGET."
  echo "  Falling back to npm install..."
  echo ""

  if command -v bun >/dev/null 2>&1; then
    bun install -g @aria-cli/cli@"$LATEST"
  elif command -v npm >/dev/null 2>&1; then
    npm install -g @aria-cli/cli@"$LATEST"
  else
    echo "Error: No package manager found. Install bun or npm first." >&2
    exit 1
  fi
  echo ""
  echo "  ✅ ARIA installed via npm"
  echo "  Run: aria --version"
  exit 0
fi

chmod +x "$INSTALL_DIR/$BINARY_NAME"

# ─── Verify ──────────────────────────────────────────────────────────────────

VERSION=$("$INSTALL_DIR/$BINARY_NAME" --version 2>/dev/null || echo "unknown")

echo ""
echo "  ✅ ARIA $VERSION installed to $INSTALL_DIR/$BINARY_NAME"
echo ""

# Check if install dir is in PATH
case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *)
    echo "  ⚠  Add $INSTALL_DIR to your PATH:"
    echo ""
    echo '    export PATH="'"$INSTALL_DIR"':$PATH"'
    echo ""
    SHELL_NAME="$(basename "$SHELL" 2>/dev/null || echo "bash")"
    case "$SHELL_NAME" in
      zsh)  RC="$HOME/.zshrc" ;;
      bash) RC="$HOME/.bashrc" ;;
      fish) RC="$HOME/.config/fish/config.fish" ;;
      *)    RC="$HOME/.profile" ;;
    esac
    echo "  Or add it permanently:"
    echo ""
    echo "    echo 'export PATH=\"$INSTALL_DIR:\$PATH\"' >> $RC"
    echo ""
    ;;
esac

echo "  Run: aria --version"
