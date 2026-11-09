{ inputs, config, ... }:
{
  perSystem = { pkgs, ... }: {
    checks.doom-session = pkgs.testers.runNixOSTest {
      name = "doom-session";
      nodes.machine = { pkgs, ... }: {
        imports = [ inputs.home-manager.nixosModules.home-manager ];
        virtualisation.memorySize = 3072;
        users.users.consumer = {
          isNormalUser = true;
          uid = 1000;
          linger = true;
        };
        home-manager.useUserPackages = true;
        home-manager.users.consumer = {
          imports = [ config.flake.modules.homeManager.shared-doom-emacs ];
          home.stateVersion = "26.05";
          knowledge.orgDirectory = "/home/consumer/notes";
        };
        environment.systemPackages = [
          pkgs.xorg-server
          pkgs.procps
        ];
      };
      testScript = builtins.readFile ../../tests/doom/session.py;
    };
  };
}
