{
  description = "A presentation built with Pandoc and revealjs";

  inputs = {
      nixpkgs.url = "nixpkgs";
  };
  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.default = (
        let
            pkgs = nixpkgs.legacyPackages."x86_64-linux";
        in
          pkgs.stdenv.mkDerivation {
              name = "Nix-presentation";
              src = ./.;
              buildInputs = [
                  pkgs.pandoc
                  pkgs.texlive.combined.scheme-small
                ];
              dontInstall = true;
              buildPhase = ''
              mkdir -p $out
                pandoc $src/README.md \
                  -t revealjs \
                  -s \
                  -M date="`date "+%B %e, %Y"`" \
                  -o $out/presentation.html
              '';
          }
        );
  };
}
