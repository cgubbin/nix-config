# Build and inspect before explicitly activating a generation.
build:
    nix build path:{{justfile_directory()}}#nixosConfigurations.kitsune.config.system.build.toplevel -L

check:
    nix flake check path:{{justfile_directory()}} -L

switch:
    sudo nixos-rebuild switch --flake path:{{justfile_directory()}}#kitsune -L --show-trace
