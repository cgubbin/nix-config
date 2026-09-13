{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./sops.nix
    ../common/optional/stylix.nix
  ];

  wsl = {
    enable = true;
    defaultUser = "kit";

    wslConf = {
      network.hostname = "work";
    };
  };

  users.users.kit = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "26.05";
}
