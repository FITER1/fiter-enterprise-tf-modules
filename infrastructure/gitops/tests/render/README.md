# gitops — values render fixture

Renders the module's templated Helm values (`files/base-config.yaml` and
`files/argocd-apps.yaml.tmpl`) to static YAML **without instantiating the module**
(no `helm`/`kubernetes`/`aws` providers, no cluster, no `terraform plan` against
live state). `templatefile()` is a pure function, so a provider-less root module
with two `output`s is enough.

The inputs are a deliberate **kitchen-sink** set — every feature flag on
(`enable_argocd_notifications`, `crossplane_enabled`, `enable_ui_exec`, ALB
ingress, developer + admin users, extra projects/applications) — so every
conditional block in the templates renders. A render from the canonical
`example/main.tf` would omit keys gated behind off-by-default flags.

## Usage

```bash
./render.sh
```

Outputs:

- `rendered/argocd-values.yaml` — argo-cd chart values
- `rendered/argocd-apps-values.yaml` — argocd-apps chart values

Feed these to the `renovate-manager` skill as the "config in use" when reviewing
an `argocd_version` / `argoapps_version` bump, or pipe into
`helm template argo-cd argo-cd/argo-cd --version <ver> -f rendered/argocd-values.yaml`
to validate against the bumped chart's schema offline.

## Keeping it current

The `locals` here mirror the module's `main.tf` (`eks_helm_map`, the
dev/admin user split, the `projects` concat). If those change in `main.tf`,
update this fixture too. Re-run `./render.sh` after any template change; in CI,
regenerate and `git diff --exit-code rendered/` to catch drift.
