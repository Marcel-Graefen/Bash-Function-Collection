#!/usr/bin/env bash

# ========================================================================================
# Bash- Normalize List
#
#
# @author      : Marcel Gräfen
# @version     : 1.0.0
# @date        : 2025-08-18
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
  local inputs=() output_var="" extra_sep=""
  local default_sep=",| "  # Default separators: comma, pipe, space

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i|--input)
        inputs+=("$2")
        shift 2
        ;;
      -o|--output)
        output_var="$2"
        shift 2
        ;;
      -s|--separator)
        extra_sep="$2"
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done

  [[ -z "$output_var" ]] && { echo "normalize_list: --output missing" >&2; return 2; }

  # Build separator set
  local sep="$default_sep$extra_sep"
  local tmp=()

  for item in "${inputs[@]}"; do
    # Replace any separator by space
    local s="$item"
    for c in $(echo "$sep" | fold -w1); do
      s="${s//$c/ }"
    done
    # Read words into array
    for word in $s; do
      [[ -n "$word" ]] && tmp+=("$word")
    done
  done

  # Assign to output array
  local -n out="$output_var"
  out=("${tmp[@]}")
}
