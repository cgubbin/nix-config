{ config, ... }: {
  flake.modules.homeManager.home-kit-global-tools-git = {
    imports = [ config.flake.modules.homeManager.shared-git ];
    services.ssh-agent.enable = true;
    programs.git.settings = {
      user = {
        name = "cgubbin";
        email = "chris.gubbin@gmail.com";
      };
      github.user = "cgubbin";
    };
  };
}
