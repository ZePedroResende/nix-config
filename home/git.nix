{ ... }:

{
  # ── Git ───────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    lfs.enable = true;
    delta = {
      enable = true;
      options = {
        navigate = true;
        side-by-side = true;
      };
    };
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
    };
  };

  # ── GitHub CLI ───────────────────────────────────────────────
  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  # ── LazyGit ──────────────────────────────────────────────────
  programs.lazygit.enable = true;
}
