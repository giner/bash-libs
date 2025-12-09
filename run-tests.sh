#!/usr/bin/env bash

cd "$(dirname "$0")"
echo "BASH_VERSION: $BASH_VERSION" >&2
bats .
