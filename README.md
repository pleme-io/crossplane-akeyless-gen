# crossplane-akeyless-gen

Auto-generated Crossplane artifacts for the Akeyless provider.

**Do not edit manually.** This repo is populated by the [iac-forge](https://github.com/pleme-io/iac-forge) code generation pipeline from [TOML resource specifications](https://github.com/pleme-io/akeyless-terraform-resources).

## Contents

CRD YAML manifests packaged as a Nix derivation.

## Verification

Artifacts are validated by [iac-verify](https://github.com/pleme-io/akeyless-terraform-resources/tree/main/tools/iac-verify) via the aggregate repo's `nix flake check`.

```bash
iac-verify crossplane .
```

## Pipeline

```
OpenAPI spec change -> tend detects -> iac-forge sync -> pushes here
  -> GitHub Actions updates aggregate flake.lock
    -> kenshi runs nix build .#verify-all
      -> Discord notification
```

## License

[MIT](LICENSE)
