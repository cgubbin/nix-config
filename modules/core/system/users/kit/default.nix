_: {
  flake.modules.nixos."hosts-common-users-kit" =
    {
      pkgs,
      ...
    }:
    {
      users = {
        mutableUsers = false;
        users = {
          kit = {
            isNormalUser = true;
            description = "Christopher Gubbin";
            extraGroups = [
              "networkmanager"
              "wheel"
            ];
            packages = with pkgs; [
              git
              git-crypt
              gnupg
              just
            ];
            shell = pkgs.fish;
          };
        };
      };

    };
}
