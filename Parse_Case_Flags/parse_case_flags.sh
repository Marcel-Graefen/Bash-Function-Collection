#!/usr/bin/env bash

# ========================================================================================
# Bash Parse Case Flags
#
#
# @author      : Marcel Gräfen
# @version     : 1.0.0-beta.05
# @date        : 2025-09-26
#
# @requires    : Bash 4.3+
#
# @see         : https://github.com/Marcel-Graefen/Bash-Function-Collection/
#
# @copyright   : Copyright (c) 2025 Marcel Gräfen
# @license     : MIT License
# ========================================================================================




parse_case_flags() {

  # === Defaults ===
  local verbose=false             # Terminal output for warnings/errors
  local allow_numbers=false       # Only numbers are allowed
  local allow_letters=false       # Only letters are allowed
  local toggle=false              # when set, output is automatically true
  local required=false            # A value must be passed.

  local help=false                #

  local deduplicate=false         # Check all inputs for duplicate values and remove them
  local deduplicate_var=""        # Output variable of the double input value

  local other_flags=""            # Output all input values that do not have the same flag as the first input element
  local return_var=""             # The output
  local dropping_var=""           # All those who failed the filter tests

  local min_length=""
  local max_length=""
  local label=""                  # The name used in Warning and/or Error
  local forbid_chars=""           # Prohibited symbols / letters / numbers
  local allow_chars=""            # Allowed characters / letters / numbers

  local forbid_full=()            # Forbidden words. Wildcard (*) also allowed
  local allow_full=()             # Allowed words. Wildcard (*) also allowed


  # === HELPER FUNCTIONS ===

    #--- Value Validation Helper ---
    __validate_has_value() {

      [[ -z "$2" || "$2" == "-"* ]] && { echo "❌ [ERROR] $1 requires a value"; return 1; }

      return 0

    }

    #--- Boolean Flag Validation Helper ---
    __validate_no_value() {

      [[ -n "$2" && "$2" != "-"* ]] && { echo "⚠️ [WARNING] Flag $1 is boolean and should not have a value. Removing value: '$2'"; return 1; }

      return 0
    }

  #--- Parse Full Flag Helper ---
  # The function collects all values that follow a specific flag into an array—even across multiple flag calls.
  # It automatically detects when a new flag begins and stops collecting for the current flag.
  __parse_full_flag() {

    local val="$1"
    local current_flag="$2"

    # Stop if new real flag
    [[ "$val" == "-"* && "$val" != "$current_flag" && ! "$val" =~ ^\\- ]] && return 1

    # Skip repeated same flag
    [[ "$val" == "$current_flag" ]] && return 0

    # masking removeing
    [[ "$val" =~ ^\\- ]] && val="${val:1}"

    # Append to array
    local dest="$3"
    declare -n arr_ref="$dest"
    arr_ref+=("$val")
    return 0

  }

  #!===

  # === Parse Flags ===
  while [[ $# -gt 0 ]]; do

    case "$1" in
      -i|--input) shift; break ;;

      -F|--forbid-full)
        local current_flag="$1"
        shift
        # --- Validate that at least one value is provided ---
        [[ $# -eq 0 || "$1" == "-"* ]] && { echo "❌ [ERROR] $current_flag requires at least one value"; return 1; }
        while [[ $# -gt 0 ]]; do
          if __parse_full_flag "$1" "$current_flag" forbid_full; then
            shift
          else
            break
          fi
        done
        ;;

      -A|--allow-full)
        local current_flag="$1"
        shift
        # Validate that at least one value is provided
        [[ $# -eq 0 || "$1" == "-"* ]] && { echo "❌ [ERROR] $current_flag requires at least one value"; return 1; }
        while [[ $# -gt 0 ]]; do
          if __parse_full_flag "$1" "$current_flag" allow_full; then
            shift
          else
            break
          fi
        done
        ;;

      -m|--min-length)          shift;  __validate_has_value "-m/--min-length" "$1"  || return 1; min_length="$1";      shift ;;
      -M|--max-length)          shift;  __validate_has_value "-M/--max-length" "$1"  || return 1; max_length="$1";      shift ;;
      -d|--dropping)            shift;  __validate_has_value "-d/--dropping" "$1"    || return 1; dropping_var="$1";    shift ;;
      -D|--dedub|--deduplicate) shift; [[ -n "$1" && "$1" != "-"* ]] && { deduplicate_var="$1"; shift; } ; deduplicate=true ;;
      -R|--rest-params)         shift;  __validate_has_value "-R/--rest-params" "$1" || return 1; other_flags="$1";     shift ;;
      -L|--label)               shift;  __validate_has_value "-l/--label" "$1"       || return 1; label="$1";           shift ;;
      -f|--forbid)              shift;  __validate_has_value "-f/--forbid" "$1"      || return 1; forbid_chars="$1";    shift ;;
      -a|--allow)               shift;  __validate_has_value "-a/--allow" "$1"       || return 1; allow_chars="$1";     shift ;;
      -o|--return|--output)     shift;  __validate_has_value "-o/--return" "$1"      || return 1; return_var="$1";      shift ;;

      # --- Long flags for booleans with value validation ---
      --verbose)  shift; __validate_no_value "--verbose" "$1"  || shift; verbose=true         ;;
      --number)   shift; __validate_no_value "--number" "$1"   || shift; allow_numbers=true   ;;
      --letters)  shift; __validate_no_value "--letters" "$1"  || shift; allow_letters=true   ;;
      --toggle)   shift; __validate_no_value "--toggle" "$1"   || shift; toggle=true          ;;
      --required) shift; __validate_no_value "--required" "$1" || shift; required=true        ;;
      --help)     shift; __validate_no_value "--help" "$1"     || shift; help=true            ;;

      -*)
        # Split shortflags, only Boolean + -s
        short_flags="${1:1}"
        shift

        # --- Check if a value follows the short flags ---
        if [[ "$short_flags" =~ ^[vnltrh]*$ ]]; then  # Only Boolean flags (without s)
          __validate_no_value "-$short_flags" "$1" || shift
        fi

        for (( i=0; i<${#short_flags}; i++ )); do
          flag="${short_flags:i:1}"
          case "$flag" in
            v) verbose=true ;;
            n) allow_numbers=true ;;
            l) allow_letters=true ;;
            t) toggle=true ;;
            r) required=true ;;
            h) help=true ;;
            *)
              echo "❌ [ERROR] $label: Unknown or non-boolean short flag: -$flag"
              return 1
              ;;
          esac
        done
        ;;

      *)
        echo "❌ [ERROR] $label: Unknown parameter: $1"
        return 1
        ;;

    esac

  done
  #!===

  # === Check Value is set (none_zero) ===
  if $required && [[ -z $1 ]]; then
    $verbose && echo "❌ [ERROR] $label: no values provided"
    return 1
  fi
  #!===

  # === Setup namerefs for Return ===
  if [[ -n "$return_var" ]]; then
    declare -n target_ref="$return_var"
  else
    $verbose && echo "❌ [ERROR] $label: No return variable specified" >&2
    return 1
  fi
  #!===

  # === Apply toggle flag ===
  if $toggle ; then
    target_ref=(true)
    return 0
  fi
  #!===

  # === Validate count length (min & max zusammen) ===
  if [[ -n "$min_length" || -n "$max_length" ]]; then

    # --- Check if min_length is set and the number is > 0 ---
    if [[ -n "$min_length" ]]; then
      if ! [[ "$min_length" =~ ^[0-9]+$ ]]; then
        $verbose && echo "❌ [ERROR] $label: min_length is not a number: $min_length" >&2
        return 1
      elif (( min_length <= 0 )); then
        $verbose && echo "⚠️ [WARNING] $label: min_length must be greater than zero. Resetting."
        min_length=""
      fi
    fi

    # --- Check if max_length is set and the number is > 0 ---
    if [[ -n "$max_length" ]]; then
      if ! [[ "$max_length" =~ ^[0-9]+$ ]]; then
        $verbose && echo "❌ [ERROR] $label: max_length is not a number: $max_length" >&2
        return 1
      elif (( max_length <= 0 )); then
        $verbose && echo "⚠️ [WARNING] $label: max_length must be greater than zero. Resetting."
        max_length=""
      fi
    fi

    # --- Check relationship if both are set ---
    if [[ -n "$min_length" && -n "$max_length" && $max_length -lt $min_length ]]; then
      $verbose && echo "⚠️ [WARNING] $label: max_length ($max_length) is less than min_length ($min_length). Resetting both."
      min_length=""
      max_length=""
    fi

  fi
  #!===


  local values=()
  local group2=()
  local target_flag=""

  # The loop separates arguments into two groups: all values before the first flag go into group 1,
  # while the first flag and all subsequent arguments go into group 2.
  while [[ $# -gt 0 ]]; do

    if [[ "$1" == "-"* ]]; then
      if [[ -z "$target_flag" ]]; then
        # First flag found - moving to target
        target_flag="$1"
      fi

      if [[ "$1" == "$target_flag" ]]; then
        # target Flag - collect values, but do not put the Flag in Group 1
        shift
        while [[ $# -gt 0 && "$1" != "-"* ]]; do
          local val="$1"
          # Removal of masking, to use -* information WITHOUT triggering errors
          # The escape character is \
          [[ "$val" =~ ^\\- ]] && val="${val:1}"
          values+=("$val")
          shift
          done
      else
        # If the first argument is not a flag, all values are written to group 1.
        group2+=("$1")
        shift
        while [[ $# -gt 0 && "$1" != "-"* ]]; do
          group2+=("$1")
          shift
        done
      fi

    else
      if [[ -n "$target_flag" ]]; then
        values+=("$1")
      fi
        shift
    fi
  done

  if [[ -n "$other_flags" ]]; then
    declare -n other_flags_ref="$other_flags"
    other_flags_ref=("${group2[@]}")
  fi

  # === DEDUPLICATION ===
  if [[ "$deduplicate" == true ]]; then

    local dedup=()

    declare -A seen_values
    local tmp=()
    for v in "${values[@]}"; do
      if [[ -n "${seen_values["$v"]}" ]]; then
        dedup+=("$v")
        continue
      fi
      seen_values["$v"]=1
      tmp+=("$v")
    done

    values=("${tmp[@]}")
    unset seen_values

    if [[ -n "$deduplicate_var" ]]; then
      declare -n deduplicate_ref="$deduplicate_var"
      deduplicate_ref+=("${dedup[@]}")
    fi

  fi
  #!===

  # === Validation helper function ===
  check_chars() {

    local val="$1"
    local chars="$2"
    local flag="$3"
    local mode="$4"

    local processed=""
    for pair in $chars; do
      case "$pair" in
        "()"|")") processed+="(" ;;
        "[]"|"]") processed+="[" ;;
        "{}"|"}") processed+="{"
        ;;
        *) processed+="$pair" ;;
      esac
    done

    for (( i=0; i<${#val}; i++ )); do
      local c="${val:i:1}"
      if [[ "$mode" == "allow" && "$processed" != *"$c"* ]]; then
        invalid=true; reason="❌ [ERROR] $flag contains invalid character: $val"; return 1
      elif [[ "$mode" == "forbid" && "$processed" == *"$c"* ]]; then
        invalid=true; reason="❌ [ERROR] $flag contains forbidden character: $val"; return 1
      fi
    done
    return 0

  }
  #!===

  # === Validate values ===
  local new_values=()
  local dropping=()
  for val in "${values[@]}"; do
    local invalid=false
    local reason=""

    # --- numbers only check ---
    if $allow_numbers && ! $allow_letters && [[ ! "$val" =~ ^[0-9]+$ ]]; then
      invalid=true; reason="must be numbers only"
    fi

    # --- letters only check ---
    if ! $invalid && $allow_letters && ! $allow_numbers && [[ ! "$val" =~ ^[a-zA-Z]+$ ]]; then
      invalid=true; reason="must be letters only"
    fi

    # --- letters and numbers only check ---
    if ! $invalid && $allow_numbers && $allow_letters && [[ ! "$val" =~ ^[a-zA-Z0-9]+$ ]]; then
      invalid=true; reason="must be letters and or numbers only"
    fi

    # --- Check conflicting allow and forbid chars ---
    if [[ -n "$allow_chars" && -n "$forbid_chars" ]]; then
      conflicts=()
      for (( i=0; i<${#forbid_chars}; i++ )); do
        c="${forbid_chars:i:1}"
        [[ "$allow_chars" == *"$c"* ]] && conflicts+=("$c")
      done
      [[ ${#conflicts[@]} -gt 0 ]] && invalid=true; reason="⚠️ [WARNING] Characters both allowed and forbidden: ${conflicts[*]}"
    fi

    # --- check allowed chars ---
    if ! $invalid && [[ -n "$allow_chars" ]]; then
      if ! check_chars "$val" "$allow_chars" "$label" "allow"; then
        invalid=true
      fi
    fi

    # --- check forbidden chars ---
    if ! $invalid && [[ -n "$forbid_chars" ]]; then
      if ! check_chars "$val" "$forbid_chars" "$label" "forbid"; then
        invalid=true
      fi
    fi

    # --- Check full allowed values ---
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

    # --- min_length check ---
    if ! $invalid && [[ -n "$min_length" && ${#val} -lt $min_length ]]; then
      invalid=true; reason="value must have at least $min_length characters"
    fi

    # ---  max_length check ---
    if ! $invalid && [[ -n "$max_length" && ${#val} -gt $max_length ]]; then
      invalid=true; reason="value must have at most $max_length characters"
    fi

    # --- Handle invalid values ---
    if $invalid; then
      dropping+=("$val")
      $verbose && echo "❌ [ERROR] $label $reason: $val"
      continue
    fi

    new_values+=("$val")
  done
  #!===

  if [[ -n "$dropping_var" ]]; then
    declare -n dropping_ref="$dropping_var"
    dropping_ref=("${dropping[@]}")
  fi

  target_ref=("${new_values[@]}")

  return 0

}



# input="Hallo du doof kopf"

input="-w val-w val-w val-w -u val-u -j -i val-i -x val-x val-x"
parse_case_flags -D DEDUP -o Hallo -l -d WOW -i $input


echo "Output) ${Hallo[*]}"
echo "Dedup) ${DEDUP[*]}"
echo "Dropping) ${WOW[*]}"
