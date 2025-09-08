#!/usr/bin/env bash

# ========================================================================================
# Bash Function: Format Message Line
#
#
# @author      : Marcel Gräfen
# @version     : 0.0.0-beta.01
# @date        : 2025-09-06
#
# @requires    : Bash 4.3+ (for printf -v named variable assignment)
#
# @see         : https://github.com/Marcel-Graefen/Bash-Function-Collection/
#
# @copyright   : Copyright (c) 2025 Marcel Gräfen
# @license     : MIT License
# ========================================================================================


source <(wget -qO- https://raw.githubusercontent.com/Marcel-Graefen/Bash-Function-Collection/refs/heads/main/Parse_Case_Flags/Versions/v0.0.0-beta.02/parse_case_flags.sh)

#---------------------- FUNCTION: format_message_line -----------------------
#
# @version 0.0.0-beta.01
#
# Builds a formatted line with optional text, fill characters, brackets, and padding.
#
# Features:
#   - Adds optional outer and inner padding around the text
#   - Surrounds text with specified brackets
#   - Fills remaining space with a repeated fill character
#   - Supports minimum total length for consistent output formatting
#   - Returns result either via a named output variable or stdout
#
# GLOBAL VARIABLES:
#   None
#
# External programs used:
#   seq, printf
#
# Internal functions used:
#   parse_case_flags version 0.0.0_beta.02
#
# Arguments (OPTIONS):
#   -r, --result                  Optional: Name of variable to store output (via printf -v)
#   -m, --msg, --message          Text to include inside the brackets
#   -l, --length, --min_len       Minimum total length of the line
#   -b, --brackets                Brackets to use around the text (e.g., [] or {})
#   -f, --fill_char               Character(s) to fill the line with
#   -ip, --inner_padding          Number of spaces between brackets and text
#   -op, --outer_padding          Number of spaces outside the brackets
#   -i "$@"                        Marks end of internal parsing and passes remaining CLI arguments
#
# Requirements:
#   Bash version >= 4.3 (for named variable assignment via printf -v)
#
# Returns:
#   0  on success
#   1  if unknown parameter or parse_case_flags fails
#
# Notes:
#   - Output is returned via the variable specified in -r/--result, or printed to stdout if omitted
#   - Useful for building consistent visual lines in terminal output, headers, or separators
#

format_message_line() {

  # --------- Check parameters ---------
  if [[ $# -eq 0 ]]; then
    echo "❌ [ERROR] No parameters provided"
    return 1
  fi

  # --------- Defaults -----------------
  local output=""
  local text=""
  local min_len=55
  local fill_char="="
  local brackets="[]"
  local inner_pad="0"
  local outer_pad="1"

  # --------- Parse arguments ---------
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -r|--result)
        shift
        parse_case_flags "-r|--result" output -i "$@" || return 1
        shift ${#output[@]}
        ;;
      -m|--msg|--message)
        shift
        parse_case_flags "-m|--msg|--message" text -i "$@" || return 1
        shift ${#text[@]}
        ;;
      -l|--length|--min_len)
        shift
        parse_case_flags "-l|--length|--min_len" min_len --number -i "$@" || return 1
        shift ${#min_len[@]}
        ;;
      -b|--brackets)
        shift
        parse_case_flags "-b|--brackets" brackets --allow "(){}[]" -i "$@" || return 1
        shift ${#brackets[@]}
        ;;
      -f|--fill_char)
        shift
        parse_case_flags "-f|--fill_char" fill_char --allow "#=*-~" -i "$@" || return 1
        shift ${#fill_char[@]}
        ;;
      -ip|--inner_padding)
        shift
        parse_case_flags "-ip|--inner_padding" inner_pad --number -i "$@" || return 1
        shift ${#inner_pad[@]}
        ;;
      -op|--outer_padding)
        shift
        parse_case_flags "-op|--outer_padding" outer_pad --number -i "$@" || return 1
        shift ${#outer_pad[@]}
        ;;
      *)
        echo "❌ [ERROR] Unknown parameter: $1"
        return 1
        ;;
    esac
  done



  local left_bracket="${brackets:0:1}"
  local right_bracket="${brackets:1:1}"

  local inner_space=""
  local outer_space=""

  (( inner_pad > 0 )) && inner_space="$(printf ' %.0s' $(seq 1 $inner_pad))"
  (( outer_pad > 0 )) && outer_space="$(printf ' %.0s' $(seq 1 $outer_pad))"

  local result=""
  if [ -n "$text" ]; then
    local text_len=${#text}
    local total_len=$((text_len + 2*inner_pad + 2 + 2*outer_pad))
    [ $total_len -lt $min_len ] && total_len=$min_len
    local side_len=$(((total_len - text_len - 2*inner_pad - 2 - 2*outer_pad) / 2))

    local left_fill="$(printf -- "${fill_char}%.0s" $(seq 1 "$side_len"))"
    local right_fill="$(printf -- "${fill_char}%.0s" $(seq 1 "$side_len"))"

    (( (total_len - text_len - 2*inner_pad - 2 - 2*outer_pad) % 2 != 0 )) && right_fill="${right_fill}${fill_char}"

    result="${left_fill}${outer_space}${left_bracket}${inner_space}${text}${inner_space}${right_bracket}${outer_space}${right_fill}"
  else
    safe_fill_char="${fill_char//%/%%}"
    result="$(printf -- "${safe_fill_char}%.0s" $(seq 1 "$min_len"))"
  fi



  if [[ -n "$output" ]]; then
    printf -v "$output" "%s" "$result"
  else
    printf "%s" "$result"
  fi

}
