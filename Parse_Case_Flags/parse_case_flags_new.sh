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
  local verbose=false
  local allow_numbers=false
  local allow_letters=false
  local toggle=false
  local required=false

  local help=false

  local string_output=false
  local dropping_var_string=false
  local deduplicate_var_string=false
  local rest_array_name_string=false
  local return_var_string=false


  local min_length=""
  local max_length=""
  local label=""
  local forbid_chars=""
  local allow_chars=""

  local return_var=""
  local dropping_var=""
  local deduplicate_var=""
  local rest_array_name=""

  local deduplicate_var_input=()
  local forbid_full=()
  local allow_full=()

  local string_sep="|"
  #!===

  # === Helper Function ===
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


    #--- Value Validation Helper ---
    validate_has_value() {

      [[ -z "$2" || "$2" == "-"* ]] && { echo "❌ [ERROR] $1 requires a value"; return 1; }

      return 0

    }

    #--- Boolean Flag Validation Helper ---
    validate_no_value() {

      [[ -n "$2" && "$2" != "-"* ]] && { echo "⚠️ [WARNING] Flag $1 is boolean and should not have a value. Removing value: '$2'"; return 1; }

      return 0
    }

    apply_global_string() {

        # string_flags = Array der Variablen-Namen
        local flags=("dropping_var_string" "deduplicate_var_string" "rest_array_name_string" "return_var_string")
        for f in "${flags[@]}"; do
            # nur setzen, wenn noch false (Array)
            [[ "${!f}" == false ]] && declare -g "$f=true"
        done

    }

  #!===

  # === Parse Flags ===
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i|--input) shift; break ;;

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
        # --- Validate that at least one value is provided ---
        [[ $# -eq 0 || "$1" == "-"* ]] && { echo "❌ [ERROR] $current_flag requires at least one value"; return 1; }
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
        # Validate that at least one value is provided
        [[ $# -eq 0 || "$1" == "-"* ]] && { echo "❌ [ERROR] $current_flag requires at least one value"; return 1; }
        while [[ $# -gt 0 ]]; do
          if parse_full_flag "$1" "$current_flag" allow_full; then
            shift
          else
            break
          fi
        done
        ;;

      -m|--min-length)          shift;  validate_has_value "-m/--min-length" "$1"  || return 1; min_length="$1";      shift ;;
      -M|--max-length)          shift;  validate_has_value "-M/--max-length" "$1"  || return 1; max_length="$1";      shift ;;

      -d|--dropping)            shift;  validate_has_value "-d/--dropping" "$1"    || return 1; dropping_var="$1";    shift ;
      [[ "$1" =~ ^(s|a)$ ]] && { [[ "$1" == "s" ]] && dropping_var_string=true || dropping_var_string=false; shift; }       ;;

      -D|--dedub|--deduplicate) shift;  validate_has_value "-D/--dedub" "$1"       || return 1; deduplicate_var="$1"; shift ;
      [[ "$1" =~ ^(s|a)$ ]] && { [[ "$1" == "s" ]] && deduplicate_var_string=true || deduplicate_var_string=false; shift; } ;;

      -R|--rest-params)         shift;  validate_has_value "-R/--rest-params" "$1" || return 1; rest_array_name="$1"; shift ;
      [[ "$1" =~ ^(s|a)$ ]] && { [[ "$1" == "s" ]] && rest_array_name_string=true || rest_array_name_string=false; shift; } ;;


      -l|--label)               shift;  validate_has_value "-l/--label" "$1"       || return 1; label="$1";           shift ;;
      -f|--forbid)              shift;  validate_has_value "-f/--forbid" "$1"      || return 1; forbid_chars="$1";    shift ;;
      -a|--allow)               shift;  validate_has_value "-a/--allow" "$1"       || return 1; allow_chars="$1";     shift ;;

      -o|--return|--output)     shift;  validate_has_value "-o/--return" "$1"      || return 1; return_var="$1";      shift ;
      [[ "$1" =~ ^(s|a)$ ]] && { [[ "$1" == "s" ]] && return_var_string=true || return_var_string=false; shift; }           ;;

      # --- Long flags for booleans with value validation ---
      --verbose)  shift; validate_no_value "--verbose" "$1"  || shift; verbose=true         ;;
      --number)   shift; validate_no_value "--number" "$1"   || shift; allow_numbers=true   ;;
      --letters)  shift; validate_no_value "--letters" "$1"  || shift; allow_letters=true   ;;
      --toggle)   shift; validate_no_value "--toggle" "$1"   || shift; toggle=true          ;;
      --required) shift; validate_no_value "--required" "$1" || shift; required=true        ;;
      --help)     shift; validate_no_value "--help" "$1"     || shift; help=true            ;;

      --string)
        shift;  validate_no_value "--string" "$1" || string_output=true ; shift;
        if [[ $# -gt 0 && "$1" != "-"* ]]; then
          string_sep="$1"
          shift
        fi
        ;;

      -*)
        # Split shortflags, only Boolean + -s
        short_flags="${1:1}"
        shift

        # --- Check if a value follows the short flags ---
        if [[ "$short_flags" =~ ^[vnltrh]*$ ]]; then  # Only Boolean flags (without s)
          validate_no_value "-$short_flags" "$1" || shift
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
            s)
              string_output=true
              if [[ $# -gt 0 && "$1" != "-"* ]]; then
                string_sep="$1"
                shift
              fi
              ;;
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


  # === CALL apply_global_string ===
  [[ "$string_output" == true ]] && apply_global_string


  # === Display Help and Exit ===
  [[ "$help" == true ]] && { __help_parse_case_flags ; exit 1; }
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

  # === Setup namerefs ===
  [[ -n "$dropping_var" ]] && declare -n dropping_ref="$dropping_var"
  [[ -n "$deduplicate_var" ]] && declare -n deduplicate_ref="$deduplicate_var"
  #!===

  # === Collect values after -i / --input ===
  local values=()
  local current_flag="$1"
  shift

  while [[ $# -gt 0 ]]; do

    # --- Recognize a foreign flag ---
    if [[ "$1" == "-"* && "$1" != "$current_flag" && ! "$1" =~ ^\\- ]]; then
      if [[ -n "$rest_array_name" ]]; then
        declare -n rest_ref="$rest_array_name"
        rest_ref=("$@")
      fi
      break
    fi

    # --- Same flag → skip ---
    if [[ "$1" == "$current_flag" ]]; then
      shift
      continue
    fi

    # --- Extract value, remove leading backslash ---
    local val="$1"
    [[ "$val" =~ ^\\- ]] && val="${val:1}"

    values+=("$val")
    shift
  done

  # --- Optional: Rest-Parameter sichern ---
  if [[ -n "$rest_array_name" && -z "${rest_ref[*]:-}" ]]; then
      declare -n rest_ref="$rest_array_name"
      rest_ref=("$@")
  fi

  #!===

  # === Deduplication ===
  if [[ -n "$deduplicate_var" ]]; then
    if [[ ${#deduplicate_var_input[@]} -gt 0 ]]; then
      values+=( "${deduplicate_var_input[@]}" )
    fi

    declare -A seen_values
    local tmp=()
    for v in "${values[@]}"; do
      if [[ -n "${seen_values["$v"]}" ]]; then
        deduplicate_ref+=("$v")
        continue
      fi
      seen_values["$v"]=1
      tmp+=("$v")
    done
    values=("${tmp[@]}")
    unset seen_values
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
      [[ -n "$dropping_var" ]] && dropping_ref+=("$val")
      $verbose && echo "❌ [ERROR] $label $reason: $val"
      continue
    fi

    new_values+=("$val")
  done
  #!===

  # === Assign values to target ===

  # Dropping
  if [[ "$dropping_var_string" == true && -n "${dropping_ref[@]:-}" ]]; then
      dropping_ref=("${dropping_ref[*]//$'\n'/"$string_sep"}")
  fi

  # Deduplicate
  if [[ "$deduplicate_var_string" == true && -n "${deduplicate_ref[@]:-}" ]]; then
      deduplicate_ref=("${deduplicate_ref[*]//$'\n'/"$string_sep"}")
  fi

  # Rest Array
  if [[ "$rest_array_name_string" == true && -n "${rest_ref[@]:-}" ]]; then
      rest_ref=("${rest_ref[*]//$'\n'/"$string_sep"}")
  fi

  # Return Var
  if [[ "$return_var_string" == true && -n "${target_ref[@]:-}" ]]; then
      target_ref=("${target_ref[*]//$'\n'/"$string_sep"}")
  fi

  return 0
  #!===

}


  # === Help Message ===
  __help_parse_case_flags() {
    cat << EOF

    parse_case_flags - A versatile bash function to parse command-line flags and options.

    Usage:
      parse_case_flags [options] -i <input_parameters>

    Options:
      -i, --input                     Input parameters to be parsed (required).
      -d, --dropping <var_name>       Name of the variable to drop (array).
      -D, --dedub <var_name>          Name of the variable to deduplicate (string).
      -R, --rest-params <array_name>  Name of the array to store remaining parameters (string).
      -l, --label <label>             Label for error messages (string).
      -f, --forbid <chars>            Characters to forbid in input (string).
      -a, --allow <chars>             Characters to allow in input (string).
      -o, --return <var_name>         Name of the variable to return the result (array|string).
      -F, --forbid-full <values>      Full values to forbid (multiple strings).
      -A, --allow-full <values>       Full values to allow (multiple strings).
      -m, --min-length <number>       Minimum length of each input value (number).
      -M, --max-length <number>       Maximum length of each input value (number).
      -s, --string [<separator>]      Output as a string with optional separator (default: '|').
      -v, --verbose                   Enable verbose output (boolean).
      -n, --number                    Allow numbers in input (boolean).
      -l, --letters                   Allow letters in input (boolean).
      -t, --toggle                    Toggle a boolean value (boolean).
      -r, --required                  Mark the option as required (boolean).
      -h, --help                      Display this help message and exit.

    Examples:
      parse_case_flags --verbose -d "myVar" -o "resultVar" -i "-f value1 -a value2"
      parse_case_flags -D "myArray" --string "," -i "-f value1 value2 value3"

    Note:
      This function requires Bash version 4.3 or higher.

EOF
    return 0
  }
  #!===
