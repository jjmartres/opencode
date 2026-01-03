<div align="center">
  <a href="https://opencode.ai"><img src="opencode-logo.png" alt="Opencode logo"></a>
</div>

<p align="center">
    <strong>Personal OpenCode configuration with curated agents, skills, MCP servers, plugins, rules, and themes.</strong>
</p>

<p align="center">
    <a href="https://github.com/jjmartres/smartplaylist/issues"><img src="https://img.shields.io/github/issues/jjmartres/smartplaylist" alt="GitHub Issues"/></a>
    <a href="https://github.com/jjmartres/smartplaylist/pulls"><img src="https://img.shields.io/github/issues-pr/jjmartres/smartplaylist" alt="GitHub Pull Requests"/></a>
</p>

---

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration Structure](#configuration-structure)
- [Development](#development)
- [Superpowers Extension](#superpowers-extension)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Agents**: Specialized AI agents for various domains (payment integration, customer success, etc.)
- **Skills**: Reusable skill definitions for common workflows
- **MCP Servers**: Model Context Protocol server configurations
- **Plugins**: Custom OpenCode plugins
- **Rules**: Coding rules and best practices
- **Themes**: Custom themes for OpenCode
- **Automated Installation**: Uses GNU Stow or symlinks for easy deployment
- **Pre-commit Hooks**: Automatic validation and linting

## Prerequisites

- [OpenCode](https://opencode.ai) - AI-powered code editor
- [GNU Stow](https://www.gnu.org/software/stow/) - Symlink farm manager (optional but recommended)
- [Node.js](https://nodejs.org/) - JavaScript runtime (v18+)
- [Git](https://git-scm.com/) - Version control
- [pre-commit](https://pre-commit.com/) - Git hook framework (optional)

### Installing Prerequisites

**macOS:**

```bash
brew install stow node pre-commit
```

**Ubuntu/Debian:**

```bash
sudo apt install stow nodejs npm
pip install pre-commit
```

**Arch Linux:**

```bash
sudo pacman -S stow nodejs npm python-pre-commit
```

**Ubuntu/Debian:**

```bash
sudo apt install stow nodejs npm
pip install pre-commit
```

**Arch Linux:**

```bash
sudo pacman -S stow nodejs npm python-pre-commit
```

## Installation

### Quick Start

```bash
# Clone the repository
git clone https://github.com/jjmartres/opencode.git
cd opencode

# Install configuration
make install

# (Optional) Install pre-commit hooks
make install-hooks

# (Optional) Install Superpowers extension
make install-superpowers
```

### What Gets Installed

The installation process creates symlinks from this repository to `~/.config/opencode/`:

```
~/.config/opencode/
├── agent/      -> ~/opencode/opencode/agent/
├── command/    -> ~/opencode/opencode/command/
├── mcp/        -> ~/opencode/opencode/mcp/
├── plugin/     -> ~/opencode/opencode/plugin/
├── rules/      -> ~/opencode/opencode/rules/
├── skill/      -> ~/opencode/opencode/skill/
└── themes/     -> ~/opencode/opencode/themes/
```

### Installation Methods

The Makefile automatically detects if GNU Stow is available:

- **With Stow**: Uses `stow` for proper symlink management
- **Without Stow**: Falls back to `ln -s` for direct symlinks

## Usage

### Basic Commands

```bash
# Open current directory in OpenCode
opencode .

# Open specific file
opencode path/to/file.py

# Check installation status
make status

# List available packages
make list

# Update configuration (after pulling changes)
make restow
```

### Available Make Targets

```bash
make help                    # Display all available commands
make install                 # Install OpenCode configuration
make uninstall              # Remove configuration symlinks
make restow                 # Refresh symlinks (after updates)
make status                 # Show installation status
make list                   # List available packages
make clean                  # Remove broken symlinks

# Superpowers Extension
make install-superpowers    # Install obra's superpowers
make update-superpowers     # Update superpowers to latest
make uninstall-superpowers  # Remove superpowers
make superpowers-status     # Check superpowers installation

# Pre-commit Hooks
make install-hooks          # Install pre-commit hooks
make run-hooks             # Run hooks manually
make update-hooks          # Update hooks to latest versions

# Combined Operations
make install-all           # Install config + superpowers
make uninstall-all         # Remove everything
```

## Configuration Structure

```
opencode/
├── agent/                 # AI agent definitions
│   ├── 01-software-development/
│   ├── 07-specialized-domains/
│   └── 08-business-product/
├── command/              # Custom commands
├── mcp/                  # MCP server configurations
├── plugin/               # OpenCode plugins
├── rules/                # Coding rules and standards
├── skill/                # Reusable skills
│   ├── mcp-builder/
│   ├── content-research-writer/
│   └── meeting-insights-analyzer/
└── themes/               # UI themes
```

## Development

### Making Changes

1. Edit files in the `opencode/` directory
2. Changes are immediately reflected (symlinks!)
3. Restart OpenCode if needed

### Running Pre-commit Hooks

```bash
# Run all hooks on all files
make run-hooks

# Run specific hook
pre-commit run markdownlint --all-files

# Skip hooks for a commit (not recommended)
git commit --no-verify -m "message"
```

### Updating Configuration

```bash
# Pull latest changes
git pull origin main

# Refresh symlinks
make restow
```

## Superpowers Extension

[Superpowers](https://github.com/obra/superpowers) is a powerful extension that enhances OpenCode with additional capabilities.

### Installation

```bash
make install-superpowers
```

This clones the superpowers repository to `~/.config/opencode/superpowers` and automatically adds it to `.gitignore` to prevent accidental commits.

### Updating Superpowers

```bash
# Update to latest version
make update-superpowers

# Check current status
make superpowers-status
```

### Manual Installation

For detailed installation instructions, see the [official INSTALL guide](https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md).

## Troubleshooting

### Configuration Not Loading

```bash
# Check installation status
make status

# Verify symlinks
ls -la ~/.config/opencode/

# Reinstall
make uninstall
make install
```

### Stow Conflicts

```bash
# If you get conflicts, remove existing files first
rm -rf ~/.config/opencode/agent  # Repeat for other directories

# Then reinstall
make install
```

### Pre-commit Hooks Failing

```bash
# Run hooks manually to see errors
make run-hooks

# Update hooks
make update-hooks

# Uninstall/reinstall hooks
make uninstall-hooks
make install-hooks
```

## Contributing

Contributions are welcome! We appreciate bug reports, feature suggestions, new agents/skills, and documentation improvements.

Please read our [Contributing Guidelines](CONTRIBUTING.md) for:

- How to report bugs
- How to suggest enhancements
- Development workflow and pull request process
- Coding standards and pre-commit requirements
- Testing procedures

**Quick Start for Contributors:**

```bash
# Fork and clone
git clone https://github.com/YOUR_USERNAME/opencode.git
cd opencode

# Install with development hooks
make install
make install-hooks

# Make changes and test
make run-hooks
make status

# Submit a pull request!
```

For detailed contribution guidelines, see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT License - see [LICENSE](LICENSE) file for details

## Acknowledgments

- [OpenCode](https://opencode.ai) - The AI-powered code editor
- [Superpowers](https://github.com/obra/superpowers) - Extension by obra
- [GNU Stow](https://www.gnu.org/software/stow/) - Symlink farm manager
- All our [contributors](https://github.com/jjmartres/opencode/graphs/contributors)

## Support

- **Issues**: [GitHub Issues](https://github.com/jjmartres/opencode/issues)
- **Discussions**: [GitHub Discussions](https://github.com/jjmartres/opencode/discussions)
- **Contributing**: See [CONTRIBUTING.md](CONTRIBUTING.md)

---

**Note**: This configuration is tailored for personal use. Feel free to fork and customize for your needs!
