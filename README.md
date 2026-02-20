# Casso Hawk

**Never lose a change. Automatic versioning for AI-assisted development.**

> **Beta Software** - Casso Hawk is in active development. Use only on projects that are properly backed up (git, cloud sync, etc.). We assume no liability for data loss. See [LICENSE](LICENSE).

Casso Hawk protects your project files by creating automatic snapshots as AI agents make changes. No git commits required - every edit is captured instantly. If something goes wrong, restore any file to any previous version in seconds.

## Why Casso Hawk?

AI agents move fast. They edit dozens of files in minutes, and sometimes things go wrong - a bad refactor, a deleted function, a broken build. By the time you notice, the damage is done.

Casso Hawk sits between your files and your AI agents. Every change is versioned automatically. **No commits. No staging. No commands to remember.** Just protect your project and work normally.

## Features

- **Never lose a change** - Every file edit creates a snapshot automatically. Nothing slips through.
- **No git required** - Works with or without git. Snapshots are independent of your commit history.
- **Instant restore** - Revert any file or folder to any previous version in seconds.
- **AI agent coordination** - Multiple AI agents can work on the same project safely with workspace isolation.
- **Zero-config protection** - Run one command to protect your project. Files stay visible and editable.
- **Git-aware** - When git is present, snapshots include git context for conflict detection.

## Beta Access

Casso Hawk is currently in **closed beta**. To request access:

1. [Open an access request issue](https://github.com/CASSO-ai/casso-hawk/issues/new?title=Beta+Access+Request&body=Name:%0AUse+case:%0AEnvironment+(Linux/WSL2):)
2. We'll add you to the beta testers group
3. You'll receive install instructions

If you already have access, see [Installation](#installation) below.

## Installation

> **Requires beta access.** See [Beta Access](#beta-access) above.

### Linux / WSL2

```bash
curl -sSL https://raw.githubusercontent.com/CASSO-ai/casso-hawk/main/install.sh | bash
```

Then open a new terminal (or `source ~/.bashrc`) and protect your first project:

```bash
cd ~/myproject
casso hawk protect
```

### What Happens

1. **`casso hawk setup`** - One-time setup (shell integration, FUSE configuration)
2. **`casso hawk protect`** - Protect a project directory
3. Files remain visible and editable - Casso Hawk works transparently via FUSE
4. AI agents make changes, snapshots are created automatically
5. **`casso hawk snapshot list`** - See all snapshots
6. **`casso hawk file restore <file>`** - Restore a file to a previous version

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

- **Issues**: https://github.com/CASSO-ai/casso-hawk/issues
- **Documentation**: https://github.com/CASSO-ai/casso-hawk/wiki

## License

Proprietary software. See [LICENSE](LICENSE) for details.
