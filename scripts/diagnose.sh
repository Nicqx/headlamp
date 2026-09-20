#!/usr/bin/env bash
set -Eeuo pipefail
read -r -a K <<< "${KUBECTL:-kubectl}"
"${K[@]}" get deployment,pod,service -n headlamp-system -o wide
"${K[@]}" auth can-i --as=system:serviceaccount:headlamp-system:headlamp-operator list pods --all-namespaces
"${K[@]}" auth can-i --as=system:serviceaccount:headlamp-system:headlamp-operator delete pods --all-namespaces
"${K[@]}" auth can-i --as=system:serviceaccount:headlamp-system:headlamp-operator delete deployments --all-namespaces
