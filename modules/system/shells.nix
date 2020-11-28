{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.environment;
in

{
  options = {
    environment.shells = mkOption {
      type = types.listOf (types.either types.shellPackage types.path);
      default = [];
      example = literalExample "[ pkgs.bashInteractive pkgs.zsh ]";
      description = ''
        A list of permissible login shells for user accounts.
        No need to mention <literal>/bin/sh</literal>
        and other shells that are available by default on
        macOS.
      '';
      apply = map (v: if types.shellPackage.check v then "/run/current-system/sw${v.shellPath}" else v);
    };
  };

  config = mkIf (cfg.shells != []) {

    environment.etc."shells".text = ''
      # List of acceptable shells for chpass(1).
      # Ftpd will not allow users to connect who are not using
      # one of these shells.

      /bin/bash
      /bin/csh
      /bin/dash
      /bin/ksh
      /bin/sh
      /bin/tcsh
      /bin/zsh

      # List of shells managed by nix.
      ${concatStringsSep "\n" cfg.shells}
    '';

    environment.etc."shells".knownSha256Hashes = [
      "edfd1953cce18ab14449b657fcc01ece6a43a7075bab7b451f3186b885c20998"
      "9d5aa72f807091b481820d12e693093293ba33c73854909ad7b0fb192c2db193"
    ];

  };
}
