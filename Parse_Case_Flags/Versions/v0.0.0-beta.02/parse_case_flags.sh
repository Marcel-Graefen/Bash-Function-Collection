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
#   --allow <chars>                Allow these characters in values
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
  local allow_chars=""
  local forbid_full=()

  check_chars() {
    local val="$1"
    local chars="$2"      # Allow- oder Forbidden-Zeichen
    local flag="$3"       # Name für Fehlermeldung
    local mode="$4"       # "allow" oder "forbid"

    # Schritt 1: Paare / Einzelklammern auf öffnende Klammern reduzieren
    local processed=""
    for pair in $chars; do
      case "$pair" in
        "()" | ")") processed+="(" ;;
        "[]" | "]") processed+="[" ;;
        "{}" | "}") processed+="{" ;;
        *) processed+="$pair" ;;
      esac
    done

    # Schritt 2: jeden Character prüfen
    for (( i=0; i<${#val}; i++ )); do
      local c="${val:i:1}"
      if [[ "$mode" == "allow" && "$processed" != *"$c"* ]]; then
        echo "❌ [ERROR] $flag contains invalid character: $val"
        echo "   Allowed: $chars"
        echo "   Input value: $val"
        return 1
      elif [[ "$mode" == "forbid" && "$processed" == *"$c"* ]]; then
        echo "❌ [ERROR] $flag contains forbidden character: $val"
        echo "   Forbidden: $chars"
        return 1
      fi
    done

    return 0
  }

  # --------- Parse arguments ---------
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --array) type="array"; shift ;;
      --number) allow_numbers=true; shift ;;
      --letters) allow_letters=true; shift ;;
      --toggle) toggle=true; shift ;;
      --forbid) shift; forbid_chars="$1"; shift ;;
      --allow) shift; allow_chars="$1"; shift ;;
      --forbid-full)
        shift
        forbid_full=()
        while [[ $# -gt 0 && "$1" != "-"* && "$1" != "-i" ]]; do
          if [[ "$1" =~ ^\\- ]]; then
            forbid_full+=("${1:1}")
          else
            forbid_full+=("$1")
          fi
          shift
        done
        ;;
      -i) shift; break ;;
      *) break ;;
    esac
  done

  # --------- Collect values ---------
  local values=()
  while [[ $# -gt 0 && "$1" != "-"* && "$1" != "-i" ]]; do
    if [[ "$1" =~ ^\\- ]]; then
      values+=("${1:1}")
    else
      values+=("$1")
    fi
    shift
  done

  # --------- Validation ---------
  if [[ ${#values[@]} -eq 0 && $toggle == false ]]; then
    echo "❌ [ERROR] $flag has no value" >&2
    return 1
  fi

  for val in "${values[@]}"; do
    # Numbers
    if $allow_numbers && [[ ! "$val" =~ ^[0-9]+$ ]]; then
      echo "❌ [ERROR] $flag must be numbers only: $val"
      return 1
    fi
    # Letters
    if $allow_letters && [[ ! "$val" =~ ^[a-zA-Z]+$ ]]; then
      echo "❌ [ERROR] $flag must be letters only: $val"
      return 1
    fi
  # Forbidden chars prüfen
  if [[ -n "$forbid_chars" ]]; then
    check_chars "$val" "$forbid_chars" "$flag" "forbid" || return 1
  fi

  # Allowed chars prüfen
  if [[ -n "$allow_chars" ]]; then
    check_chars "$val" "$allow_chars" "$flag" "allow" || return 1
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
