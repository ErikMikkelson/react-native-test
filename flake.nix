{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    android-nixpkgs.url = "github:tadfisher/android-nixpkgs/stable";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = { self, nixpkgs, devenv, systems, ... } @ inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      packages = forEachSystem (system: {
        devenv-up = self.devShells.${system}.default.config.procfileScript;
      });

      devShells = forEachSystem
        (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};

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
          in
          {
            default = devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [
                {
                    # # https://devenv.sh/scripts/
                  scripts.motd.exec = "echo Welcome to react-native-test!";

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
                    gradle.package = pkgs.gradle_8;
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
              ];
            };
          });
    };
}
