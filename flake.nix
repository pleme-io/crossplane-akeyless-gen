{
  description = "Generated Crossplane provider for Akeyless";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        packages.default = pkgs.buildGoModule {
          pname = "crossplane-akeyless";
          version = "0.1.0";
          src = self;
          vendorHash = "sha256-ftov5HtDbFGTOMQQSDn1k5jA9hTcIYfcc6azknNfJJQ=";
          subPackages = [ "cmd/provider" ];
          doCheck = false;
        };

        packages.crds = pkgs.runCommand "crossplane-akeyless-crds" {
          src = self;
        } ''
          mkdir -p $out/share/crossplane/crds
          cp $src/package/crds/*.yaml $out/share/crossplane/crds/
        '';

        checks.default = pkgs.runCommand "check-crossplane-gen" { src = self; } ''
          cd $src
          crd_count=$(find package/crds -name '*.yaml' | wc -l | tr -d ' ')
          go_count=$(find . -name '*.go' -not -path './.git/*' | wc -l | tr -d ' ')
          if [ "$crd_count" -eq 0 ]; then echo "FAIL: no CRD YAML files found"; exit 1; fi
          if [ "$go_count" -eq 0 ]; then echo "FAIL: no Go source files found"; exit 1; fi
          echo "OK: $crd_count CRD YAMLs, $go_count Go source files"
          mkdir -p $out && echo "$crd_count crds, $go_count go files" > $out/result.txt
        '';
      }
    );
}
