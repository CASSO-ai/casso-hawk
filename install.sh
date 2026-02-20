#!/bin/bash
# =============================================================================
# Casso Hawk Installer
# =============================================================================
#
# Downloads and installs Casso Hawk on Linux/WSL2.
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/casso-ai/casso-hawk/main/install.sh | bash
#
#   # Install specific version:
#   curl -sSL .../install.sh | bash -s -- --version 0.1.0
#
#   # Install pre-release (for UAT testers):
#   curl -sSL .../install.sh | bash -s -- --pre
#
# =============================================================================

set -euo pipefail

# Configuration
REPO="casso-ai/casso-hawk"
INSTALL_DIR="$HOME/.local/bin"
PLATFORM="linux-x64"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Arguments
VERSION=""
PRE_RELEASE=false
SKIP_FUSE=false

# =============================================================================
# Argument parsing
# =============================================================================

while [[ $# -gt 0 ]]; do
    case "$1" in
        --version)
            VERSION="$2"
            shift 2
            ;;
        --pre)
            PRE_RELEASE=true
            shift
            ;;
        --skip-fuse)
            SKIP_FUSE=true
            shift
            ;;
        -h|--help)
            echo "Casso Hawk Installer"
            echo ""
            echo "Usage: curl -sSL .../install.sh | bash [-s -- OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --version X.Y.Z   Install specific version"
            echo "  --pre             Include pre-release versions"
            echo "  --skip-fuse       Skip FUSE prerequisite installation"
            echo "  -h, --help        Show this help"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}" >&2
            exit 1
            ;;
    esac
done

# =============================================================================
# Helper functions
# =============================================================================

info()    { echo -e "${BLUE}::${NC} $1"; }
success() { echo -e "${GREEN}::${NC} $1"; }
warn()    { echo -e "${YELLOW}::${NC} $1"; }
error()   { echo -e "${RED}:: ERROR:${NC} $1" >&2; }
fatal()   { error "$1"; exit 1; }

# =============================================================================
# Platform detection
# =============================================================================

detect_platform() {
    local os arch

    os=$(uname -s)
    arch=$(uname -m)

    if [ "$os" != "Linux" ]; then
        if [ "$os" = "Darwin" ]; then
            fatal "macOS is not yet supported. See: https://github.com/$REPO/issues"
        else
            fatal "Unsupported operating system: $os. Casso Hawk currently supports Linux and WSL2."
        fi
    fi

    if [ "$arch" != "x86_64" ]; then
        fatal "Unsupported architecture: $arch. Casso Hawk currently supports x86_64 only."
    fi

    # Detect WSL
    local is_wsl=false
    if grep -qi microsoft /proc/version 2>/dev/null; then
        is_wsl=true
    fi

    if [ "$is_wsl" = true ]; then
        info "Detected: WSL2 (Linux x86_64)"
    else
        info "Detected: Linux x86_64"
    fi
}

# =============================================================================
# Package manager detection
# =============================================================================

detect_package_manager() {
    if command -v apt-get &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v zypper &>/dev/null; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

# =============================================================================
# FUSE prerequisites
# =============================================================================

check_fuse_installed() {
    # Check if fuse3 or fuse is available
    if command -v fusermount3 &>/dev/null; then
        return 0
    elif command -v fusermount &>/dev/null; then
        return 0
    fi
    return 1
}

check_user_allow_other() {
    if [ -f /etc/fuse.conf ]; then
        if grep -q '^user_allow_other' /etc/fuse.conf 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

install_fuse() {
    local pkg_mgr
    pkg_mgr=$(detect_package_manager)

    echo ""
    echo -e "${BOLD}FUSE is required for Casso Hawk to protect your files.${NC}"
    echo ""

    case "$pkg_mgr" in
        apt)
            info "Installing fuse3 via apt..."
            echo "  This requires administrator access."
            echo ""
            if ! sudo apt-get update -qq && sudo apt-get install -y -qq fuse3; then
                echo ""
                error "FUSE installation failed."
                echo ""
                echo "To install manually:"
                echo "  sudo apt install fuse3"
                echo ""
                echo "Then re-run this installer."
                exit 1
            fi
            ;;
        dnf)
            info "Installing fuse3 via dnf..."
            echo "  This requires administrator access."
            echo ""
            if ! sudo dnf install -y fuse3; then
                echo ""
                error "FUSE installation failed."
                echo ""
                echo "To install manually:"
                echo "  sudo dnf install fuse3"
                echo ""
                echo "Then re-run this installer."
                exit 1
            fi
            ;;
        pacman)
            info "Installing fuse3 via pacman..."
            echo "  This requires administrator access."
            echo ""
            if ! sudo pacman -S --noconfirm fuse3; then
                echo ""
                error "FUSE installation failed."
                echo ""
                echo "To install manually:"
                echo "  sudo pacman -S fuse3"
                echo ""
                echo "Then re-run this installer."
                exit 1
            fi
            ;;
        *)
            error "Could not detect package manager."
            echo ""
            echo "Please install fuse3 manually using your system's package manager,"
            echo "then re-run this installer with --skip-fuse"
            exit 1
            ;;
    esac

    success "FUSE installed"
}

