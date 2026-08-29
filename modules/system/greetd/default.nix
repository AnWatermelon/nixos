_: {
  flake.modules.nixos.greetd = _: {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "/etc/profiles/per-user/maxfh/bin/start-hyprland";
          user = "maxfh";
        };
      };
    };
  };
}
