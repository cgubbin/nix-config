{
  description = "NixOS Config";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
      url = "github:danth/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
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
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #     hyprland = {
    #         url = "github:hyprwm/Hyprland";
    #     };
    #     hyprland-plugins = {
    #         url = "github:hyprwm/hyprland-plugins";
    #         inputs.hyprland.follows = "hyprland";
    #     };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-master,
    git-hooks-nix,
    home-manager,
    stylix,
    nix-index-database,
    sops-nix,
    niri,
    nixvim,
    firefox-addons,
    impermanence,
    nix-secrets,
    nix-darwin,
    ...
  }: let
    forEachSystem = nixpkgs.lib.genAttrs [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
    forEachPkgs = f: forEachSystem (system: f nixpkgs.legacyPackages.${system});
    mkChecks = system: {
      pre-commit-check = git-hooks-nix.lib.${system}.run {
        src = ./.;
        hooks = {
          nixfmt-rfc-style = {
            enable = false;
            settings.width = 110;
          };
          deadnix.enable = true;
          statix.enable = true;
        };
      };
    };

    mkShell = system:
      nixpkgs.legacyPackages.${system}.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        packages = with nixpkgs.legacyPackages.${system};
        with pkgs;
          [
            just
          ]
          ++ [
            pkgs.home-manager
          ];
      };

    mkNixos = user: host: system: specific-modules:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit (self) inputs outputs;
        };
        modules = let
          overlay-master = prev: final: {
            master = import nixpkgs-master {
              inherit prev final system;
              config.allowUnfree = true;
            };
          };
          overlay-unstable = final: prev: {
            unstable = import nixpkgs-unstable {
              inherit (final) system;
              config.allowUnfree = true;
            };
          };

          overlay-sof-unstable = final: prev: {
            sofFirmwareUnstable =
              (import nixpkgs-unstable {
                inherit (final) system;
                config.allowUnfree = true;
              }).sof-firmware;
          };
        in
          [
            (_: {
              nixpkgs.overlays = [
                overlay-master
                overlay-unstable
                overlay-sof-unstable
              ];
            })
            ./hosts/${host}
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                users.${user} = import ./home/${user}/${host}.nix;
                backupFileExtension = "backup_hm";
                extraSpecialArgs = {
                  inherit (self) inputs outputs;
                };
                sharedModules = [
                  sops-nix.homeManagerModules.sops
                  (_: {
                    nixpkgs.overlays = [
                      overlay-master
                    ];
                  })
                ];
              };
            }
            stylix.nixosModules.stylix
            nix-index-database.nixosModules.nix-index
            {
              programs.nix-index-database.comma.enable = true;
              programs.nix-index.enable = true;
            }
          ]
          ++ specific-modules;
      };
    mkDarwin = user: host: system: specific-modules:
      nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          inherit (self) inputs outputs;
        };
        modules = let
          overlay-master = prev: final: {
            master = import nixpkgs-master {
              inherit prev final system;
              config.allowUnfree = true;
            };
          };
          overlay-unstable = final: prev: {
            unstable = import nixpkgs-unstable {
              inherit (final) system;
              config.allowUnfree = true;
            };
          };
        in
          [
            (_: {
              nixpkgs.overlays = [
                overlay-master
                overlay-unstable
              ];
            })
            ./hosts/${host}
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                users.${user} = import ./home/${user}/${host}.nix;
                backupFileExtension = "backup_hm";
                extraSpecialArgs = {
                  inherit (self) inputs outputs;
                };
                sharedModules = [
                  sops-nix.homeManagerModules.sops
                  (_: {
                    nixpkgs.overlays = [
                      overlay-master
                    ];
                  })
                ];
              };
            }
          ]
          ++ specific-modules;
      };
  in {
    nix.nixPath = ["nixpkgs=${nixpkgs}"];
    formatter = forEachPkgs (pkgs: pkgs.nixfmt-rfc-style);

    checks."x86_64-linux" = mkChecks "x86_64-linux";
    devShells."x86_64-linux".default = mkShell "x86_64-linux";

    checks."aarch64-linux" = mkChecks "aarch64-linux";
    devShells."aarch64-linux".default = mkShell "aarch64-linux";

    nixosConfigurations = {
      kitsune = mkNixos "kit" "kitsune" "x86_64-linux" [
        #(_: {
        #    nixpkgs.overlays = [
        #     niri.overlays.niri
        #    ];
        #})
        #niri.nixosModules.niri
      ];
    };
    darwinConfigurations = {
      macbook = mkDarwin "kit" "macbook" "aarch64-darwin" [];
    };
  };
}
