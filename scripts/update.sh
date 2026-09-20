#!/usr/bin/env bash
set -Eeuo pipefail

TARGET=""
DRY_RUN=false
while (($#)); do
  case "$1" in
    --target=nuc) TARGET=nuc; shift ;;
    --target)
      [[ ${2:-} == nuc ]] || { echo "HIBA: csak a nuc cel tamogatott." >&2; exit 2; }
      TARGET=nuc
      shift 2
      ;;
    --dry-run) DRY_RUN=true; shift ;;
    *) echo "Ismeretlen parameter: $1" >&2; exit 2 ;;
  esac
done

if [[ "$TARGET" != "nuc" ]]; then
  echo "HIBA: ezt a repot csak --target=nuc celra szabad alkalmazni." >&2
  exit 1
fi

read -r -a K <<< "${KUBECTL:-kubectl}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

node="$(${K[@]} get node nuc -o jsonpath='{.metadata.name}' 2>/dev/null || true)"
arch="$(${K[@]} get node nuc -o jsonpath='{.status.nodeInfo.architecture}' 2>/dev/null || true)"
if [[ "$node" != "nuc" || "$arch" != "amd64" ]]; then
  echo "HIBA: a kube-context nem a nuc (amd64) clusterre mutat." >&2
  exit 1
fi

if $DRY_RUN; then
  "${K[@]}" apply --server-side --dry-run=server -f "$ROOT/k8s/headlamp.yaml" >/dev/null
  "${K[@]}" apply --server-side --dry-run=server -f "$ROOT/k8s/operator-rbac.yaml" >/dev/null
  echo "Szerveroldali dry-run sikeres; cluster-modositas nem tortent."
  exit 0
fi

"${K[@]}" apply -f "$ROOT/k8s/headlamp.yaml"
"${K[@]}" apply -f "$ROOT/k8s/operator-rbac.yaml"
"${K[@]}" rollout status deployment/headlamp -n headlamp-system --timeout=180s
echo "Ready: http://192.168.1.10:30443"
echo "Belepesi token: KUBECTL='${KUBECTL:-kubectl}' ./scripts/token.sh"
