{
    config,
    ...
}:
let
    inherit (config.home-config.cli.commonTools) enable;
in
{
    services.syncthing = {
        inherit enable;
        # openDefaultPorts = true;

        guiAddress = "127.0.0.1:8385";
        # user = "kit";
        # group = "users";

        key = "/home/kit/.keys/workstation/key.pem";
        cert = "/home/kit/.keys/workstation/cert.pem";

        overrideDevices = true;
        overrideFolders = true;

        settings = {
            devices = {
                "Christophers-MacBook-Pro.local" = {
                    id = "BMVUX2J-YQOZ5G5-YR7FFDB-NBVFNUX-47KBBTR-3BSQ2TL-GAKVBY3-GFYDMA3";
                };
            };

            folders = {
                "obsidian" = {
                    label="obsidian";
                    path = "/home/kit/obsidian";
                    devices = [
                        "Christophers-MacBook-Pro.local"
                    ];
                    versioning = {
                        type = "simple";
                        params = {
                            keep = "10";
                            cleanoutDays = "0";
                        };
                    };
                };
            };
        };

        # folders = {
        #     "obs" = {
        #         label = "Obsidian";
        #         path = "/home/kit/Obsidian";
        #         devices = [
        #             "MacBook Pro 2024"
        #         ];
        #     };
        # };
    };
}
