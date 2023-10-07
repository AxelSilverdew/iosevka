{
  description = "Axel's Custom Iosevka fonts";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
  }:
    utils.lib.eachSystem ["x86_64-linux"] (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        packages.default = pkgs.stdenvNoCC.mkDerivation {
          name = "iosevka-ax";
          dontUnpack = true;
          buildInputs = with pkgs; [python311Packages.brotli python311Packages.fonttools];
          buildPhase = let
            metric-override = {
              cap = 790;
              ascender = 790;
              xHeight = 570;
            };
            iosevka-curly = pkgs.iosevka.override {
              set = "curly";
              privateBuildPlan = {
                family = "Iosevka Curly Ax";
                spacing = "term";
                serifs = "sans";
                no-ligation = false;
                ligations = {"inherit" = "default-calt";};
                no-cv-ss = true;
                variants = {
                  inherits = "ss04";
                  design = {
                    tilde = "low";
                    number-sign = "slanted-tall";
                    at = "fourfold-tall";
                  };
                };
                slopes.upright = {
                  angle = 0;
                  shape = "upright";
                  menu = "upright";
                  css = "normal";
                };
                weights.regular = {
                  menu = 400;
                  shape = 400;
                  css = 400;
                };
                widths.normal = {
                  shape = 500;
                  menu = 7;
                  css = "normal";
                };
                inherit metric-override;
              };
            };
            iosevka-aile = pkgs.iosevka.override {
              set = "aile";
              privateBuildPlan = {
                family = "Iosevka Aile Ax";
                spacing = "quasi-proportional";
                no-ligation = true;
                no-cv-ss = true;
                variants = {
                  inherits = "ss04";
                  design = {
                    tilde = "low";
                    number-sign = "slanted-tall";
                    at = "fourfold-tall";
                  };
                };
                slopes = {
                  upright = {
                    angle = 0;
                    shape = "upright";
                    menu = "upright";
                    css = "normal";
                  };
                  italic = {
                    angle = 9.4;
                    shape = "italic";
                    menu = "italic";
                    css = "italic";
                  };
                };
                weights.regular = {
                  shape = 400;
                  menu = 400;
                  css = 400;
                };
                inherit metric-override;
              };
            };
            iosevka-etoile = pkgs.iosevka.override {
              set = "etoile";
              privateBuildPlan = {
                family = "Iosevka Etoile Ax";
                spacing = "quasi-proportional";
                serifs = "slab";
                no-ligation = true;
                no-cv-ss = true;
                variants = {
                  inherits = "ss04";
                  design = {
                    capital-t = "serifed";
                    capital-w = "straight-flat-top-serifed";
                    f = "flat-hook-serifed";
                    i = "serifed";
                    j = "flat-hook-serifed";
                    r = "serifed";
                    t = "flat-hook";
                    w = "straight-flat-top-serifed";

                    tilde = "low";
                    number-sign = "slanted-tall";
                    at = "fourfold-tall";
                  };
                  italic = {f = "flat-hook-tailed";};
                };
                slopes = {
                  upright = {
                    angle = 0;
                    shape = "upright";
                    menu = "upright";
                    css = "normal";
                  };
                  italic = {
                    angle = 9.4;
                    shape = "italic";
                    menu = "italic";
                    css = "italic";
                  };
                };
                weights.regular = {
                  shape = 400;
                  menu = 400;
                  css = 400;
                };
                inherit metric-override;
              };
            };
          in ''
            mkdir -p ttf
            for ttf in ${iosevka-curly}/share/fonts/truetype/*.ttf ${iosevka-aile}/share/fonts/truetype/*.ttf ${iosevka-etoile}/share/fonts/truetype/*.ttf; do
              cp $ttf .

              echo "building $ttf"

              name=`basename -s .ttf $ttf`
              pyftsubset \
                $ttf \
                --output-file="$name".woff2 \
                --flavor=woff2 \
                --layout-features=* \
                --no-hinting \
                --desubroutinize \
                --unicodes="U+0000-0170,U+00D7,U+00F7,U+2000-206F,U+2074,U+20AC,U+2122,U+2190-21BB,U+2212,U+2215,U+F8FF,U+FEFF,U+FFFD,U+00E8"
              mv *.ttf ttf
            done

            ${pkgs.zip}/bin/zip ttf.zip ttf/*.ttf
          '';

          installPhase = ''
            mkdir -p $out
            cp *.woff2 $out
            cp ttf.zip $out

            cp ${src/iosevka-ax.css} $out/iosevka-ax.css
          '';
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [pkgs.python3];
        };
      }
    );
}
