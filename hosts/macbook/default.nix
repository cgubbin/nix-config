{ pkgs, ... }:
{
  imports = [
    ./homebrew.nix
  ];

  # Machine-wide packages
  environment.systemPackages = with pkgs; [
    vim
    devenv
  ];

  services = {
    karabiner-elements.enable = false;
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "kit"
    ];
  };

  # Enable shells at the system level
  programs.fish.enable = true;

  # nix-darwin metadata
  system.stateVersion = 4;
  system.primaryUser = "kit";

  # Host platform
  nixpkgs.hostPlatform = "aarch64-darwin";

  # User account
  users.users.kit = {
    name = "kit";
    home = "/Users/kit";
    shell = pkgs.fish;
  };

  system.defaults = {
    dock = {
      autohide = true;
      orientation = "left";
      show-process-indicators = false;
      show-recents = false;
      static-only = true;
    };

    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXEnableExtensionChangeWarning = false;
    };

    NSGlobalDomain = {
      AppleKeyboardUIMode = 3;
      "com.apple.keyboard.fnState" = true;
      _HIHideMenuBar = true;
    };
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  fonts.packages = [
    pkgs.monaspace
  ];

  networking = {
    hostName = "macbook";
    computerName = "macbook";
    localHostName = "macbook";
  };
}
