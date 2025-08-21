#!/usr/bin/env bash

# ========================================================================================
# Bash Resolve Paths
#
#
# @author      : Marcel Gräfen
# @version     : 1.0.0-Beta.02
# @date        : 2025-08-21
#
# @requires    : Bash 4.0+
# @requires    : realpath
# @requires    : Function   =>  Normalize List v1.X.X
# @requires    : Function   =>  check_requirements v1.X.X
#
# @see         : https://github.com/Marcel-Graefen/Bash-Function-Collection/Resolve%20Paths
#
# @copyright   : Copyright (c) 2025 Marcel Gräfen
# @license     : MIT License
# ========================================================================================

#---------------------- FUNCTION: resolve_paths --------------------------------
# Resolves given paths, normalizes them, optionally expands wildcards (*, ?),
# removes duplicates, classifies by existence, readability, and writability,
# and assigns results to named output arrays.
#
# GLOBAL VARIABLES:
#   None
#
# Programs used:
#   realpath
#
# Functions used:
#   normalize_list
#   log_msg
#
# Arguments:
#   -i|--input "path1 path2 ..."    Space-separated list of paths to resolve
#   -s|--separator "chars"          Optional separator characters for splitting input
#   -o-all VAR                      Output array with all normalized paths (before duplicate removal)
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
#   - Expands wildcards (*, ?) automatically if present in input paths
#   - Resolves absolute paths using realpath
#   - Removes duplicate paths (except for -o-all, which is mapped before deduplication)
#   - Classifies paths into existence, readability, and writability categories
#   - Maps internal arrays to user-provided global output arrays via namerefs
#   - Errors are printed with ❌ prefix

resolve_paths() {

  # NOTE: see check_requirements.sh
  # @ see https://github.com/Marcel-Graefen/Bash-Function-Collection/tree/main/Check%20Requirements

  if [[ $# -eq 0 ]]; then
    log_msg ERROR "${FUNCNAME[0]}: No parameters provided"
    return 2
  fi

  # Defaults
  # INFO sep=" " -> This value must NOT be empty, otherwise there will be an error in the function 'normalize_list'.
  # INFO Since we pass the value to the function `normalize_list` and it cannot be distinguished whether it is an empty or an unset value.
  local inputs=() sep=" " wildcard_chars="*?"
  local output_all_var="" output_exist_var="" output_missing_var=""
  local output_read_var="" output_not_read_var=""
  local output_writable_var="" output_not_writable_var=""

  # ----------------- Helper -----------------
  check_value() {
    local val="$1" name="$2"
    if [[ -z "$val" || "$val" == -* ]]; then
      log_msg ERROR "${FUNCNAME[1]}: $name requires a value"; return 2
    fi
  }

  # --------- Parse arguments ---------
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i|--input)     check_value "$2" "$1" || return 2; inputs+=("$2") ;;
      -s|--separator) check_value "$2" "$1" || return 2; sep="$2" ;;
      -o-all)         check_value "$2" "$1" || return 2; output_all_var="$2" ;;
      -o-exist)       check_value "$2" "$1" || return 2; output_exist_var="$2" ;;
      -o-missing)     check_value "$2" "$1" || return 2; output_missing_var="$2" ;;
      -o-read)        check_value "$2" "$1" || return 2; output_read_var="$2" ;;
      -o-not-read)    check_value "$2" "$1" || return 2; output_not_read_var="$2" ;;
      -o-write)       check_value "$2" "$1" || return 2; output_writable_var="$2" ;;
      -o-not-write)   check_value "$2" "$1" || return 2; output_not_writable_var="$2" ;;
      *) log_msg ERROR "${FUNCNAME[0]}: Unknown option: $1"; return 1 ;;
    esac
    shift 2
  done


  # --------- Normalize input ---------
  [[ -z "$output_all_var" && -z "$output_exist_var" && -z "$output_missing_var" && \
     -z "$output_read_var" && -z "$output_not_read_var" && -z "$output_writable_var" && \
     -z "$output_not_writable_var" ]] && { log_msg ERROR "${FUNCNAME[0]}: At least one output option is required"; return 2; }


  # --------- Normalize input ---------
  local normalized=()
  normalize_list -i "${inputs[*]}" -o normalized -s "$sep"


  # --------- Wildcard resolution ---------
  local processed=()
  shopt -s nullglob dotglob
  for p in "${normalized[@]}"; do
    if [[ "$p" == *[${wildcard_chars}]* ]]; then
      for f in $p; do
        processed+=("$(realpath -m "$f")")
      done
    else
      processed+=("$(realpath -m "$p")")
    fi
  done
  shopt -u nullglob dotglob


  # --------- Map -o-all BEFORE removing duplicates ---------
  [[ -n "$output_all_var" ]] && { local -n dest="$output_all_var"; dest=( "${processed[@]}" ); }


  # --------- Remove duplicates ---------
  local unique=() ; declare -A seen
  for f in "${processed[@]}"; do [[ -z "${seen[$f]}" ]] && { unique+=("$f"); seen[$f]=1; } ; done
  processed=("${unique[@]}")


  # --------- Classify paths ---------
  local _all=() _exist=() _missing=() _readable=() _not_readable=() _writable=() _not_writable=()
  for p in "${processed[@]}"; do
    _all+=("$p")
    if [[ -e "$p" ]]; then
      _exist+=("$p")
      [[ -r "$p" ]] && _readable+=("$p") || _not_readable+=("$p")
      [[ -w "$p" ]] && _writable+=("$p") || _not_writable+=("$p")
    else
      _missing+=("$p")
      _not_readable+=("$p")
      _not_writable+=("$p")
    fi
  done

  # --------- Map to output variables ---------
  declare -A map=([exist]=output_exist_var [missing]=output_missing_var \
                  [readable]=output_read_var [not_readable]=output_not_read_var \
                  [writable]=output_writable_var [not_writable]=output_not_writable_var)


  # --------- Map internal arrays to output variables ---------
  for name in "${!map[@]}"; do
    local var_name="${map[$name]}"
    [[ -n "${!var_name}" ]] && { local -n src="_$name"; local -n dest="${!var_name}"; dest=( "${src[@]}" ); }
  done

  return 0

}
