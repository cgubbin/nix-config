{ ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "none";
      # this sucks, as the entire homebrew does. gah
      autoUpdate = true;
      upgrade = true;
    };
    global.autoUpdate = true;
    caskArgs.no_quarantine = true;
    brews = [
      "hdf5"
      "gnuplot"
    ];
    casks = [
      # "1password"
      # "aerospace"
      "alfred"
      # "amethyst"
      # "caffeine"
      # "arc"
      # "drawio"
      # "elgato-wave-link"
      # "firefox"
      # "ghostty"
      # "google-chrome"
      # "hiddenbar"
      # "karabiner-elements"
      # "keymapp"
      # "mactex-no-gui"
      # "obs"
      # "obsidian"
      # "pdf-expert"
      # "protonvpn"
      # "sf-symbols"
      # "vlc"
      # "zed"
      # "zoom"
      # "zotero"
      # "the-unarchiver"
    ];
  };
}
