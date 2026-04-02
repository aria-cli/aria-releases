# ARIA CLI

AI coding assistant that runs in your terminal.

## Install

```sh
# Recommended — standalone binary (no Node.js required)
curl -fsSL https://raw.githubusercontent.com/aria-cli/aria-releases/main/install.sh | sh

# Or via npm
npm i -g @aria-cli/cli

# Or via bun
bun install -g @aria-cli/cli
```

## Supported Platforms

| Platform | Architecture | Binary |
|----------|-------------|--------|
| macOS | Apple Silicon (arm64) | `aria-darwin-arm64` |
| macOS | Intel (x64) | `aria-darwin-x64` |
| Linux | x64 | `aria-linux-x64` |
| Linux | arm64 | `aria-linux-arm64` |

## Verify Installation

```sh
aria --version
```
