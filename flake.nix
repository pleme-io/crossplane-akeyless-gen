{
  description = "Generated Crossplane CRDs for Akeyless";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python3.withPackages (ps: [ ps.pyyaml ]);
      in {
        packages.default = pkgs.runCommand "crossplane-akeyless-gen" {
          src = self;
        } ''
          mkdir -p $out/share/crossplane/crds
          find $src -name '*.yaml' -not -path '*/.git/*' -exec cp {} $out/share/crossplane/crds/ \;
          touch $out/share/crossplane/crds/.generated
        '';

        # CRD YAML schema validation
        checks.default = pkgs.runCommand "check-crossplane-gen" {
          src = self;
          nativeBuildInputs = [ python ];
        } ''
          cd $src
          CRD_COUNT=0
          FAIL=0
          for f in $(find . -name '*.yaml' -not -path './.git/*'); do
            CRD_COUNT=$((CRD_COUNT + 1))
            if ! python3 -c "
          import yaml, sys
          try:
              docs = list(yaml.safe_load_all(open(sys.argv[1])))
              for doc in docs:
                  if doc is None:
                      continue
                  if not isinstance(doc, dict):
                      print(f'FAIL: {sys.argv[1]}: expected mapping, got {type(doc).__name__}')
                      sys.exit(1)
                  kind = doc.get('kind', '')
                  if kind == 'CustomResourceDefinition':
                      spec = doc.get('spec', {})
                      if 'group' not in spec:
                          print(f'FAIL: {sys.argv[1]}: CRD missing spec.group')
                          sys.exit(1)
                      if 'names' not in spec:
                          print(f'FAIL: {sys.argv[1]}: CRD missing spec.names')
                          sys.exit(1)
          except yaml.YAMLError as e:
              print(f'FAIL: {sys.argv[1]}: {e}')
              sys.exit(1)
          " "$f"; then
              FAIL=$((FAIL + 1))
            fi
          done
          if [ "$CRD_COUNT" -eq 0 ]; then
            echo "FAIL: no YAML files found"
            exit 1
          fi
          if [ "$FAIL" -gt 0 ]; then
            echo "FAIL: $FAIL/$CRD_COUNT YAML files have validation errors"
            exit 1
          fi
          echo "OK: $CRD_COUNT CRD files pass validation"
          mkdir -p $out
          echo "crossplane-gen: $CRD_COUNT files checked" > $out/result.txt
        '';
      }
    );
}
