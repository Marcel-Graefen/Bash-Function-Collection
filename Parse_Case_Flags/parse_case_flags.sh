#!/usr/bin/env bash

# ========================================================================================
# Bash Parse Case Flags
#
#
# @author      : Marcel Gräfen
# @version     : 0.0.0-beta.02
# @date        : 2025-09-06
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
# @version 0.0.0-beta.02
#
# Parses, validates, and assigns values from command-line flags within a case block.
#
# Features:
#   - Supports single values, arrays, and toggle flags
#   - Validates values as numbers or letters only
#   - Rejects specified characters or complete forbidden values (supports wildcards)
#   - Dynamically assigns values to provided variable names (using nameref)
#   - Preserves unprocessed arguments for subsequent flag handling
#
# GLOBAL VARIABLES:
#   None
#
# External programs used:
#   None
#
# Internal functions used:
#   None
#
# Arguments (OPTIONS):
#   <flag>                         The command-line flag to parse (e.g., --name)
#   <target_variable>              Name of the variable to assign the value(s) to
#   --array                        Treat values as an array (collect multiple arguments)
#   --number                       Only allow numeric values
#   --letters                      Only allow alphabetic characters
#   --toggle                       Flag with no value, sets target variable to true
#   --forbid <chars>               Disallow these characters in values
#   --forbid-full <value1> [...]   Disallow specific full values (supports wildcards *)
#   -i "$@"                        Marks end of internal parsing and passes all remaining CLI arguments to the function
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
#   - Handles arrays, toggles, and multiple validation rules cleanly
#   - Must always be called with "$@" after -i to ensure unprocessed arguments are preserved
#

parse_case_flags() {

  # --------- Defaults -----------------
  local flag="$1"; shift
  declare -n target_ref="$1"; shift
  local type="single"
  local allow_numbers=false
  local allow_letters=false
  local toggle=false
  local forbid_chars=""
  local forbid_full=()

  # --------- Parse arguments ---------
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --array) type="array"; shift ;;
      --number) allow_numbers=true; shift ;;
      --letters) allow_letters=true; shift ;;
      --toggle) toggle=true; shift ;;
      --forbid) forbid_chars="$2"; shift 2 ;;
      --forbid-full)
        shift
        forbid_full=()
        while [[ $# -gt 0 && "$1" != "-i" && ! ( "$1" == -* && "$1" != \"*\" && "$1" != \'*\' ) ]]; do
          forbid_full+=("$1")
          shift
        done
        ;;
     -i) shift; break ;;
      *) break ;;
    esac
  done

  # --------- Collecting values ---------
  local values=()
  while [[ $# -gt 0 && "$1" != "-i" && ! ( "$1" == -* && "$1" != \"*\" && "$1" != \'*\' ) ]]; do
    values+=("$1")
    shift
  done

  # --------- Validation ---------
  if [[ ${#values[@]} -eq 0 && $toggle == false ]]; then
    echo "❌ [ERROR] $flag have no Value" >&2
    return 1
  fi

  for val in "${values[@]}"; do
    if $allow_numbers && [[ ! "$val" =~ ^[0-9]+$ ]]; then
      echo "❌ [ERROR] $flag must be numbers only: $val"
      return 1
    fi
    if $allow_letters && [[ ! "$val" =~ ^[a-zA-Z]+$ ]]; then
      echo "❌ [ERROR] $flag must be letters only: $val"
      return 1
    fi
    if [[ -n "$forbid_chars" && "$val" =~ [$forbid_chars] ]]; then
      echo "❌ [ERROR] $flag contains forbidden character: $val"
      return 1
    fi
    for forbidden in "${forbid_full[@]}"; do
      if [[ "$forbidden" == *"*"* ]]; then
        [[ "$val" == $forbidden ]] && { echo "❌ [ERROR] $flag value forbidden: $val"; return 1; }
      else
        [[ "$val" == "$forbidden" ]] && { echo "❌ [ERROR] $flag value forbidden: $val"; return 1; }
      fi
    done
  done

  # --------- Assign values ---------
  if [[ "$type" == "array" ]]; then
    target_ref=("${values[@]}")
  else
    target_ref="${values[0]}"
  fi

  # --------- Set toggle  ---------
  if $toggle; then
    target_ref=true
  fi
}
