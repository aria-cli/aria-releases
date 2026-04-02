# ARIA — AI Coding Assistant

**Superintelligent CLI that gets smarter with every interaction.**

Persistent memory, self-learning tools, knowledge graph, multi-model routing, autonomous agent loop — all in your terminal.

## Install

### Standalone Binary (recommended)

No Node.js, npm, or bun required. Just download and run.

```sh
curl -fsSL https://raw.githubusercontent.com/aria-cli/aria-releases/main/install.sh | sh
```

Supports:
- macOS (Apple Silicon + Intel)
- Linux (x64 + arm64)

### npm

```sh
npm i -g @aria-cli/cli
```

### bun

```sh
bun install -g @aria-cli/cli
```

## Usage

```sh
# Start interactive REPL
aria

# One-shot query
aria "explain this codebase"

# Check version
aria --version
```

## Platforms

| Platform | Architecture | Binary |
|----------|-------------|--------|
| macOS | Apple Silicon (arm64) | `aria-darwin-arm64` |
| macOS | Intel (x64) | `aria-darwin-x64` |
| Linux | x64 | `aria-linux-x64` |
| Linux | arm64 | `aria-linux-arm64` |

## Manual Download

Download binaries directly from [Releases](https://github.com/aria-cli/aria-releases/releases):

```sh
# macOS Apple Silicon
curl -fsSL -o aria https://github.com/aria-cli/aria-releases/releases/latest/download/aria-darwin-arm64
chmod +x aria
./aria --version
```

## Uninstall

```sh
rm ~/.local/bin/aria
```

Or if installed via npm:

```sh
npm uninstall -g @aria-cli/cli
```

## Links

- [npm](https://www.npmjs.com/package/@aria-cli/cli)
- [Releases](https://github.com/aria-cli/aria-releases/releases)
