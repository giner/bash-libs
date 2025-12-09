#!/usr/bin/env bash

# read-vars.sh - Read values for specified environment variables from user input

# Copyright (c) 2025 Stanislav German-Evtushenko

read_vars_usage() {
  local script_name; script_name=$(basename "${BASH_SOURCE[0]}")
  local function_name; function_name=${FUNCNAME[1]:-}
  local command_name

  [[ "${FUNCNAME[2]:-}" == "read_vars_main" ]] && command_name="$script_name" || command_name="$function_name"

  cat <<EOF
Usage:
  $command_name -h
  eval "\$($command_name -c|--cleartext|-s|--secret VAR1 [VAR2 ...])"

Read values for specified environment variables from user input if they are not
already set or not exported and print export commands.

Options:
  -h, --help        Show this help message and exit
  -c, --cleartext   Read variables in cleartext
  -s, --secret      Read variables as secrets (input will not be echoed)

Arguments:
  VAR1, VAR2, ...   Names of the environment variables to read
EOF
}

read_vars() {
  local vars=()
  local opt_secret

  if [[ $# -eq 0 ]]; then
    read_vars_usage >&2
    echo
    echo "ERROR: No arguments provided" >&2
    return 1
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help) read_vars_usage; return 0 ;;
      -c|--cleartext) opt_secret=false; shift ;;
      -s|--secret) opt_secret=true; shift ;;
      -*) read_vars_usage >&2; echo; echo "Unknown option: $1" >&2; return 1 ;;
      *) vars+=("$1"); shift ;;
    esac
  done

  if [[ -z "${opt_secret:-}" ]]; then
    read_vars_usage >&2
    echo
    echo "ERROR: Must specify either -c/--cleartext or -s/--secret" >&2
    return 1
  fi

  if [[ ${#vars[@]} -eq 0 ]]; then
    read_vars_usage >&2
    echo
    echo "ERROR: Must specify at least one variable name" >&2
    return 1
  fi

  local read_opts=()
  [[ $opt_secret == true ]] && read_opts=(-s) || read_opts=()

  local exports=()
  local var value

  for var in "${vars[@]}"; do
    if [[ -z "${!var+empty}" || ! $(declare -p "$var") =~ ^declare\ -[^\ ]*x[^\ ]* ]]; then
      read -rp "$var: " "${read_opts[@]+"${read_opts[@]}"}" value
      if [[ $opt_secret == true ]]; then echo >&2; fi
      exports+=("$var=$(printf '%q' "$value")")
    fi
  done

  local kv

  for kv in "${exports[@]+"${exports[@]}"}"; do
    echo "export $kv"
  done
}

read_vars_main() {
  local executed

  [[ ${BASH_SOURCE[0]} == "$0" ]] && executed=true || executed=false

  if $executed; then
    set -euo pipefail
    read_vars "$@"
  fi
}

read_vars_main "$@"
