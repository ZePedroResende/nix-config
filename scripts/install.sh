#!/usr/bin/env bash
set -euo pipefail

# ── Colors ──────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

log()  { echo -e "${GREEN}[nix]${NC} $*"; }
warn() { echo -e "${YELLOW}[nix]${NC} $*"; }
die()  { echo -e "${RED}[nix]${NC} $*" >&2; exit 1; }

# ── Constants ───────────────────────────────────────────────────────
# These must match hosts/framework/hardware.nix
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LUKS_UUID="a73321fc-3b59-4b4c-9c79-deefc97c2d05"
LUKS_MAPPER="/dev/mapper/luks-${LUKS_UUID}"
ESP_DEV="/dev/disk/by-uuid/1AB0-FB2C"
MNT="/mnt"
BTRFS_OPTS="compress=zstd:1,ssd,discard=async,space_cache=v2"

# Subvolume names — must match hardware.nix fileSystems
SV_ROOT="@nixos"       # → /
SV_NIX="@nix-store"    # → /nix
SV_HOME="home"         # → /home (shared with Fedora)

# ── Cleanup trap ────────────────────────────────────────────────────
cleanup() {
    warn "Cleaning up mounts..."
    umount -R "$MNT" 2>/dev/null || true
    umount /tmp/btrfs-top 2>/dev/null || true
    rmdir /tmp/btrfs-top 2>/dev/null || true
}
trap cleanup EXIT

# ── Preflight ───────────────────────────────────────────────────────
[[ $EUID -eq 0 ]] || die "Run as root: sudo $0"
[[ -b "$LUKS_MAPPER" ]] || die "LUKS device not open — are you booted into Fedora?"
command -v curl &>/dev/null || die "curl is required"
[[ -f "$REPO_DIR/flake.nix" ]] || die "Missing $REPO_DIR/flake.nix"

echo ""
echo -e "${BOLD}NixOS installer for Framework 13 (AMD AI 300)${NC}"
echo ""
log "This will:"
log "  1. Install the Nix package manager (if missing)"
log "  2. Create btrfs subvolumes: ${SV_ROOT}, ${SV_NIX}"
log "  3. Install NixOS alongside Fedora (shared /home)"
log "  4. Add systemd-boot entry to the EFI partition"
echo ""
log "Disk layout after install:"
log "  ${SV_ROOT}      → NixOS root (new)"
log "  ${SV_NIX}  → /nix/store (new)"
log "  ${SV_HOME}        → /home (existing, shared with Fedora)"
echo ""
warn "Fedora will NOT be modified — both OSes boot from the EFI menu."
echo ""
read -rp "Continue? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || exit 0

# ── Step 1: Install Nix ────────────────────────────────────────────
if command -v nix &>/dev/null; then
    log "Nix already installed: $(nix --version)"
else
    log "Installing Nix package manager..."
    sh <(curl -L https://nixos.org/nix/install) --daemon

    # Source the daemon profile so nix is on PATH for the rest of the script
    if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        # shellcheck disable=SC1091
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi

    command -v nix &>/dev/null || die "Nix installation failed — nix not on PATH"
    log "Nix installed: $(nix --version)"
fi

export NIX_CONFIG="experimental-features = nix-command flakes"

# ── Step 2: Create btrfs subvolumes ────────────────────────────────
log "Creating btrfs subvolumes..."
mkdir -p /tmp/btrfs-top
mount -o subvolid=5 "$LUKS_MAPPER" /tmp/btrfs-top

for sv in "$SV_ROOT" "$SV_NIX"; do
    if btrfs subvolume show "/tmp/btrfs-top/$sv" &>/dev/null; then
        warn "Subvolume $sv already exists — skipping"
    else
        btrfs subvolume create "/tmp/btrfs-top/$sv"
        log "Created subvolume: $sv"
    fi
done

umount /tmp/btrfs-top
rmdir /tmp/btrfs-top

# ── Step 3: Mount target ───────────────────────────────────────────
log "Mounting target at $MNT..."

mount -o "subvol=${SV_ROOT},$BTRFS_OPTS"            "$LUKS_MAPPER" "$MNT"
mkdir -p "$MNT"/{nix,home,boot}
mount -o "subvol=${SV_NIX},$BTRFS_OPTS,noatime"     "$LUKS_MAPPER" "$MNT/nix"
mount -o "subvol=${SV_HOME},$BTRFS_OPTS"             "$LUKS_MAPPER" "$MNT/home"
mount "$ESP_DEV"                                      "$MNT/boot"

log "Target mounted."

# ── Step 4: Copy NixOS configuration ───────────────────────────────
log "Copying NixOS configuration..."
mkdir -p "$MNT/etc/nixos"
cp -r "$REPO_DIR"/{flake.nix,hosts,modules,home,templates,scripts} "$MNT/etc/nixos/"
[[ -f "$REPO_DIR/flake.lock" ]] && cp "$REPO_DIR/flake.lock" "$MNT/etc/nixos/"

# Flakes require files to be tracked by git
git -C "$MNT/etc/nixos" init -q
git -C "$MNT/etc/nixos" add -A

# ── Step 5: Build nixos-install-tools ───────────────────────────────
log "Fetching nixos-install-tools (first run downloads several GB)..."
NIX_INSTALL="$(nix build "nixpkgs#nixos-install-tools" --print-out-paths)/bin/nixos-install"

[[ -x "$NIX_INSTALL" ]] || die "Failed to build nixos-install-tools"
log "nixos-install ready."

# ── Step 6: Install NixOS ──────────────────────────────────────────
log "Installing NixOS (this takes a while — building the full system)..."
echo ""
"$NIX_INSTALL" \
    --root "$MNT" \
    --flake "$MNT/etc/nixos#framework" \
    --no-channel-copy

# ── Done ────────────────────────────────────────────────────────────
trap - EXIT
umount -R "$MNT"

echo ""
echo -e "${BOLD}━━━ NixOS installed successfully ━━━${NC}"
echo ""
log "Boot:      Reboot and press ${BOLD}F12${NC} to open the boot menu"
log "           Select ${BOLD}'Linux Boot Manager'${NC} for NixOS"
log "Login:     resende / ${BOLD}nixos${NC}  ← change this immediately"
log "Fedora:    Still available — select 'Fedora' in the boot menu"
echo ""
log "Config:    /etc/nixos/"
log "Rebuild:   sudo nixos-rebuild switch --flake /etc/nixos#framework"
echo ""
log "Symlink to git repo:"
log "  sudo rm -rf /etc/nixos"
log "  sudo ln -s $REPO_DIR /etc/nixos"
echo ""
