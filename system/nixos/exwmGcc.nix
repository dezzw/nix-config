{ config, lib, pkgs, ...}:

with lib;

let

  cfg = config.services.xserver.windowManager.myExwm;
  loadScript = pkgs.writeText "emacs-exwm-load" ''
    ${cfg.loadScript}
    ${optionalString cfg.enableDefaultConfig ''
      (require 'exwm-config)
      (exwm-config-default)
    ''}
  '';

  myEmacs = pkgs.emacsGcc;

  services.emacs.enable = true;
in {

 # programs.emacs = {
 #   enable = true;
 #   package = myEmacs;
 # };

  options = {
    services.xserver.windowManager.myExwm = {
      enable = mkEnableOption "exwm";
      loadScript = mkOption {
        default = "(require 'exwm)";
        type = types.lines;
        example = ''
          (require 'exwm)
          (exwm-enable)
        '';
        description = ''
          Emacs lisp code to be run after loading the user's init
          file. If enableDefaultConfig is true, this will be run
          before loading the default config.
        '';
      };
      enableDefaultConfig = mkOption {
        default = true;
        type = lib.types.bool;
        description = "Enable an uncustomised exwm configuration.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.xserver.windowManager.session = singleton {
      name = "emacsWM";
      start = ''
        ${myEmacs}/bin/emacs -l ${loadScript}
      '';
    };
    environment.systemPackages = [ myEmacs ];
  };

}
