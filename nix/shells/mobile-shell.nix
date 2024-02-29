{ pkgs, config, inputs, ... }: # Receive pkgs and config as arguments

let
  android-sdk = (import inputs.android { }).sdk (sdkPkgs:
    with sdkPkgs; [
      platforms-android-34
      build-tools-34-0-0

      platform-tools
      cmdline-tools-latest
      ndk-23-1-7779620
      cmake-3-18-1

      emulator
      system-images-android-34-google-apis-playstore-arm64-v8a
    ]);
in {
  name = "mobile";

  imports = [ ./base-shell.nix ];

  packages = [
    pkgs.watchman
  ];

  languages.java = {
    enable = true;
    jdk.package = pkgs.zulu17;
  };

  languages.ruby = {
    enable = true;
    # package = pkgs."ruby-3.1.3";  # We could do this, but it forces us to build ruby
    package = pkgs.ruby_3_1; # Whereas this will use the prebuilt package
  };

  enterShell = ''
    export PATH="${android-sdk}/bin:$PATH"
    export ANDROID_HOME="${android-sdk}/share/android-sdk"
    export ANDROID_SDK_ROOT="${android-sdk}/share/android-sdk"
    export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$PATH"
    ${(builtins.readFile "${android-sdk}/nix-support/setup-hook")}

    echo "📱  Mobile configuration loaded."
  '';
}
