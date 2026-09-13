{pkgs, ...}: {
  programs.obsidian = {
    enable = pkgs.stdenv.isLinux;
    vaults.notes.target = "Obsidian";

    defaultSettings.app = {
      alwaysUpdateLinks = true;
      spellCheck = true;
    };
  };
}
