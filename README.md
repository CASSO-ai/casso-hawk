# Casso Hawk

**Local versioning and file protection for AI-assisted development.**

Casso Hawk watches your project files and creates automatic snapshots as AI agents make changes. If something goes wrong, restore any file to any previous version instantly.

## Features

- **Automatic versioning** - Every file change creates a snapshot. No manual commits needed.
- **Instant restore** - Revert any file or folder to any previous version in seconds.
- **AI agent coordination** - Multiple AI agents can work on the same project safely with workspace isolation.
- **Zero-config protection** - Run one command to protect your project. Files stay visible and editable.
- **Git integration** - Works alongside git. Snapshots include git context for conflict detection.

## Quick Start

### Install (Linux / WSL2)

```bash
curl -sSL https://raw.githubusercontent.com/casso-ai/casso-hawk/main/install.sh | bash
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

- **Issues**: https://github.com/casso-ai/casso-hawk/issues
- **Documentation**: https://github.com/casso-ai/casso-hawk/wiki

## License

Proprietary software. See [LICENSE](LICENSE) for details.
