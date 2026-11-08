{ config, ... }:
let
  top = config;
in
{
  flake.modules.nixos."hosts-kitsune" = # Edit this configuration file to define what should be installed on
    # your system.  Help is available in the configuration.nix(5) man page
    # and in the NixOS manual (accessible by running ‘nixos-help’).
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [
        # Include the results of the hardware scan.
        top.flake.modules.nixos."hosts-kitsune-hardware-configuration"
        top.flake.modules.nixos."hosts-kitsune-sops"
        top.flake.modules.nixos."hosts-common-optional-fingerprint-scanner"
        top.flake.modules.nixos."hosts-common-optional-hyprland"
        top.flake.modules.nixos."hosts-common-optional-niri"
        top.flake.modules.nixos."hosts-common-optional-services"
        top.flake.modules.nixos."hosts-common-optional-stylix"
        top.flake.modules.nixos."hosts-common-optional-tethering"
        top.flake.modules.nixos."hosts-common-optional-tlp"
        # top.flake.modules.nixos."hosts-common-users-kit"
        top.flake.modules.nixos."hosts-common-global"
      ];

      boot.loader.systemd-boot.enable = true;
      # Keep rollback entries without filling the 1 GiB EFI partition.
      boot.loader.systemd-boot.configurationLimit = 5;
      boot.loader.efi.canTouchEfiVariables = true;

      # Use latest kernel.
      # boot.kernelPackages = pkgs.linuxPackages_latest;

      # Uncomment if in offload
      boot.blacklistedKernelModules = [
        "nouveau"
      ];

      boot.initrd.kernelModules = [
        "nvidia"
        "i915"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
      ];
      # boot.kernelPackages = pkgs.linuxPackages_latest;
      boot.kernelPackages = pkgs.linuxPackages_6_18;

      # Sound card fix?

      networking.hostName = "kitsune"; # Define your hostname.
      # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

      # Configure network proxy if necessary
      # networking.proxy.default = "http://user:password@proxy:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      # Enable networking
      networking.networkmanager.enable = true;

      users.mutableUsers = false;
      users.groups.backup = { };
      users.users.kit = {
        isNormalUser = true;
        description = "Christopher Gubbin";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        shell = pkgs.fish;
        hashedPasswordFile = config.sops.secrets.kitsune_passwd.path;
      };

      users.users.backup = {
        isSystemUser = true;
        group = "backup";

        description = "Restic backup user";

        home = "/var/lib/backup";
        createHome = true;

        shell = "${pkgs.bash}/bin/bash";

        openssh.authorizedKeys.keyFiles = [
          ./../../../assets/keys/backup.pub
          # Pi backup public key goes here
        ];
      };

      # Enable the KDE Plasma Desktop Environment.
      services.displayManager.sddm.enable = true;
      services.displayManager.sddm.wayland.enable = true;

      services.resolved.enable = true;
      # services.desktopManager.plasma6.enable = true;

      # Configure keymap in X11
      # services.xserver.xkb = {
      #   layout = "us";
      #   variant = "colemak_dh_ortho";
      # };

      # Enable automatic login for the user.
      services.displayManager.autoLogin.enable = true;
      services.displayManager.autoLogin.user = "kit";

      services.openssh = {
        enable = true;
        openFirewall = true;

        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };

        sftpServerExecutable = "internal-sftp";

        extraConfig = ''
          Match User backup
            ChrootDirectory none
            ForceCommand internal-sftp
            AllowTcpForwarding no
            X11Forwarding no
            PermitTTY no
        '';
      };

      networking.firewall.trustedInterfaces = [ "tailscale0" ];

      programs.fish.enable = true;

      virtualisation.docker = {
        enable = false;
      };

      programs.steam = {
        enable = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
      };

      services.tailscale = {
        enable = true;
        openFirewall = true;
      };

      # List packages installed in system profile. To search, run:
      # $ nix search wget
      environment.systemPackages = with pkgs; [
        vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        #  wget
        lshw
        fwupd
      ];
      services.fwupd.enable = true;

      environment.sessionVariables = {
        WLR_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0";
      };

      # Enable OpenGL
      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
        ];
      };

      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "iHD";
        MOZ_ENABLE_WAYLAND = "1";
      };

      # Load nvidia driver for Xorg and Wayland
      services.xserver.videoDrivers = [
        # Uncomment if in offload mode
        "modesetting"
        "nvidia"
      ];

      hardware.enableAllFirmware = true;
      hardware.firmware = [
        pkgs.linux-firmware
        pkgs.sof-firmware
      ];

      hardware.nvidia = {
        # Mode setting is required
        modesetting.enable = true;

        # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
        # Enable it if you have graphical corruption issues, or application crashes after
        # waking from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
        # of just the bare essentials
        powerManagement.enable = false;

        # Fine-grained power management. Turns off the GPU when not in use.
        # Experimental and only works on modern GPUs (Turing or newer)
        # Not compatible with sync mode
        powerManagement.finegrained = true;

        # Use the nvidia open source kernel module.
        open = true;

        # Enable the nvidia settings menu
        nvidiaSettings = true;

        # Select the appropriate driver
        package = config.boot.kernelPackages.nvidiaPackages.beta;
      };

      hardware.nvidia.prime = {
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";

        # Sync mode lets the system decide when to use the gpu
        #  sync.enable = true;

        # Offload lets the GPU be used when called for
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };

      systemd.services.disable-acpi-gpe6e = {
        description = "Disable storming ACPI GPE 6E";
        wantedBy = [ "multi-user.target" ];
        after = [ "sysinit.target" ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };

        script = ''
          set +e

          gpe=/sys/firmware/acpi/interrupts/gpe6E

          if [ -e "$gpe" ]; then
            echo disable > "$gpe" 2>/dev/null || true
          fi

          exit 0
        '';
      };
    };
}
