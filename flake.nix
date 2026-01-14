{
  description = "Switch between git worktrees with speed";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        git-worktree-switcher = pkgs.callPackage ./package.nix { };
      in
      {
        packages = {
          default = git-worktree-switcher;
          git-worktree-switcher = git-worktree-switcher;
        };

        apps = {
          default = {
            type = "app";
            program = "${git-worktree-switcher}/bin/wt";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            git
            fzf
            bashInteractive
            shellcheck
          ];

          shellHook = ''
            echo "git-worktree-switcher development environment"
            echo ""
            echo "Available commands:"
            echo "  ./wt <command>     - Run the script directly"
            echo "  shellcheck wt      - Lint the bash script"
            echo "  nix build          - Build the package"
            echo "  nix run            - Run the built package"
          '';
        };
      }
    );
}
