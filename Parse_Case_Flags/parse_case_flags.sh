#!/usr/bin/env bash

# ========================================================================================
# Bash Parse Case Flags
#
#
# @author      : Marcel Gräfen
# @version     : 1.0.0-beta.04
# @date        : 2025-09-26
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
# @version 1.0.0-beta.04
#
# Parses, validates, and assigns values from command-line flags within a case block.
#
# Features:
#   - Supports single values, arrays, and toggle flags
#   - Validates values as numbers, letters, or alphanumeric combinations
#   - Rejects specified characters or complete forbidden values (supports wildcards *)
#   - Deduplicates array elements when requested (with optional external input)
#   - Collects invalid values into a dropping array if specified
#   - Dynamically assigns values to provided variable names (using nameref)
#   - Automatically returns unprocessed arguments for subsequent flag handling
#   - Handles multi-value parameters and multiple occurrences of the same flag
#   - Handles toggle flags, which set the target variable to true
#   - Optional flag recognition for case statement integration
#   - Warns if characters are both allowed and forbidden
#   - Supports masked leading dashes for values that start with hyphens
#
# GLOBAL VARIABLES:
#   None
#
# External programs used:
#   None
#
# Internal functions used:
#   check_chars - validates allowed/forbidden characters per value
#   parse_full_flag - collects multiple full values for allow/forbid checks
#
# Arguments (OPTIONS):
#   -n, --name <name>                 Name for error messages
#   -y, --array                       Treat values as an array (collect multiple values)
#   -v, --verbose                     Enable verbose error output
#   -c, --number                      Only allow numeric values
#   -l, --letters                     Only allow alphabetic characters
#   -t, --toggle                      Flag with no value, sets target variable to true
#   -nz, --none-zero                  Require at least one value
#   -nrf, -NF, --no-recognize-flags   Disable flag recognition in array mode
#   -f, --forbid <chars>              Disallow these characters in values
#   -a, --allow <chars>               Allow only these characters in values
#   -r, --return, -o, --output <var>  Name of variable to assign values to
#   -d, --dropping <array_name>       Collect invalid values into this array
#   -D, --deduplicate <array_name>    Collect duplicate values into this array
#   -DI, --dedub-input <values...>    Additional values for deduplication input
#   -F, --forbid-full <values...>     Disallow specific full values (supports wildcards *)
#   -A, --allow-full <values...>      Allow only specific full values (supports wildcards *)
#   -R, --rest-params <array_name>    Return unprocessed arguments in this array
#   -i, --input "$@"                  Pass all remaining CLI arguments for processing
#
# Usage in case statements:
#   -d|--dir)
#     local rest_params
#     parse_case_flags -v -n "directory" -r directories -y -R rest_params -i "$@" || return 1
#     set -- "${rest_params[@]}"
#     ;;
#
# Requirements:
#   Bash version >= 4.3 (for declare -n nameref support)
#
# Returns:
#   0  on success
#   1  if required values are missing or validation fails
#
# Notes:
#   - Designed to be used inside a case block to process CLI flags sequentially
#   - Arrays, toggles, deduplication, dropping, and validation are handled internally
#   - Must always be called with "$@" after -i/--input to ensure proper argument processing
#   - Works with multi-value flags and multiple occurrences of the same flag
#   - The --no-recognize-flags option controls whether flags are recognized in array mode
#   - Use --rest-params for automatic handling of remaining arguments (recommended)
#   - Masked leading dashes (\-value) are properly handled as values rather than flags
#   - Deduplication can include external values via --dedub-input for cross-flag deduplication

