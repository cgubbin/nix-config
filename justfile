switch HOST:
    sudo nixos-rebuild switch --flake .#{{HOST}} --impure -v -L --show-trace
