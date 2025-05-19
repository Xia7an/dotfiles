# sway.nix
{ pkgs, ... }:

{
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    config = rec {
      modifier = "Mod4";
      terminal = "kitty";
    };
    input."*".xkb_layout = "jp";
    input."*".xkb_model= "jp106";
  }
}
