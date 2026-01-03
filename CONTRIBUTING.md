# Contributing to OpenCode Configuration

First off, thank you for considering contributing to this OpenCode configuration repository! It's people like you that make the open source community such a great place to learn, inspire, and create.

We welcome any type of contribution, not just code. You can help with:

- **Reporting bugs** in configurations or scripts
- **Discussing the current state** of agents, skills, or MCP servers
- **Submitting fixes** for broken configurations
- **Proposing new agents, skills, or themes**
- **Improving documentation**
- **Sharing your custom configurations**
- **Becoming a maintainer**

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Process](#development-process)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Project Structure](#project-structure)
- [Testing Your Changes](#testing-your-changes)
- [License](#license)

## Code of Conduct

This project adheres to a code of conduct that we expect all contributors to follow:

- Be respectful and inclusive
- Welcome newcomers and encourage diverse perspectives
- Focus on what is best for the community
- Show empathy towards other community members

## How Can I Contribute?

### Reporting Bugs

We use GitHub Issues to track bugs. Report a bug by [opening a new issue](https://github.com/jjmartres/opencode/issues/new).

**Great Bug Reports** include:

- **Quick summary** - One-line description of the issue
- **Steps to reproduce** - Be specific!

  ```bash
  1. Run `make install`
  2. Open OpenCode
  3. See error...
  ```

- **Expected behavior** - What you expected to happen
- **Actual behavior** - What actually happened
- **Environment details**:
  - OS: [e.g., macOS 14.0, Ubuntu 22.04]
  - OpenCode version: [e.g., 1.2.3]
  - Stow version (if applicable): [e.g., 2.3.1]
- **Additional context** - Screenshots, logs, or error messages
- **Possible fix** - If you have ideas (optional)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub Issues. When creating an enhancement suggestion, please include:

- **Clear title** - Descriptive and specific
- **Detailed description** - What you want to happen and why
- **Use cases** - Real-world scenarios where this would be useful
- **Examples** - Mock-ups, code samples, or references to similar features
- **Alternatives considered** - Other solutions you've thought about

### Contributing New Configurations

We love receiving new agents, skills, MCP servers, or themes! Here's how:

#### Adding a New Agent

1. Create a new file in the appropriate category:

   ```bash
   opencode/agent/XX-category/your-agent-name.md
   ```

2. Follow the existing agent structure:

   ```markdown
   # Agent Name

   Brief description of what this agent does.

   ## Capabilities
   - What it can do
   - Key features

   ## Usage
   How to use this agent

   ## Examples
   Example use cases
   ```

3. Test the agent in OpenCode
4. Submit a pull request

#### Adding a New Skill

1. Create a directory under `opencode/skill/`:

   ```bash
   opencode/skill/your-skill-name/
   ├── SKILL.md          # Main skill definition
   ├── examples/         # Example usage (optional)
   └── reference/        # Reference materials (optional)
   ```

2. Follow the SKILL.md template used in existing skills
3. Document prerequisites and usage
4. Submit a pull request

#### Adding MCP Servers

1. Add configuration to `opencode/mcp/`
2. Document setup instructions
3. Include example usage
4. Test the MCP server integration
5. Submit a pull request

## Development Process

We use GitHub to host code, track issues and feature requests, and accept pull requests.

### We Use [GitHub Flow](https://guides.github.com/introduction/flow/)

All code changes happen through pull requests:

1. **Fork the repository** and create your branch from `main`

   ```bash
   git clone https://github.com/YOUR_USERNAME/opencode.git
   cd opencode
   git checkout -b feature/your-feature-name
   ```

2. **Set up your development environment**

   ```bash
   make install
   make install-hooks  # Install pre-commit hooks
   ```

3. **Make your changes**
   - Add your configurations
   - Update documentation if needed
   - Follow the coding standards (see below)

4. **Test your changes**

   ```bash
   make restow          # Refresh symlinks
   make run-hooks       # Run pre-commit checks
   make status          # Verify installation
   ```

5. **Commit your changes**

   ```bash
   git add .
   git commit -m "feat: add new AI agent for X"
   ```

   Follow [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` - New feature
   - `fix:` - Bug fix
   - `docs:` - Documentation changes
   - `style:` - Formatting changes
   - `refactor:` - Code refactoring
   - `test:` - Adding tests
   - `chore:` - Maintenance tasks

6. **Push to your fork**

   ```bash
   git push origin feature/your-feature-name
   ```

7. **Open a Pull Request**

## Pull Request Process

1. **Update documentation** - README.md, configuration docs, etc.
2. **Follow the style guide** - Run `make run-hooks` to check
3. **Write clear PR description**:
   - What changes you made
   - Why you made them
   - How to test them
   - Screenshots (if applicable)
4. **Link related issues** - Use `Fixes #123` or `Closes #456`
5. **Wait for review** - Maintainers will review your PR
6. **Address feedback** - Make requested changes if needed
7. **Squash commits** - Clean up commit history if requested

### PR Title Format

Use conventional commit format:

```
feat(agent): add payment integration agent
fix(skill): correct MCP builder syntax
docs(readme): update installation instructions
```

## Coding Standards

### Markdown Files

- Use markdownlint-compliant formatting
- Run `make run-hooks` before committing
- Configuration is in `.markdownlint.yaml`

### JSONC Files

- Use comments to explain complex configurations
- Validate with `pre-commit run validate-jsonc`
- Keep formatting consistent

### Shell Scripts

- Use shellcheck for validation
- Follow POSIX standards where possible
- Add comments for complex logic

### General Guidelines

- **Be descriptive** - Clear names for files and variables
- **Document everything** - Explain what and why
- **Keep it simple** - Avoid over-engineering
- **Test thoroughly** - Verify changes work as expected
- **Stay consistent** - Follow existing patterns

### Pre-commit Hooks

All contributions must pass pre-commit hooks:

```bash
# Install hooks
make install-hooks

# Run manually
make run-hooks

# What gets checked:
# - Trailing whitespace
# - File endings
# - YAML/JSON syntax
# - Markdown formatting
# - Makefile syntax
# - Superpowers exclusion
```

## Project Structure

Understanding the structure helps you contribute effectively:

```
opencode/
├── agent/                 # AI agent definitions by category
├── command/              # Custom commands
├── mcp/                  # MCP server configurations
├── plugin/               # OpenCode plugins
├── rules/                # Coding rules and best practices
├── skill/                # Reusable skills with examples
└── themes/               # UI themes

Repository root:
├── .pre-commit-config.yaml   # Pre-commit hook configuration
├── .markdownlint.yaml        # Markdown linting rules
├── .stowrc                   # Stow configuration
├── Makefile                  # Automation scripts
├── README.md                 # Main documentation
└── CONTRIBUTING.md           # This file
```

### File Naming Conventions

- Use **kebab-case** for file names: `payment-integration.md`
- Use **descriptive names**: `customer-success-manager.md` not `csm.md`
- Add category prefixes where applicable: `01-software-development/`

## Testing Your Changes

Before submitting a PR, test your changes:

### Local Testing

```bash
# 1. Install your changes
make uninstall
make install

# 2. Verify symlinks
make status

# 3. Test in OpenCode
opencode .

# 4. Check for errors
make run-hooks

# 5. Verify clean state
make clean
```

### Testing Agents/Skills

1. Open OpenCode
2. Navigate to the agent/skill you added/modified
3. Test functionality with real use cases
4. Verify documentation is clear and accurate
5. Check for edge cases

### Testing Makefile Changes

```bash
# Test all targets
make help
make check
make install
make status
make list
make uninstall
```

## License

By contributing, you agree that your contributions will be licensed under the same [MIT License](LICENSE) that covers the project.

When you submit code changes, your submissions are understood to be under the MIT License. Feel free to contact maintainers if that's a concern.

## Questions?

Feel free to:

- Open an [issue](https://github.com/jjmartres/opencode/issues) for questions
- Start a [discussion](https://github.com/jjmartres/opencode/discussions)
- Reach out to maintainers directly

## Recognition

All contributors will be recognized in our README. Thank you for making this project better!

---

**Happy contributing!** 🎉
