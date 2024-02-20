{ inputs, pkgs, ... }:

let
  # Configure which Android tools we'll need (mostly the recommended ones)
  sdk = (import inputs.android-nixpkgs { }).sdk (sdkPkgs:
    with sdkPkgs; [
      build-tools-30-0-3
      build-tools-33-0-1
      build-tools-34-0-0
      cmdline-tools-latest
      emulator
      platform-tools
      platforms-android-33
      platforms-android-34
      system-images-android-32-google-apis-x86-64
    ]);
in {
  # https://devenv.sh/packages/
  packages = with pkgs; [
    watchman
  ];

    # # https://devenv.sh/scripts/
  scripts.motd.exec = "echo Welcome to Thrivent Web!";

  # https://devenv.sh/languages/
  languages.javascript = {
    enable = true;
    package = pkgs.nodejs_18;
    corepack.enable = true;
  };

  languages.typescript = {
    enable = true;
  };

  languages.java = {
    enable = true;
    gradle.enable = true;
  };

  languages.ruby = {
    enable = true;
    package = pkgs.ruby_3_1;
  };

  env.LANG="en_US.UTF-8";
  env.LANGUAGE="en_US.UTF-8";
  env.LC_ALL="en_US.UTF-8";

  # Ensure our path has various Android SDK things in it
  enterShell = ''
    motd
    export PATH="${sdk}/bin:$PATH"
    export PATH="./node_modules/.bin:$PATH"

    ${(builtins.readFile "${sdk}/nix-support/setup-hook")}
  '';

  # See full reference at https://devenv.sh/reference/options/
}
