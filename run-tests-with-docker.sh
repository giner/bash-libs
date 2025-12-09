#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

for bash_version in 3 4 5 latest; do
  docker run --rm -it -v .:/source "bash:$bash_version" sh -c 'apk add bats && /source/run-tests.sh'
done
