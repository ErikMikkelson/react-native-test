{ pkgs, config, inputs, ... }: # Receive pkgs and config as arguments

{
  dotenv.enable = true;

  # https://devenv.sh/languages/
  languages.javascript = {
    enable = true;
    package = pkgs.nodejs_18;
    corepack.enable = true;
  };

  languages.typescript = { enable = true; };

  env.LANG = "en_US.UTF-8";
  env.LANGUAGE = "en_US.UTF-8";
  env.LC_ALL = "en_US.UTF-8";

  enterShell = ''
    export PATH="./node_modules/.bin:$PATH"

    echo "🧰  Base configuration loaded."
  '';
}