enable_user_allow_other() {
    echo ""
    info "Enabling user_allow_other in /etc/fuse.conf..."
    echo "  This allows Casso Hawk to make protected files visible to all processes."
    echo "  This requires administrator access."
    echo ""

    if ! sudo sed -i 's/^#user_allow_other/user_allow_other/' /etc/fuse.conf 2>/dev/null; then
        # If file doesn't exist or sed fails, try creating/appending
        if ! echo "user_allow_other" | sudo tee -a /etc/fuse.conf >/dev/null 2>&1; then
            echo ""
            error "Could not update /etc/fuse.conf"
            echo ""
            echo "To fix manually:"
            echo "  sudo sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf"
            echo ""
            echo "Then re-run this installer."
            exit 1
        fi
    fi

    success "user_allow_other enabled"
}

setup_fuse() {
    if [ "$SKIP_FUSE" = true ]; then
        info "Skipping FUSE setup (--skip-fuse)"
        return
    fi

    # Check if FUSE is installed
    if check_fuse_installed; then
        success "FUSE already installed"
    else
        install_fuse
    fi

    # Check user_allow_other
    if check_user_allow_other; then
        success "user_allow_other already enabled"
    else
        enable_user_allow_other
    fi
}

# =============================================================================
# Download and install
# =============================================================================

get_latest_version() {
    local api_url="https://api.github.com/repos/$REPO/releases"

    if [ "$PRE_RELEASE" = true ]; then
        # Get latest release including pre-releases
        api_url="${api_url}?per_page=1"
    else
        # Get latest stable release
        api_url="${api_url}/latest"
    fi

    local response
    response=$(curl -sSL "$api_url" 2>/dev/null) || fatal "Could not reach GitHub API. Check your internet connection."

    local tag
    if [ "$PRE_RELEASE" = true ]; then
        # Response is an array, get first item's tag_name
        tag=$(echo "$response" | grep -o '"tag_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\(v[^"]*\)".*/\1/')
    else
        tag=$(echo "$response" | grep -o '"tag_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\(v[^"]*\)".*/\1/')
    fi

    if [ -z "$tag" ]; then
        fatal "No releases found at https://github.com/$REPO/releases"
    fi

    echo "$tag"
}

download_and_install() {
    local tag="$1"
    local tarball_name="casso-hawk-${PLATFORM}.tar.gz"
    local checksum_name="${tarball_name}.sha256"
    local download_url="https://github.com/$REPO/releases/download/${tag}/${tarball_name}"
    local checksum_url="https://github.com/$REPO/releases/download/${tag}/${checksum_name}"

    info "Downloading Casso Hawk $tag..."

    local tmp_dir
    tmp_dir=$(mktemp -d)

    # Download tarball
    if ! curl -sSL -o "$tmp_dir/$tarball_name" "$download_url"; then
        rm -rf "$tmp_dir"
        fatal "Download failed. URL: $download_url"
    fi

    # Download checksum
    if ! curl -sSL -o "$tmp_dir/$checksum_name" "$checksum_url"; then
        rm -rf "$tmp_dir"
        fatal "Checksum download failed. URL: $checksum_url"
    fi

    # Verify checksum
    info "Verifying checksum..."
    if ! (cd "$tmp_dir" && sha256sum -c "$checksum_name" --quiet); then
        rm -rf "$tmp_dir"
        fatal "Checksum verification failed! The download may be corrupted. Please try again."
    fi
    success "Checksum verified"

    # Extract
    info "Extracting..."
    tar -xzf "$tmp_dir/$tarball_name" -C "$tmp_dir"

    # Install
    mkdir -p "$INSTALL_DIR"

    cp "$tmp_dir/casso-hawk" "$INSTALL_DIR/casso-hawk"
    chmod +x "$INSTALL_DIR/casso-hawk"

    cp "$tmp_dir/casso-hawk-daemon" "$INSTALL_DIR/casso-hawk-daemon"
    chmod +x "$INSTALL_DIR/casso-hawk-daemon"

    rm -rf "$tmp_dir"

    success "Installed to $INSTALL_DIR/"
}

