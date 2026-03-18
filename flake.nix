{
  description = "Generated Crossplane CRDs for Akeyless";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        packages.default = pkgs.runCommand "crossplane-akeyless-gen" {
          src = self;
        } ''
          mkdir -p $out/share/crossplane/crds
          find $src -name '*.yaml' -not -path '*/.git/*' -exec cp {} $out/share/crossplane/crds/ \;
          touch $out/share/crossplane/crds/.generated
        '';

        checks.default = pkgs.runCommand "check-crossplane-gen" { src = self; } ''
          cd $src
          count=$(find . -name '*.yaml' -not -path './.git/*' | wc -l | tr -d ' ')
          if [ "$count" -eq 0 ]; then echo "FAIL: no YAML files found"; exit 1; fi
          echo "OK: $count YAML files found"
          mkdir -p $out && echo "$count files" > $out/result.txt
        '';
      }
    );
}
