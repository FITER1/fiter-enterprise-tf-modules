#!/usr/bin/env bash
# Render the gitops module's templated Helm values to static YAML so they can be
# compared against upstream chart values (e.g. by the renovate-manager skill)
# without a terraform plan against live providers.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="${HERE}/rendered"
mkdir -p "${OUT}"

terraform -chdir="${HERE}" init -backend=false -input=false >/dev/null
terraform -chdir="${HERE}" apply -auto-approve -input=false >/dev/null

terraform -chdir="${HERE}" output -raw argocd_values >"${OUT}/argocd-values.yaml"
terraform -chdir="${HERE}" output -raw argocd_apps_values >"${OUT}/argocd-apps-values.yaml"

echo "Rendered:"
echo "  ${OUT}/argocd-values.yaml"
echo "  ${OUT}/argocd-apps-values.yaml"
