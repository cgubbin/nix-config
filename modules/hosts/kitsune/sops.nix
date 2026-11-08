{ inputs, ... }: {
  flake.modules.nixos."hosts-kitsune-sops" =
    _:
    let
      secretspath = builtins.toString inputs.nix-secrets;
    in
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      sops = {
        defaultSopsFile = "${secretspath}/secrets.yaml";
        age = {
          sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
          keyFile = "/var/lib/sops-nix/key.txt";
          generateKey = true;
        };
        secrets = {
          kitsune_passwd = {
            neededForUsers = true;
          };
        };
      };
    };
}
