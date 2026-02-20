# Casso Hawk

**Never lose a change. Never let your agents step on each other.**

> **Beta Software** — Casso Hawk is in active development. Use only on projects that are properly backed up. We assume no liability for data loss. See [LICENSE](LICENSE).

Casso Hawk is a local versioning engine and coordination layer for AI-assisted development. It captures every file change automatically — no git commits required — and coordinates multiple AI agents working on the same codebase so they never overwrite each other's work.

## The Problem

AI agents move fast. They edit dozens of files in minutes, and when things go wrong — a bad refactor, a deleted function, a broken build — the damage is done before you notice.

Run multiple agents and it gets worse. They overwrite each other's changes. They forget to commit. They push broken code. They work on stale branches and create merge conflicts that take longer to fix than the original task.

Casso Hawk solves both problems at once.

## Protect Everything

- **Every edit captured automatically** — No commands to remember. The moment a file changes, it's versioned. Nothing slips through.
- **No git required** — Snapshots are independent of your commit history. Works on any project, git or not.
- **Automatic git commits and push** — When a snapshot is saved, Casso Hawk commits and pushes to the remote automatically. Your agents never forget to commit.
- **Instant restore** — Revert any file or folder to any previous version in seconds. Cancel a snapshot and the entire project returns to its pre-change state in milliseconds.
- **Filesystem-enforced** — Protection operates at the filesystem level via FUSE. Files are physically read-only unless a snapshot is open. This isn't a convention — it cannot be bypassed.
- **Git history preservation** — Every snapshot creates a preservation ref on the remote. Even after rebases, branch deletions, or force pushes, you can trace back to any commit.

## Coordinate Everyone

- **Workspace isolation** — Each AI agent gets its own virtual copy of the project, created instantly. Agents work in parallel without seeing each other's in-progress changes.
- **Conflict detection before damage** — When agents lock the same file, their planned changes are compared. Overlapping work triggers warnings before anyone writes a line of code.
- **Validation gate** — Code is saved locally first, giving agents a chance to run tests and fix issues. Only validated code is pushed to the remote. Broken code never reaches your team.
- **Background sync** — All agents stay on the latest code automatically. The sync worker fetches from the remote every 30 seconds and refreshes workspaces on snapshot open, save, and cancel.
- **Merge conflict resolution** — When a push conflicts with remote changes, Casso Hawk shows the clean remote version alongside the agent's diff. Agents can leave merge instructions for whoever resolves the conflict.
- **Cross-VM coordination** — Agents running on different machines coordinate through the git remote. Each agent's snapshots, locks, and workspace state are visible to all others.

## Coming Soon

- **Non-AI auto mode** — Even without AI agents, every edit is captured automatically. A "black box recorder" for all file operations. *(In development)*
- **Web dashboard** — Monitor agent activity, snapshot history, and project status through a local web UI. *(In development)*
- **macOS support** — Native macFUSE integration. *(Planned)*
- **Windows support** — WinFsp integration. *(Planned)*

## Beta Access

Casso Hawk is in **closed beta**. To request access, email:

**support@casso.ai**

Include your name and a brief description of your use case. We'll send you a beta access token and install instructions.

## Installation

> Requires a beta access token. See [Beta Access](#beta-access).

### Linux / WSL2

```bash
curl -sSL https://raw.githubusercontent.com/CASSO-ai/casso-hawk/main/install.sh | bash -s -- --token YOUR_TOKEN
```

Then open a new terminal (or `source ~/.bashrc`) and protect your first project:

```bash
cd ~/myproject
casso hawk protect
```

### What Happens

1. **`casso hawk setup`** — One-time setup (shell integration, FUSE configuration)
2. **`casso hawk protect`** — Protect a project directory
3. Files remain visible and editable — Casso Hawk works transparently via FUSE
4. AI agents make changes, snapshots are created automatically
5. **`casso hawk snapshot list`** — See all snapshots
6. **`casso hawk file restore <file>`** — Restore a file to a previous version

## System Requirements

- **OS**: Linux (Ubuntu 20.04+, Debian 11+, Fedora 36+, Arch) or WSL2
- **Architecture**: x86_64
- **FUSE**: fuse3 (installed automatically by the install script)
- **Disk**: ~100MB for binaries + space for snapshots

## Commands

| Command | Description |
|---------|-------------|
| `casso hawk setup` | One-time system configuration |
| `casso hawk protect` | Protect the current directory |
| `casso hawk unprotect` | Remove protection |
| `casso hawk status` | Show protection status |
| `casso hawk snapshot list` | List snapshots |
| `casso hawk snapshot open --why "reason"` | Start a new snapshot |
| `casso hawk snapshot save` | Save the current snapshot |
| `casso hawk file restore <file>` | Restore a file |
| `casso hawk doctor` | System diagnostics |

## Troubleshooting

### Files not visible after protect

Make sure you ran `casso hawk setup` first and sourced your shell config:

```bash
casso hawk setup
source ~/.bashrc  # or open a new terminal
```

### FUSE errors

Run the doctor command for diagnostics:

```bash
casso hawk doctor
```

Common fixes:
- Install FUSE: `sudo apt install fuse3`
- Enable user_allow_other: `sudo sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf`

### Permission denied

The daemon needs access to your project files. Make sure you're running as the same user who installed Casso Hawk.

## Support

- **Email**: support@casso.ai
- **Issues**: https://github.com/CASSO-ai/casso-hawk/issues

## License

Proprietary software. See [LICENSE](LICENSE) for details.
