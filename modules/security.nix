{ lib, pkgs, ... }:

let
  # Set to true after first boot + sbctl create-keys + sbctl enroll-keys --microsoft
  secureBoot = false;
in
{
  # ── Secure Boot (Lanzaboote) ──────────────────────────────────
  # Setup steps:
  #   1. Boot NixOS with Secure Boot OFF in BIOS
  #   2. sudo sbctl create-keys
  #   3. Change secureBoot above to true
  #   4. sudo nixos-rebuild switch --flake /etc/nixos#framework
  #   5. sudo sbctl verify
  #   6. sudo sbctl enroll-keys --microsoft  (keeps Fedora bootable)
  #   7. Reboot → BIOS → Enable Secure Boot
  boot.loader.systemd-boot.enable = lib.mkIf secureBoot (lib.mkForce false);
  boot.lanzaboote = lib.mkIf secureBoot {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  # ── Kernel hardening (sysctl) ─────────────────────────────────
  # NOTE: zram sysctl params are in base.nix — no duplicate keys
  boot.kernel.sysctl = {
    # Hide kernel pointers from non-root
    "kernel.kptr_restrict" = 2;
    # Only parent→child ptrace (GDB still works normally)
    "kernel.yama.ptrace_scope" = 1;
    # Only root can read kernel logs
    "kernel.dmesg_restrict" = 1;
    # Block unprivileged eBPF
    "kernel.unprivileged_bpf_disabled" = 1;
    # Harden BPF JIT
    "net.core.bpf_jit_harden" = 2;
    # Block unprivileged userfaultfd (kernel exploit mitigation)
    "vm.unprivileged_userfaultfd" = 0;

    # Network — anti-spoofing
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    # Block ICMP redirects (MITM protection)
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    # SYN flood protection
    "net.ipv4.tcp_syncookies" = 1;
    # Smurf attack protection
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;

    # Filesystem protections
    "fs.protected_hardlinks" = 1;
    "fs.protected_symlinks" = 1;
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;
  };

  # ── Blacklisted kernel modules ────────────────────────────────
  boot.blacklistedKernelModules = [
    # Unused network protocols
    "dccp" "sctp" "rds" "tipc"
    "n-hdlc" "ax25" "netrom" "x25" "rose"
    "decnet" "econet" "af_802154" "ipx"
    "appletalk" "p8023" "p8022" "can" "atm"
    # FireWire (DMA attack vector)
    "firewire-core" "firewire-ohci" "firewire-sbp2"
    # Uncommon filesystems
    "cramfs" "freevxfs" "jffs2" "hfs" "hfsplus"
  ];

  # ── Firewall (deny-by-default) ────────────────────────────────
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ 5353 ]; # mDNS — GNOME local service discovery
    allowPing = true;
    logReversePathDrops = true;
  };

  # ── DNS-over-TLS ──────────────────────────────────────────────
  # Encrypted DNS to Cloudflare + Quad9. Mullvad VPN overrides when active.
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = [
        "1.1.1.1#cloudflare-dns.com"
        "9.9.9.9#dns.quad9.net"
      ];
      FallbackDNS = [
        "1.1.1.1#cloudflare-dns.com"
        "9.9.9.9#dns.quad9.net"
      ];
      DNSOverTLS = true;
    };
  };

  # ── USBGuard ──────────────────────────────────────────────────
  # Devices present at boot are trusted; new USB devices are blocked until approved.
  # After first boot: sudo usbguard generate-policy | sudo tee /etc/usbguard/rules.conf
  services.usbguard = {
    enable = true;
    presentDevicePolicy = "allow";
    IPCAllowedUsers = [ "root" "resende" ];
  };

  # ── AppArmor ─────────────────────────────────────────────────
  security.apparmor = {
    enable = true;
    killUnconfinedConfinables = true;
    packages = with pkgs; [
      apparmor-utils
      apparmor-profiles
    ];
  };
  services.dbus.apparmor = "enabled";

  # ── Tmpfs for /tmp ───────────────────────────────────────────
  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "5G";
  };

  # ── SSH agent ────────────────────────────────────────────────
  # GNOME provides its own SSH agent (gcr-ssh-agent) — don't start a second one
  programs.ssh.startAgent = false;

  # ── GPG agent ────────────────────────────────────────────────
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
    pinentryPackage = pkgs.pinentry-gnome3;
    settings.default-cache-ttl = 14400; # 4 hours
  };

  # ── GNOME Keyring ────────────────────────────────────────────
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
}
