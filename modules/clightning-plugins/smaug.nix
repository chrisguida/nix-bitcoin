{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.clightning.plugins.smaug;
  secretsDir = config.nix-bitcoin.secretsDir;
in
{
  options.services.clightning.plugins.smaug = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc ''
        Whether to enable Smaug (CLN plugin).
        See also: https://github.com/chrisguida/smaug#running
      '';
    };

    package = mkOption {
      type = types.package;
      default = config.nix-bitcoin.pkgs.smaug;
      defaultText = "config.nix-bitcoin.pkgs.smaug";
      description = mdDoc "The package providing smaug binaries.";
    };
  };

  config = mkIf cfg.enable {
    services.clightning.extraConfig = ''
      plugin=${cfg.package}/bin/smaug
      smaug_brpc_user=privileged
      smaug_brpc_pass=$(cat ${secretsDir}/bitcoin-rpcpassword-privileged)
    '';
  };
}
