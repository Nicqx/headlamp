#!/usr/bin/env bash
set -Eeuo pipefail
read -r -a K <<< "${KUBECTL:-kubectl}"
exec "${K[@]}" create token headlamp-operator -n headlamp-system --duration=8h
