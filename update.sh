#!/bin/sh
set -eu
exec bash "$(dirname "$0")/scripts/update.sh" "$@"
