{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-ruby.url = "github:bobvanderlinden/nixpkgs-ruby";
    devenv.url = "github:cachix/devenv";
    android.url = "github:tadfisher/android-nixpkgs";
  };

  nixConfig = {
    extra-substituters = [
      "https://nixpkgs.cachix.org"
      "https://nixpkgs-ruby.cachix.org"
      "https://devenv.cachix.org"
      "https://android-nixpkgs.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
      "nixpkgs-ruby.cachix.org-1:vrcdi50fTolOxWCZZkw0jakOnUI1T19oYJ+PRYdK4SM="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "android-nixpkgs.cachix.org-1:2lZoPmwoyTVGaNDHqa6A32tdn8Gc0aMWBRrfXN1H3dQ="
    ];
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];

      imports = [ inputs.devenv.flakeModule ];

      perSystem = { config, self', inputs', pkgs, system, lib, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ inputs.nixpkgs-ruby.overlays.default ];
        };

        devenv.shells.mobile = import ./shells/mobile-shell.nix;
        devenv.shells.web = import ./shells/web-shell.nix;
    };
  };
}
