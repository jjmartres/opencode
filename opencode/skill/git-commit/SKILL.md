---
name: Git Commit
description: Generates storytelling-focused Conventional Commits messages with Jira context integration, then commits and pushes changes. Use when the user says "commit", "git commit", or asks to commit changes.
license: MIT
compatibility: opencode
---

# Git Commit Skill

This skill generates Conventional Commits messages that tell a complete story for future code archeology, with optional Jira ticket context integration.

## When to Use This Skill

Activate this skill when:

- The user types "commit" or "git commit".
- The user says "commit this" or "let's commit".
- Work is complete and ready to commit.
- The user mentions committing or pushing changes.

## Critical Rules

- **NEVER add "Co-authored-by" to the git commit message.**
- **NEVER mention Opencode in commit messages.**
- **NEVER commit or push without explicit user confirmation.**

## Workflow

### 1. Gather Context & Validate

First, collect information and validate the changes:

1. **Run Pre-Commit Validation:**
    - Execute `pre-commit run -a` to run validations.
    - If it fails, report the issues and ask the user if they want to proceed with the commit anyway or stop to fix the issues.

2. **Gather Git Context:** Run these commands to understand the state of the repository.
    - `git status --porcelain`
    - `git diff` (to see all unstaged changes)
    - `git diff --staged`
    - `git log --oneline -5`
    - `git branch --show-current`

### 2. Stage Files for Commit

- If `git status` shows files are already staged, proceed with those files.
- If `git status` shows no staged files but there are modified/untracked files, **ask the user** if you should stage all changes using `git add .`. Proceed only after confirmation. Do not add all files automatically.

### 3. Extract Jira Ticket Context (If Applicable)

- Parse the current branch name (from `git branch --show-current`) to find Jira ticket IDs (e.g., `PROJ-123`).
- If a Jira ticket ID is found, use available tools to fetch ticket details (title, description) to understand the purpose of the changes.

### 4. Ask the User "Why?"

**This is the most important step.** You must understand the *intent* behind the code changes.

- Based on the `git diff`, Jira context, and recent logs, ask the user an open-ended question: **"I see the technical changes, but what was the primary goal or reason for this update?"**
- Wait for their response and use it as the core of the commit message body.

### 5. Create the Commit Message

Generate a multi-line commit message that tells a complete story. Use the reference table below to select a suitable type and optional emoji.

**Unified Format:**

```
type(scope): <optional_emoji> concise subject line

Why this change was needed:
[Incorporate the user's explanation and Jira ticket context here.]

What changed:
[Provide a technical summary of the modifications from the git diff.]

Problem solved:
[Explain the business or technical problem this change addresses.]

Refs: [PROJ-123] # Only if a Jira ticket was found
```

### 6. Get Confirmation and Execute

1. **Show the full, multi-line commit message to the user.**
2. **Ask for explicit confirmation** before proceeding (e.g., "Is this commit message okay to proceed?").
3. After receiving approval, execute the commit using a `heredoc` to preserve formatting.
4. Finally, **ask for confirmation to push** the changes (e.g., "Would you like me to push this commit?"). Push only after approval.

**Execution Commands:**

```bash
# To commit (use after message is approved)
git commit -m "$(cat <<'EOF'
type(scope): ✨ subject line

Why this change was needed:
[explanation]

What changed:
[technical summary]

Problem solved:
[problem description]

Refs: PROJ-123
EOF
)"

# To push (use after commit is successful and push is approved)
git push
```

## Storytelling Examples

### Example 1: Feature with Jira Context

```
feat(mcp): ✨ add tool execution timeout handling

Why this change was needed:
Tools were hanging indefinitely when external APIs failed to respond, blocking the entire MCP server. This was causing user-facing timeouts in the chat interface.

What changed:
- Added a configurable timeout wrapper around tool execution.
- Implemented graceful timeout error messages.
- Updated the tool registry to support per-tool timeout configuration.

Problem solved:
External API failures no longer block the MCP server. Users now receive clear timeout errors instead of indefinite hanging.

Refs: AGP-582
```

### Example 2: Bug Fix