parse_case_flags() {

  #--------- Defaults ---------
  local type="single"
  local verbose=false
  local allow_numbers=false
  local allow_letters=false
  local toggle=false
  local none_zero=false
  local recognize_flags=true
  local name=""
  local forbid_chars=""
  local allow_chars=""
  local return_var=""
  local dropping_var=""
  local deduplicate_var=""
  local deduplicate_var_input=()
  local forbid_full=()
  local allow_full=()
  local rest_array_name=""
  local end_of_options=false

  #--------- Helper Function ---------
  parse_full_flag() {

    local val="$1"
    local current_flag="$2"

    # Stop if new real flag
    [[ "$val" == "-"* && "$val" != "$current_flag" && ! "$val" =~ ^\\- ]] && return 1

    # Skip repeated same flag
    [[ "$val" == "$current_flag" ]] && return 0

    # Remove leading backslash
    [[ "$val" =~ ^\\- ]] && val="${val:1}"

    # Append to array
    local dest="$3"
    declare -n arr_ref="$dest"
    arr_ref+=("$val")
    return 0

  }

  #--------- Parse arguments ---------
  while [[ $# -gt 0 ]]; do
    if [[ "$end_of_options" == false ]]; then
      case "$1" in
        -n|--name)                shift; name="$1";              shift ;;
        -y|--array)                      type="array";           shift ;;
        -v|--verbose)                    verbose=true;           shift ;;
        -c|--number)                     allow_numbers=true;     shift ;;
        -l|--letters)                    allow_letters=true;     shift ;;
        -t|--toggle)                     toggle=true;            shift ;;
        -nz|--none-zero)                 none_zero=true;         shift ;;
        -nrf|-NF|--no-recognize-flags)   recognize_flags=false;  shift ;;
        -f|--forbid)              shift; forbid_chars="$1";      shift ;;
        -a|--allow)               shift; allow_chars="$1";       shift ;;
        -r|--return|-o|--output)  shift; return_var="$1";        shift ;;
        -d|--dropping)            shift; dropping_var="$1";      shift ;;
        -D|--dedub|--deduplicate) shift; deduplicate_var="$1";   shift ;;
        -R|--rest-params)         shift; rest_array_name="$1";   shift ;;
        -DI|--dedub-input|--deduplication-input)
            local current_flag="$1"
            shift
            while [[ $# -gt 0 ]]; do
                if parse_full_flag "$1" "$current_flag" deduplicate_var_input; then
                    shift
                else
                    break
                fi
            done
            ;;
        -F|--forbid-full)
            local current_flag="$1"
            shift
            while [[ $# -gt 0 ]]; do
                if parse_full_flag "$1" "$current_flag" forbid_full; then
                    shift
                else
                    break
                fi
            done
            ;;
        -A|--allow-full)
            local current_flag="$1"
            shift
            while [[ $# -gt 0 ]]; do
                if parse_full_flag "$1" "$current_flag" allow_full; then
                    shift
                else
                    break
                fi
            done
            ;;
        -i|--input) shift;  end_of_options=true; break  ;;
        *) echo "❌ [ERROR] Unknown parameter: $1"; return 1 ;;
      esac
    else
      break
    fi
  done



  # --------- Check Value is set (none_zero) ---------
  if $none_zero && [[ -z $1 ]]; then
    $verbose && echo "❌ [ERROR] $name: no values provided"
    return 1
  fi

  #--------- Setup namerefs for Return ---------
  if [[ -n "$return_var" ]]; then
    declare -n target_ref="$return_var"
  else
    $verbose && echo "❌ [ERROR] No return variable specified" >&2
    return 1
  fi

  #--------- Apply toggle flag ---------
  if $toggle ; then
    if [[ "$type" == "array" ]]; then
      type="single"
      $verbose && echo "⚠️ [WARNING] Toggle not supported for arrays. Set Type to Single"
    fi
    $toggle && target_ref=true
    return 0
  fi

  #--------- Setup namerefs ---------
  [[ -n "$dropping_var" ]] && declare -n dropping_ref="$dropping_var"
  [[ "$type" == "array" && -n "$deduplicate_var" ]] && declare -n deduplicate_ref="$deduplicate_var"

  #--------- Collect values after -i / --input ---------
  local values=()

  # --- Single or Array ---
  if [[ "$type" == "array" && "$1" == "-"* && "$recognize_flags" == true ]]; then
    local current_flag="$1"
    shift
  fi

  # Für Array: Current flag merken
  local current_flag="$1"
  shift

  while [[ $# -gt 0 ]]; do
      # 1️⃣ Fremdes Flag erkennen (nicht maskiert)
      if [[ "$type" == "array" && "$1" == "-"* && "$1" != "$current_flag" && ! "$1" =~ ^\\- && "$recognize_flags" == true ]]; then
          # Rest-Parameter sichern
          if [[ -n "$rest_array_name" ]]; then
              declare -n rest_ref="$rest_array_name"
              rest_ref=("$@")  # Alle verbleibenden Parameter
          fi
          break  # sofort aus der Schleife
      fi

      # 2️⃣ Gleiche Flag → überspringen (nur Array)
      if [[ "$type" == "array" && "$1" == "$current_flag" ]]; then
          shift
          continue
      fi

      # 3️⃣ Wert extrahieren, führenden Backslash entfernen
      local val="$1"
      [[ "$val" =~ ^\\- ]] && val="${val:1}"

      values+=("$val")
      shift

      # 4️⃣ Single: nur ein Wert → Schleife beenden
      [[ "$type" != "array" ]] && break
  done

  # --- Optional: Rest-Parameter sichern, falls noch nicht geschehen ---
  if [[ -n "$rest_array_name" && -z "${rest_ref[*]:-}" ]]; then
      declare -n rest_ref="$rest_array_name"
      rest_ref=("$@")
  fi

  #--------- Deduplication for Arrays ---------
  if [[ "$type" == "array" && -n "$deduplicate_var" ]]; then

    #--------- Optional: Werte aus deduplicate_var_input hinzufügen ---------
    if [[ ${#deduplicate_var_input[@]} -gt 0 ]]; then
      values+=( "${deduplicate_var_input[@]}" )
    fi

    declare -A seen_values  # Assoziatives Array für schnelle Suche
    local tmp=()

    for v in "${values[@]}"; do
      if [[ -n "${seen_values["$v"]}" ]]; then
        # Duplikat gefunden → zu deduplicate_ref hinzufügen
        deduplicate_ref+=("$v")
        continue
      fi
      # Erstmaliger Wert → merken und zu tmp hinzufügen
      seen_values["$v"]=1
      tmp+=("$v")
    done

    values=("${tmp[@]}")
    unset seen_values  # Cleanup
  fi

  #--------- Validation helper function (check_chars) ---------
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

    #--------- Check each character ---------
    for (( i=0; i<${#val}; i++ )); do
      local c="${val:i:1}"
      if [[ "$mode" == "allow" && "$processed" != *"$c"* ]]; then
        invalid=true; reason="❌ [ERROR] $flag contains invalid character: $val"
        return 1
      elif [[ "$mode" == "forbid" && "$processed" == *"$c"* ]]; then
        invalid=true; reason="❌ [ERROR] $flag contains forbidden character: $val"
        return 1
      fi
    done
    return 0
  }

  #--------- Validate values and handle dropping ---------
  local new_values=()
  for val in "${values[@]}"; do
    local invalid=false
    local reason=""

    #--------- Check numbers ---------
    if $allow_numbers && ! $allow_letters && [[ ! "$val" =~ ^[0-9]+$ ]]; then
      invalid=true
      reason="must be numbers only"
    fi

    #--------- Check letters ---------
    if ! $invalid && $allow_letters && ! $allow_numbers && [[ ! "$val" =~ ^[a-zA-Z]+$ ]]; then
      invalid=true
      reason="must be letters only"
    fi

    #--------- Check numbers & letters ---------
    if ! $invalid && $allow_numbers && $allow_letters && [[ ! "$val" =~ ^[a-zA-Z0-9]+$ ]]; then
      invalid=true
      reason="must be letters and or numbers only"
    fi

    #--------- Check allowed vs forbidden characters for conflicts ---------
    if [[ -n "$allow_chars" ]] && [[ -n "$forbid_chars" ]]; then
      conflicts=()
      for (( i=0; i<${#forbid_chars}; i++ )); do
        c="${forbid_chars:i:1}"
        [[ "$allow_chars" == *"$c"* ]] && conflicts+=("$c")
      done
      [[ ${#conflicts[@]} -gt 0 ]] && invalid=true; reason="⚠️ [WARNING] Characters both allowed and forbidden: ${conflicts[*]}"
    fi

    #--------- Check allowed chars ---------
    if ! $invalid && [[ -n "$allow_chars" ]]; then
      if ! check_chars "$val" "$allow_chars" "$name" "allow"; then
        invalid=true
        # Output in check_chars
      fi
    fi

    #--------- Check forbidden chars ---------
    if ! $invalid && [[ -n "$forbid_chars" ]]; then
      if ! check_chars "$val" "$forbid_chars" "$name" "forbid"; then
        invalid=true
        # Output in check_chars
      fi
    fi

    #--------- Check full allowed values ---------
    if ! $invalid && [[ ${#allow_full[@]} -gt 0 ]]; then
      match=false
      for allowed in "${allow_full[@]}"; do
          if [[ "$allowed" == *"*"* ]]; then
              [[ "$val" == $allowed ]] && { match=true; break; }
          else
              [[ "$val" == "$allowed" ]] && { match=true; break; }
          fi
      done

      ! $match && { invalid=true; reason="value not allowed"; }
    fi

    #--------- Check full forbidden values ---------
    if ! $invalid && [[ ${#forbid_full[@]} -gt 0 ]]; then
      for forbidden in "${forbid_full[@]}"; do
        if [[ "$forbidden" == *"*"* ]]; then
          [[ "$val" == $forbidden ]] && { invalid=true; reason="value forbidden"; break; }
        else
          [[ "$val" == "$forbidden" ]] && { invalid=true; reason="value forbidden"; break; }
        fi
      done
    fi

    #--------- Handle invalid value ---------
    if $invalid; then
      # Always add to dropping_ref if set
      dropping_ref+=("$val")

      # Print error if verbose
      $verbose && echo "❌ [ERROR] $name $reason: $val"

      # For single value, exit immediately
      [[ "$type" != "array" && -z "$dropping" ]] && return 1
      continue
    fi

    #--------- Valid element ---------
    new_values+=("$val")
  done

  #--------- Assign values to target ---------
  if [[ "$type" == "array" ]]; then
    target_ref=("${new_values[@]}")
  else
    target_ref="${new_values[0]}"
  fi

  #--------- Rest-Parameter setzen ---------
  # if [[ -n "$rest_array_name" ]]; then
  #   declare -n rest_ref="$rest_array_name"

  #   # Zuerst die übrig gebliebenen originalen Argumente bestimmen
  #   local remaining=()
  #   local skip=true
  #   for arg in "${original_args[@]}"; do
  #     if $skip && [[ "$arg" == "-i" || "$arg" == "--input" ]]; then
  #       skip=false
  #       continue
  #     fi
  #     $skip && continue
  #     remaining+=("$arg")
  #   done

  #   rest_ref=("${remaining[@]}")
  # fi

  return 0

}
