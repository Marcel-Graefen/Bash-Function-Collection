#!/usr/bin/env bash

# ========================================================================================
# Bash- Normalize List
#
#
# @author      : Marcel Gräfen
# @version     : 1.1.0
# @date        : 2025-08-20
#
# @requires    : Bash 4.0+
#
# @see         : https://github.com/Marcel-Graefen/Bash-Function-Collection/Normalize%20List
#
# @copyright   : Copyright (c) 2025 Marcel Gräfen
# @license     : MIT License
# ========================================================================================

#---------------------- FUNCTION: normalize_list -----------------------------------
# Splits input strings into an array based on a custom separator.
#
# GLOBAL VARIABLES:
#   None
#
# Uses Functions:
#   None
#
# Arguments:
#   -i|--input STRING     Input string to normalize; can be given multiple times
#   -o|--output VAR       Name of the array variable to store the result
#   -s|--separator   Additional separators to add to default ones (optional)
#
# Returns:
#   0 on success
#   2 on error
#
# Behavior:
#   - Uses default separators: space, |, ,
#   - Additional separators can be provided via -s
#   - Splits input strings based on all separators and outputs into array
#   - Output is only through the named array specified with -o|--output
#

normalize_list() {

  # Fail if no arguments provided
  [[ $# -eq 0 ]] && { echo "❌ ERROR: normalize_list: No arguments provided"; return 2; }

  local inputs=() output_var="" extra_sep="" default_sep=",| "

  # Helper functions
  check_value() { [[ -z "$1" || "$1" == -* ]] && { echo "❌ ERROR: normalize_list: '$2' requires a value"; return 2; }; }

  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i|--input)     check_value "$2" "$1" || return 2; inputs+=("$2"); shift 2  ;;
      -o|--output)    check_value "$2" "$1" || return 2; output_var="$2"; shift 2 ;;
      -s|--separator) check_value "$2" "$1" || return 2; extra_sep="$2"; shift 2  ;;
      *) echo "❌ ERROR: normalize_list: Unknown option: $1"; return 2            ;;
    esac
  done

  [[ -z "$output_var" ]] && { echo "❌ ERROR: normalize_list: --output missing" >&2; return 2; }

  local sep="${default_sep}${extra_sep}" tmp=()
  for item in "${inputs[@]}"; do
    # Replace separators with space and split into array
    IFS=' ' read -r -a words <<< "${item//[$sep]/ }"
    tmp+=("${words[@]}")
  done

  # Assign to output array
  local -n out="$output_var"
  out=("${tmp[@]}")

  return 0

}
