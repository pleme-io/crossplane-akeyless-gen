# crossplane-akeyless-gen

Auto-generated Crossplane provider for Akeyless.

**Do not edit manually.** This repo is populated by the [iac-forge](https://github.com/pleme-io/iac-forge) code generation pipeline (`crossplane-forge` backend) from [TOML resource specifications](https://github.com/pleme-io/akeyless-terraform-resources), driven by the [akeyless-go](https://github.com/pleme-io/akeyless-go) SDK's OpenAPI spec.

## Contents

A real, buildable Crossplane provider — 156 resources + 26 gateway actions, 182 total controllers:

- `apis/<kind>/v1alpha1/` — typed Kubernetes CRD Go types + `zz_generated_*` deepcopy/managed-resource boilerplate, one package per resource
- `internal/controller/<kind>/` — the `crossplane-runtime` `ExternalClient` (Observe/Create/Update/Delete) reconciler for each resource
- `internal/controller/setup.go` — wires every controller into the manager
- `package/crds/*.yaml` — the CRD manifests
- `cmd/provider/main.go` — the provider-manager entrypoint
- `helm/` — a Helm chart for deploying the provider

## Verification

Every commit is verified end-to-end, not just counted:

```bash
nix build .#default   # buildGoModule -- produces a real runnable provider binary
nix flake check        # CRD + Go-source presence check
```

The generator itself (`crossplane-forge`) ships its own resource-shape
catalog for the handful of Akeyless endpoints whose request bodies
don't follow the default `Name`-identified pattern (singleton
gateway-config resources, `_v2` API variants). A generation whose
output doesn't `go build ./...` cleanly is a generator bug, not a
publishable state -- see `crossplane-forge`'s `controller_gen.rs` for
the resource-shape overrides this provider's generation depends on.

## Pipeline

```
OpenAPI spec change -> tend detects -> iac-forge sync -> pushes here
  -> GitHub Actions updates aggregate flake.lock
    -> kenshi runs nix build .#verify-all
      -> Discord notification
```

## License

[MIT](LICENSE)
