#!/usr/bin/env bash

# ========================================================================================
# Bash- Display Table
#
#
# @author      : Marcel Gräfen
# @version     : 1.0.1
# @date        : 2025-08-18
#
# @requires    : Bash 4.0+
# @requires    : Function   =>  Normalize List v1.X.X
#
# @see         : https://github.com/Marcel-Graefen/Bash-Function-Collection/Display%20Table
#
# @copyright   : Copyright (c) 2025 Marcel Gräfen
# @license     : MIT License
# ========================================================================================


#---------------------- FUNCTION: display_table -----------------------------------
# Displays a formatted table in the terminal
#
# GLOBAL VARIABLES:
#   None
#
# Uses Functions:
#   normalize_list v1.X.X
#
# Arguments:
#   --header | -H    Optional: Table header
#   --value  | -v    Value strings (multiple allowed)
#   --separator | -s Optional: Separator characters for splitting values
#
# Returns:
#   0 on success
#   2 on error
#
# Behavior:
#   - Normalizes each value string into an array using normalize_list
#   - Calculates column widths dynamically
#   - Prints a border, header row, and all rows in a table format
#

display_table() {

  # Required functions
  local required_funcs=(normalize_list)
  for f in "${required_funcs[@]}"; do
    declare -F "$f" >/dev/null 2>&1 || { echo "❌ ERROR: ${FUNCNAME[0]}: '$f' not found. Aborting."; return 2; }
  done

  local header="" separator="" args=() rows=()

  # Parse input arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -H|--header) header="$2"; shift 2 ;;
      -v|--value) args+=("$2"); shift 2 ;;
      -s|--separator) separator="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  # Normalize each input line into an array
  local row_array
  for val in "${args[@]}"; do
    normalize_list -i "$val" -s "$separator" -o row_array
    # Store as | separated string for consistent column processing
    rows+=("$(printf "%s|" "${row_array[@]}")")
  done

  # Calculate column widths
  local max_cols=0 widths=()
  for r in "${rows[@]}"; do
    IFS='|' read -r -a cols <<< "$r"
    (( ${#cols[@]} > max_cols )) && max_cols=${#cols[@]}
  done

  for ((i=0;i<max_cols;i++)); do widths[i]=0; done
  for r in "${rows[@]}"; do
    IFS='|' read -r -a cols <<< "$r"
    for ((i=0;i<${#cols[@]};i++)); do
      (( ${#cols[i]} > widths[i] )) && widths[i]=${#cols[i]}
    done
  done

  # Build border line
  local line="+"
  for w in "${widths[@]}"; do
    line+=$(printf '%*s' $((w+2)) '' | tr ' ' '-')"+"
  done

  # Print header centered
  echo "$line"
  if [[ -n "$header" ]]; then
    local total_width=0
    for w in "${widths[@]}"; do ((total_width+=w+2)); done
    total_width=$((total_width + max_cols -1))
    local padding_left=$(( (total_width - ${#header}) / 2 ))
    local padding_right=$((total_width - ${#header} - padding_left))
    printf "|%*s%s%*s|\n" $padding_left "" "$header" $padding_right ""
    echo "$line"
  fi

  # Print all rows
  for r in "${rows[@]}"; do
    IFS='|' read -r -a cols <<< "$r"
    local fmt="|"
    for ((i=0;i<max_cols;i++)); do
      local val="${cols[i]:-}"
      fmt+=" %-$((${widths[i]}))s |"
    done
    printf "$fmt\n" "${cols[@]}"
    echo "$line"
  done

  return 0

}
