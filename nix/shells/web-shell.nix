{ pkgs, config, inputs, ... }:
{
  name = "web";

  imports = [ ./base-shell.nix ];

  enterShell = ''
    echo "🌐  Web configuration loaded."
  '';
}
