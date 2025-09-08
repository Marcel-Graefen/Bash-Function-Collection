#!/usr/bin/env bash

# ========================================================================================
# Bash Parse Case Flags
#
#
# @author      : Marcel Gräfen
# @version     : 1.0.0-beta.01
# @date        : 2025-09-08
#
# @requires    : Bash 4.3+
#
# @see         : https://github.com/Marcel-Graefen/Bash-Function-Collection/
#
# @copyright   : Copyright (c) 2025 Marcel Gräfen
# @license     : MIT License
# ========================================================================================

#---------------------- FUNCTION: parse_case_flags --------------------------------
#
# @version 1.0.0-beta.01
#
# Parses, validates, and assigns values from command-line flags within a case block.
#
# Features:
#   - Supports single values, arrays, and toggle flags
#   - Validates values as numbers or letters only
#   - Rejects specified characters or complete forbidden values (supports wildcards *)
#   - Deduplicates array elements when requested
#   - Collects invalid values into a dropping array if specified
#   - Dynamically assigns values to provided variable names (using nameref)
#   - Preserves unprocessed arguments for subsequent flag handling
#   - Handles multi-value parameters and multiple flag occurrences
#
# GLOBAL VARIABLES:
#   None
#
# External programs used:
#   None
#
# Internal functions used:
#   check_chars - validates allowed/forbidden characters per value
#
# Arguments (OPTIONS):
#   <flag>                         The command-line flag to parse (e.g., --name)
#   <target_variable>              Name of the variable to assign the value(s) to
#   --array                        Treat values as an array (collect multiple arguments)
#   --number                       Only allow numeric values
#   --letters                      Only allow alphabetic characters
#   --toggle                        Flag with no value, sets target variable to true
#   --forbid <chars>               Disallow these characters in values
#   --allow <chars>                Allow only these characters in values
#   --forbid-full <value1> [...]   Disallow specific full values (supports wildcards *)
#   --dropping <array_name>        Collect invalid values into this array
#   --deduplicate <array_name>     Collect duplicate values into this array
#   -i "$@" / --input "$@"         Pass all remaining CLI arguments for internal processing
#
# Requirements:
#   Bash version >= 4.3 (for declare -n nameref support)
#
# Returns:
#   0  on success
#   1  if required values are missing or invalid
#
# Notes:
#   - Designed to be used inside a case block to process CLI flags sequentially
#   - Arrays, toggles, deduplication, and dropping are handled internally
#   - Must always be called with "$@" after -i/--input to ensure unprocessed arguments are preserved
#   - Works with multi-value flags and multiple occurrences of the same flag


