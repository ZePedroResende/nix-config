{ ... }:

{
  # ── Git ───────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      diff.colorMoved = "zebra";
      fetch.prune = true;
      rebase.autoStash = true;
      branch.sort = "-committerdate";
      merge.conflictstyle = "diff3";
    };
  };

  # ── Delta (diff pager) ─────────────────────────────────────────
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
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
