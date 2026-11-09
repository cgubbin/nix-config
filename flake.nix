{
  description = "NixOS Config";

  inputs = {
    doom-emacs = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    consumer-nixpkgs.url = "https://releases.nixos.org/nixpkgs/nixpkgs-26.11pre1092129.319e4cebef10/nixexprs.tar.zst";
    consumer-home-manager = {
      url = "github:nix-community/home-manager/640725978b99076e18e069f6e7d2959124584f8f";
      inputs.nixpkgs.follows = "consumer-nixpkgs";
    };
    consumer-nixvim = {
      url = "github:nix-community/nixvim/8485794923eb406ce3728af320392226608f724b";
      inputs.nixpkgs.follows = "consumer-nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:denful/import-tree";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    nix-secrets = {
      url = "git+ssh://git@github.com/cgubbin/nix-secrets?shallow=1&ref=main";
      flake = false;
    };

    #     hyprland = {
    #         url = "github:hyprwm/Hyprland";
    #     };
    #     hyprland-plugins = {
    #         url = "github:hyprwm/hyprland-plugins";
    #         inputs.hyprland.follows = "hyprland";
    #     };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.modules
        (inputs.import-tree ./modules)
      ];
    };
}