```
fix(auth): 🐛 prevent token refresh race condition

Why this change was needed:
Multiple simultaneous requests were triggering concurrent token refresh attempts, causing some requests to fail with stale tokens.

What changed:
- Added a mutex lock around the token refresh logic.
- Implemented token refresh deduplication.
- Added retry logic for failed requests during the refresh.

Problem solved:
Concurrent requests no longer cause authentication failures due to token refresh race conditions.
```

## Commit Message Reference

This table provides the standard Conventional Commit `type` and a suggested `emoji` for different kinds of changes. The emoji is an optional but recommended enhancement to the commit subject line.

| Type | Emoji | Description |
| :--- | :--- | :--- |
| `feat` | ✨ | A new feature for the user. |
| `fix` | 🐛 | A bug fix for the user. |
| `docs` | 📝 | Documentation changes. |
| `style` | 💄 | Code style changes (formatting, etc.). |
| `refactor` | ♻️ | Code changes that neither fix bugs nor add features. |
| `perf` | ⚡️ | Performance improvements. |
| `test` | ✅ | Adding or fixing tests. |
| `chore` | 🔧 | Changes to build process, tools, etc. |
| `ci` | 🚀 | CI/CD improvements. |
| `revert` | ⏪️ | Reverting changes. |
| --- | --- | **Additional Types & Emojis** |
| `feat` | 🧵 | Add or update code related to multithreading or concurrency. |
| `feat` | 🔍️ | Improve SEO. |
| `feat` | 🏷️ | Add or update types. |
| `feat` | 💬 | Add or update text and literals. |
| `feat` | 🌐 | Internationalization and localization. |
| `feat` | 👔 | Add or update business logic. |
| `feat` | 📱 | Work on responsive design. |
| `feat` | 🚸 | Improve user experience / usability. |
| `feat` | 📈 | Add or update analytics or tracking code. |
| `feat` | 💥 | Introduce breaking changes. |
| `feat` | ♿️ | Improve accessibility. |
| `feat` | 🔊 | Add or update logs. |
| `feat` | 🥚 | Add or update an easter egg. |
| `feat` | 🚩 | Add, update, or remove feature flags. |
| `feat` | 🦺 | Add or update code related to validation. |
| `feat` | ✈️ | Improve offline support. |
| `fix` | 🚨 | Fix compiler/linter warnings. |
| `fix` | 🔒️ | Fix security issues. |
| `fix` | 🩹 | Simple fix for a non-critical issue. |
| `fix` | 🥅 | Catch errors. |
| `fix` | 👽️ | Update code due to external API changes. |
| `fix` | 🔥 | Remove code or files. |
| `fix` | 🚑️ | Critical hotfix. |
| `fix` | 💚 | Fix CI build. |
| `fix` | ✏️ | Fix typos. |
| `fix` | 🔇 | Remove logs. |
| `refactor`| 🚚 | Move or rename resources. |
| `refactor`| 🏗️ | Make architectural changes. |
| `refactor`| 🎨 | Improve structure/format of the code. |
| `refactor`| ⚰️ | Remove dead code. |
| `chore` | 👥 | Add or update contributors. |
| `chore` | 🔀 | Merge branches. |
| `chore` | 📦️ | Add or update compiled files or packages. |
| `chore` | ➕ | Add a dependency. |
| `chore` | ➖ | Remove a dependency. |
| `chore` | 🌱 | Add or update seed files. |
| `chore` | 🧑‍💻 | Improve developer experience. |
| `chore` | 🎉 | Begin a project. |
| `chore` | 🔖 | Release/Version tags. |
| `chore` | 📌 | Pin dependencies to specific versions. |
| `chore` | 📄 | Add or update license. |
| `chore` | 🙈 | Add or update .gitignore file. |
| `docs` | 💡 | Add or update comments in source code. |
| `test` | 🧪 | Add a failing test. |
| `test` | 🤡 | Mock things. |
| `test` | 📸 | Add or update snapshots. |
| `ci` | 👷 | Add or update CI build system. |
| `db` | 🗃️ | Perform database related changes. |
| `ui` | 💫 | Add or update animations and transitions. |
| `assets` | 🍱 | Add or update assets. |
| `wip` | 🚧 | Work in progress. |
| `experiment`| ⚗️ | Perform experiments. |
