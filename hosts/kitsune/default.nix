# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./sops.nix
    ../common/optional/fingerprint-scanner.nix
    ../common/optional/hyprland.nix
    ../common/optional/niri.nix
    ../common/optional/services.nix
    ../common/optional/stylix.nix
    ../common/optional/tlp.nix
    # ../common/users/kit
    ../common/global
  ];

  boot.loader.systemd-boot.enable = true;
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
  users.users.kit = {
    isNormalUser = true;
    description = "Christopher Gubbin";
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.fish;
    hashedPasswordFile = config.sops.secrets.kitsune_passwd.path;
  };

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  # services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb = {
  #   layout = "us";
  #   variant = "colemak_dh_ortho";
  # };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "kit";

  programs.fish.enable = true;

  programs.steam = {
    enable = true;
    extraCompatPackages = [pkgs.proton-ge-bin];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    lshw
  ];

  environment.sessionVariables = {
    WLR_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0";
  };

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
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
}
