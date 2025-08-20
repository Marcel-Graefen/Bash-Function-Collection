#!/usr/bin/env bash

# ========================================================================================
# Bash Resolve Paths
#
#
# @author      : Marcel Gräfen
# @version     : 1.0.0
# @date        : 2025-08-20
#
# @requires    : Bash 4.0+
# @requires    : realpath
# @requires    : Function   =>  Normalize List v1.0.0
# @requires    : Function   =>  check_requirements v1.0.0
#
# @see         : https://github.com/Marcel-Graefen/Bash-Function-Collection/Resolve%20Paths
#
# @copyright   : Copyright (c) 2025 Marcel Gräfen
# @license     : MIT License
# ========================================================================================


#---------------------- FUNCTION: resolve_paths --------------------------------
# Resolves given paths, classifies them by existence, readability, and writability,
# and optionally assigns results to named output arrays.
#
# GLOBAL VARIABLES:
#   None
#
# Uses Programms:
#   realpath
#
# Uses Functions:
#   normalize_list
#   log_msg
#   check_requirements
#
# Arguments:
#   -i|--input "path1 path2 ..."    Space-separated list of paths to resolve
#   -s|--separator "chars"          Optional additional separators for input splitting
#   -o-all VAR                      Output array with all normalized paths
#   -o-exist VAR                    Output array with paths that exist
#   -o-missing VAR                  Output array with paths that do not exist
#   -o-read VAR                     Output array with readable paths
#   -o-not-read VAR                 Output array with not-readable paths
#   -o-write VAR                    Output array with writable paths
#   -o-not-write VAR                Output array with not-writable paths
#
# Returns:
#   0 on success
#   2 on error (e.g., missing input, unknown option, or missing -o-* output array)
#
# Behavior:
#   - Validates input arguments
#   - Normalizes all provided paths using normalize_list
#   - Resolves absolute paths using realpath
#   - Classifies paths into existence, readability, and writability categories
#   - Maps internal arrays to user-provided global output arrays via namerefs
#   - Errors are printed with ❌ prefix

resolve_paths() {

  # NOTE: see check_requirements.sh
  # @ see https://github.com/Marcel-Graefen/Bash-Function-Collection/tree/main/Check%20Requirements

  # No parameters provided?
  if [[ $# -eq 0 ]]; then
    log_msg ERROR "No parameters provided"
    return 2
  fi

  local inputs=() sep=""
  local output_all_var="" output_exist_var="" output_missing_var=""
  local output_read_var="" output_not_read_var=""
  local output_write_var="" output_not_write_var=""

  # Helper function to check if a value was provided for an option
  check_value() {
    local val="$1"
    local name="$2"
    if [[ -z "$val" || "$val" == -* ]]; then
      log_msg ERROR resolve_paths: "$name requires a value"
      return 2
    fi
  }

  # 1) Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i|--input)      check_value "$2" "$1" || return 2; inputs+=("$2")            ;;
      -s|--separator)  check_value "$2" "$1" || return 2; sep="$2"                  ;;
      -o-all)          check_value "$2" "$1" || return 2; output_all_var="$2"       ;;
      -o-exist)        check_value "$2" "$1" || return 2; output_exist_var="$2"     ;;
      -o-missing)      check_value "$2" "$1" || return 2; output_missing_var="$2"   ;;
      -o-read)         check_value "$2" "$1" || return 2; output_read_var="$2"      ;;
      -o-not-read)     check_value "$2" "$1" || return 2; output_not_read_var="$2"  ;;
      -o-write)        check_value "$2" "$1" || return 2; output_write_var="$2"     ;;
      -o-not-write)    check_value "$2" "$1" || return 2; output_not_write_var="$2" ;;
      *)               log_msg ERROR "Unknown option: $1"; return 1                  ;;
    esac

    shift 2
  done

  # Ensure at least one output option is provided
  if [[ -z "$output_all_var"    && -z "$output_exist_var"  && \
        -z "$output_missing_var"&& -z "$output_read_var"   && \
        -z "$output_not_read_var"&& -z "$output_write_var"  && \
        -z "$output_not_writable_var" ]]; then
    log_msg ERROR "resolve_paths: At least one of \"-o-all, -o-exist, -o-missing, -o-read, -o-not-read, -o-write or -o-not-write\" is required"
    return 2
  fi

  # 2) Normalize input paths
  local normalized=()
  normalize_list -i "${inputs[*]}" -o normalized -s "$sep"

  # 3) Classify paths
  local _all=() _exist=() _missing=()
  local _readable=() _not_readable=()
  local _writable=() _not_writable=()

  for p in "${normalized[@]}"; do
    local abs
    abs=$(realpath -m "$p" 2>/dev/null)
    _all+=("$abs")

    if [[ -e "$abs" ]]; then
      _exist+=("$abs")
      [[ -r "$abs" ]] && _readable+=("$abs") || _not_readable+=("$abs")
      [[ -w "$abs" ]] && _writable+=("$abs") || _not_writable+=("$abs")
    else
      _missing+=("$abs")
    fi
  done

  # 4) Map internal arrays to global output arrays
  declare -A map=(
    [all]=output_all_var
    [exist]=output_exist_var
    [missing]=output_missing_var
    [readable]=output_read_var
    [not_readable]=output_not_read_var
    [writable]=output_write_var
    [not_writable]=output_not_write_var
  )

  for name in "${!map[@]}"; do
    local var_name="${map[$name]}"
    [[ -z "${!var_name}" ]] && continue

    # Nameref: source -> internal array, dest -> global output variable
    local -n src="_$name"
    local -n dest="${!var_name}"
    dest=( "${src[@]}" )
  done

  return 0
}
