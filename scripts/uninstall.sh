#!/usr/bin/env bash
set -Eeuo pipefail
read -r -a K <<< "${KUBECTL:-kubectl}"
"${K[@]}" delete clusterrolebinding headlamp-operator-view headlamp-operator-pod-delete --ignore-not-found
"${K[@]}" delete clusterrole headlamp-pod-operator --ignore-not-found
"${K[@]}" delete namespace headlamp-system --ignore-not-found
echo "Headlamp es a hozza tartozo RBAC eltavolitva. Alkalmazasadat nem toroltunk."
