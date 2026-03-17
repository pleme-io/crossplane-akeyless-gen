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
          find $src -name '*.yaml' -exec cp {} $out/share/crossplane/crds/ \;
          # Ensure at least one file exists
          touch $out/share/crossplane/crds/.generated
        '';
      }
    );
}