# =============================================================================
# PATH configuration
# =============================================================================

ensure_path() {
    # Check if INSTALL_DIR is in PATH
    if echo "$PATH" | grep -q "$INSTALL_DIR"; then
        return
    fi

    info "Adding $INSTALL_DIR to PATH..."

    local shell_name
    shell_name=$(basename "${SHELL:-/bin/bash}")

    local profile_file
    case "$shell_name" in
        zsh)  profile_file="$HOME/.zshrc" ;;
        fish) profile_file="$HOME/.config/fish/config.fish" ;;
        *)    profile_file="$HOME/.bashrc" ;;
    esac

    # Check if already in profile
    if grep -q "$INSTALL_DIR" "$profile_file" 2>/dev/null; then
        return
    fi

    if [ "$shell_name" = "fish" ]; then
        echo "fish_add_path $INSTALL_DIR" >> "$profile_file"
    else
        echo "" >> "$profile_file"
        echo "# Casso Hawk" >> "$profile_file"
        echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$profile_file"
    fi

    success "Added to $profile_file"
    warn "Run 'source $profile_file' or open a new terminal to activate"
}

# =============================================================================
# Upgrade detection
# =============================================================================

check_existing_install() {
    local existing_bin="$INSTALL_DIR/casso-hawk"

    if [ -x "$existing_bin" ]; then
        local current_version
        current_version=$("$existing_bin" --version 2>/dev/null | head -1 || echo "unknown")
        echo "$current_version"
        return 0
    fi

    # Also check ~/.cargo/bin (previous install location)
    existing_bin="$HOME/.cargo/bin/casso-hawk"
    if [ -x "$existing_bin" ]; then
        local current_version
        current_version=$("$existing_bin" --version 2>/dev/null | head -1 || echo "unknown")
        echo "$current_version"
        return 0
    fi

    return 1
}

# =============================================================================
# Main
# =============================================================================

main() {
    echo ""
    echo -e "${BOLD}Casso Hawk Installer${NC}"
    echo -e "${BOLD}====================${NC}"
    echo ""

    # Check prerequisites
    if ! command -v curl &>/dev/null; then
        fatal "curl is required but not installed. Install it with: sudo apt install curl"
    fi

    # Detect platform
    detect_platform

    # Check for existing installation
    local existing_version
    if existing_version=$(check_existing_install); then
        echo ""
        warn "Casso Hawk is already installed: $existing_version"
        info "Continuing will upgrade/reinstall..."
        echo ""
    fi

    # Setup FUSE
    setup_fuse

    # Determine version
    local tag
    if [ -n "$VERSION" ]; then
        tag="v$VERSION"
        info "Installing version: $tag"
    else
        info "Finding latest release..."
        tag=$(get_latest_version)
        info "Latest version: $tag"
    fi

    # Download and install
    download_and_install "$tag"

    # Ensure PATH
    ensure_path

    # Run setup
    echo ""
    info "Running initial setup..."
    if "$INSTALL_DIR/casso-hawk" setup --quiet 2>/dev/null; then
        success "Setup complete"
    else
        # Setup might fail if shell can't be detected in pipe context
        warn "Auto-setup skipped. Run manually after installation:"
        echo "  casso hawk setup"
    fi

    # Success message
    echo ""
    echo -e "${GREEN}${BOLD}================================================${NC}"
    echo -e "${GREEN}${BOLD}  Casso Hawk installed successfully!${NC}"
    echo -e "${GREEN}${BOLD}================================================${NC}"
    echo ""
    echo "  Version: $tag"
    echo "  Location: $INSTALL_DIR/"
    echo ""
    echo "  Next steps:"
    echo "    1. Open a new terminal (or run: source ~/.bashrc)"
    echo "    2. Protect your project:"
    echo ""
    echo "       cd ~/myproject"
    echo "       casso hawk protect"
    echo ""
}

main "$@"
