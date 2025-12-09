#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

echo "BASH_VERSION: $BASH_VERSION" >&2
bats .
