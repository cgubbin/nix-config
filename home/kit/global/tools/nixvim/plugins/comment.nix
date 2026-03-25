{
  programs.nixvim.plugins.comment = {
    enable = true;
    settings = {
      ignore = "^%s*$";
    };
  };
}
