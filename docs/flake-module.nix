{
  perSystem = { config, self', inputs', pkgs, lib, system, ... }: {
    devshells.default = {
      commands = [
        { package = pkgs.nodejs_21; category = "docs"; }
        { package = pkgs.markdownlint-cli; category = "docs"; }
      ];
    };

    # https://github.com/cachix/pre-commit-hooks.nix/tree/master
    pre-commit = {
      settings = {
        hooks = {
          markdownlint = {
            enable = true;
          };
        };
        # https://github.com/DavidAnson/markdownlint/blob/main/schema/.markdownlint.jsonc
        settings.markdownlint.config = {
          # MD013/line-length : Line length : https://github.com/DavidAnson/markdownlint/blob/v0.32.1/doc/md013.md
          "MD013" = {
            "line_length" = 120;
            "code_block_line_length" = 120;
            "tables" = false;
          };

          # MD024/no-duplicate-heading : Multiple headings with the same content : https://github.com/DavidAnson/markdownlint/blob/v0.32.1/doc/md024.md
          "MD024" = {
            # we have multiple Bugfixes/Upgrading headings in the CHANGELOG for consistency.
            "siblings_only" = true;
          };
        };
      };
    };

    packages.docs = pkgs.buildNpmPackage {
      pname = "docs";
      version = "0.1.0";

      src =
        pkgs.nix-gitignore.gitignoreSource [
          ".vscode"
          "README.md"
          ".gitignore"
          "nix"
          "flake.*"
        ]
          ./.;

      buildInputs = [
        pkgs.vips
      ];

      nativeBuildInputs = [
        pkgs.pkg-config
      ];

      installPhase = ''
        runHook preInstall
        cp -pr --reflink=auto dist $out/
        runHook postInstall
      '';

      npmDepsHash = "sha256-5PLfsxFmN20+/BMYWP9hK5Aw0qV9XiG/Rky8BlF80J0=";
    };
  };
}