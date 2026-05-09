#!/bin/sh
# ARIA binary installer
# Usage: curl -fsSL https://raw.githubusercontent.com/aria-cli/aria-releases/main/install.sh | sh
#
# The source of truth for this script is packages/cli's parent repo. On each
# release, release.mjs (Step 7c) uploads a copy to aria-cli/aria-releases
# so the public curl URL above always serves the latest version. The prior
# URL (aria-cli/aria) pointed at a private repo and 404'd.

set -e

REPO="aria-cli/aria-releases"
INSTALL_DIR="${ARIA_INSTALL_DIR:-$HOME/.local/bin}"
BINARY_NAME="aria"

OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Darwin) PLATFORM="darwin" ;;
  Linux) PLATFORM="linux" ;;
  *) echo "Error: Unsupported OS: $OS" >&2; exit 1 ;;
esac

case "$ARCH" in
  x86_64|amd64) ARCH="x64" ;;
  arm64|aarch64) ARCH="arm64" ;;
  *) echo "Error: Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

if [ "$PLATFORM" = "linux" ] && [ "$ARCH" = "x64" ]; then
  TARGET="${PLATFORM}-${ARCH}-baseline"
else
  TARGET="${PLATFORM}-${ARCH}"
fi

ARTIFACT="aria-${TARGET}.tar.gz"

fetch_json() {
  curl -fsSL "$1"
}
fetch_to() {
  curl -fsSL -o "$2" "$1"
}

if [ -n "${ARIA_VERSION:-}" ]; then
  VERSION="$ARIA_VERSION"
else
  VERSION=$(fetch_json "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/' || true)
fi

if [ -z "$VERSION" ]; then
  echo "Falling back to npm install because no release version was found..."
  if command -v bun >/dev/null 2>&1; then
    bun install -g @aria-cli/cli
  elif command -v npm >/dev/null 2>&1; then
    npm install -g @aria-cli/cli
  else
    echo "Need curl + bun or npm" >&2
    exit 1
  fi
  exit 0
fi

URL="https://github.com/$REPO/releases/download/v${VERSION}/${ARTIFACT}"
SHA_URL="${URL}.sha256"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$INSTALL_DIR"

echo "Installing ARIA v${VERSION} for ${TARGET}..."
fetch_to "$URL" "$TMP_DIR/$ARTIFACT"
fetch_to "$SHA_URL" "$TMP_DIR/$ARTIFACT.sha256" || true

if [ -f "$TMP_DIR/$ARTIFACT.sha256" ] && [ -z "${ARIA_NO_CHECKSUM:-}" ]; then
  EXPECTED=$(cut -d' ' -f1 "$TMP_DIR/$ARTIFACT.sha256")
  if command -v sha256sum >/dev/null 2>&1; then
    ACTUAL=$(sha256sum "$TMP_DIR/$ARTIFACT" | cut -d' ' -f1)
  else
    ACTUAL=$(shasum -a 256 "$TMP_DIR/$ARTIFACT" | cut -d' ' -f1)
  fi
  [ "$EXPECTED" = "$ACTUAL" ] || { echo "Checksum mismatch" >&2; exit 1; }
fi

tar -C "$TMP_DIR" -xzf "$TMP_DIR/$ARTIFACT"
mv "$TMP_DIR/aria" "$INSTALL_DIR/$BINARY_NAME"
chmod +x "$INSTALL_DIR/$BINARY_NAME"

echo "Installed to $INSTALL_DIR/$BINARY_NAME"
"$INSTALL_DIR/$BINARY_NAME" --version || true

echo
case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *) echo "Add to PATH: export PATH=\"$INSTALL_DIR:\$PATH\"" ;;
esac