parse_case_flags() {

  # --------- Defaults -----------------
  local type="single"           # Default flag type: single
  local verbose=false           # Show error messages if true
  local allow_numbers=false     # Only numbers allowed
  local allow_letters=false     # Only letters allowed
  local toggle=false            # Toggle flag
  local name=""                 # Flag name for error messages
  local forbid_chars=""         # Characters that are forbidden
  local allow_chars=""          # Characters that are allowed
  local return_var=""           # Name of variable to return value(s)
  local dropping=""             # Name of variable to store dropped (invalid) values
  local deduplicate=""          # Name of variable to store deduplicated values
  local forbid_full=()          # Full forbidden values

  # --------- Parse arguments ---------
  local end_of_options=false
  while [[ $# -gt 0 ]]; do
    if [[ "$end_of_options" == false ]]; then
      case "$1" in
        -n|--name) shift; name="$1"; shift ;;                   # Name for error messages
        -y|--array) type="array"; shift ;;                       # Treat value as array
        -v|--verbose) verbose=true; shift ;;                     # Enable verbose output
        -c|--number) allow_numbers=true; shift ;;                # Only numeric values allowed
        -l|--letters) allow_letters=true; shift ;;               # Only letters allowed
        -t|--toggle) toggle=true; shift ;;                       # Set toggle true
        -f|--forbid) shift; forbid_chars="$1"; shift ;;          # Forbidden characters
        -a|--allow) shift; allow_chars="$1"; shift ;;            # Allowed characters
        -r|--return|-o|--output) shift; return_var="$1"; shift ;; # Return variable name
        -d|--dropping) shift; dropping="$1"; shift ;;           # Dropped (invalid) array
        -D|--dedub|--deduplicate) shift; deduplicate="$1"; shift ;; # Deduplicated array (only for arrays)
        -F|--forbid-full)
          shift
          forbid_full=()
          while [[ $# -gt 0 && "$1" != "-"* ]]; do
            [[ "$1" =~ ^\\- ]] && forbid_full+=("${1:1}") || forbid_full+=("$1")
            shift
          done
          ;;
        -i|--input) shift; end_of_options=true; continue ;;     # End of options, start values
        *) break ;;
      esac
    else
      break
    fi
  done

  # --------- Setup namerefs ---------
  if [[ -n "$return_var" ]]; then
    declare -n target_ref="$return_var"
  else
    $verbose && echo "❌ No return variable specified" >&2
    return 1
  fi

  [[ -n "$dropping" ]] && declare -n dropping_ref="$dropping"
  [[ "$type" == "array" && -n "$deduplicate" ]] && declare -n deduplicate_ref="$deduplicate"

  # --------- Collect values after -i / --input ---------
  local values=()
  while [[ $# -gt 0 ]]; do
    local val="${1#\\-}"  # Strip leading backslash if present
    shift

    # --- Deduplication for arrays ---
    if [[ "$type" == "array" && -n "$deduplicate" ]]; then
      if [[ " ${values[*]} " == *" $val "* ]]; then
        deduplicate_ref+=("$val")
        continue
      fi
    fi

    values+=("$val")
  done

  # --------- Validation helper function (check_chars) ---------
  check_chars() {
    local val="$1"
    local chars="$2"      # Allowed or forbidden characters
    local flag="$3"       # Name for error messages
    local mode="$4"       # "allow" or "forbid"

    # --- Convert paired brackets to single opening brackets ---
    local processed=""
    for pair in $chars; do
      case "$pair" in
        "()"|")") processed+="(" ;;
        "[]"|"]") processed+="[" ;;
        "{}"|"}") processed+="{" ;;
        *) processed+="$pair" ;;
      esac
    done

    # --- Check each character ---
    for (( i=0; i<${#val}; i++ )); do
      local c="${val:i:1}"
      if [[ "$mode" == "allow" && "$processed" != *"$c"* ]]; then
        $verbose && echo "❌ [ERROR] $flag contains invalid character: $val"
        return 1
      elif [[ "$mode" == "forbid" && "$processed" == *"$c"* ]]; then
        $verbose && echo "❌ [ERROR] $flag contains forbidden character: $val"
        return 1
      fi
    done
    return 0
  }

  # --------- Validate values and handle dropping ---------
  local new_values=()
  for val in "${values[@]}"; do
    local invalid=false
    local reason=""

    # --- Check numbers ---
    if $allow_numbers && [[ ! "$val" =~ ^[0-9]+$ ]]; then
      invalid=true
      reason="must be numbers only"
    fi

    # --- Check letters ---
    if ! $invalid && $allow_letters && [[ ! "$val" =~ ^[a-zA-Z]+$ ]]; then
      invalid=true
      reason="must be letters only"
    fi

    # --- Check forbidden chars ---
    if ! $invalid && [[ -n "$forbid_chars" ]]; then
      if ! check_chars "$val" "$forbid_chars" "$name" "forbid"; then
        invalid=true
        reason="contains forbidden chars"
      fi
    fi

    # --- Check allowed chars ---
    if ! $invalid && [[ -n "$allow_chars" ]]; then
      if ! check_chars "$val" "$allow_chars" "$name" "allow"; then
        invalid=true
        reason="contains not allowed chars"
      fi
    fi

    # --- Check full forbidden values ---
    if ! $invalid && [[ ${#forbid_full[@]} -gt 0 ]]; then
      for forbidden in "${forbid_full[@]}"; do
        if [[ "$forbidden" == *"*"* ]]; then
          [[ "$val" == $forbidden ]] && { invalid=true; reason="value forbidden"; break; }
        else
          [[ "$val" == "$forbidden" ]] && { invalid=true; reason="value forbidden"; break; }
        fi
      done
    fi

    # --- Handle invalid value ---
    if $invalid; then
      # Always add to dropping_ref if set
      [[ -n "$dropping_ref" ]] && dropping_ref+=("$val")

      # Print error if verbose
      $verbose && echo "❌ [ERROR] $name $reason: $val"

      # For single value, exit immediately
      [[ "$type" != "array" || -z "$dropping" ]] && return 1
      continue
    fi

    # --- Valid element ---
    new_values+=("$val")
  done

  # --------- Assign values to target ---------
  if [[ "$type" == "array" ]]; then
    target_ref=("${new_values[@]}")
  else
    target_ref="${new_values[0]}"
  fi

  # --------- Apply toggle flag ---------
  $toggle && target_ref=true

}
