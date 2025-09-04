#!/usr/bin/env bash

# ========================================================================================
# Bash log Call Chain
#
#
# @author      : Marcel Gräfen
# @version     : 0.0.0-beta.01
# @date        : 2025-09-04
#
# @requires    : Bash 4.3+
# @requires    : realpath
#
# @see         : https://github.com/Marcel-Graefen/Bash-Function-Collection/
#
# @copyright   : Copyright (c) 2025 Marcel Gräfen
# @license     : MIT License
# ========================================================================================

#---------------------- FUNCTION: log_call_chain --------------------------------
#
# @version 0.0.0-beta.01
#
# Logs the full hierarchical call chain of Bash functions and scripts.
#
# Features:
#   - Captures nested function calls across multiple scripts
#   - Generates a readable ASCII tree showing call hierarchy
#   - Shortens script paths to first folder + ... + filename
#   - Maintains a legend of full paths for reference (only scripts, no log files)
#   - Supports multiple output files and directories
#   - Allows suppression of specified functions or scripts in call chain
#   - Validates directories and handles missing or non-writable paths
#   - Logs errors for files/directories that cannot be created
#
# GLOBAL VARIABLES:
#   None
#
# External programs used:
#   realpath
#
# Internal functions used:
#   lcc_check_value
#   lcc_validate_dirs
#   lcc_resolve_files
#   lcc_write_callchain
#   lcc_write_errors
#   lcc_write_logs
#
# Arguments (OPTIONS):
#   -s|--status <STATUS>            Status string (INFO, WARNING, ERROR, etc.)
#   -m|--message <SHORT_MSG>        Short message or subject describing the log entry (e.g., "Inside func_d", "Directory not writable")
#   -D|--details <LONG_MSG>         Detailed explanation or context for the log entry (optional)
#   -d|--dir <DIR1> [DIR2 ...]      Directories to store log files
#   -f|--file <FILE1> [FILE2 ...]   Log file names
#   -x|--suppress <NAME1> [NAME2...] Functions or scripts to suppress in call chain
#
# Requirements:
#   Bash version >= 4.0
#
# Returns:
#   0  on success
#   1  if required parameters are missing or invalid
#
# Notes:
#   - Designed for modular Bash scripts with nested function calls
#   - Provides full visibility of execution flow for debugging or auditing
#   - Main script call is always shown first in the call chain
#

log_call_chain() {

  # --------- Check parameters ---------
  if [[ $# -eq 0 ]]; then
    echo "❌ [ERROR] No parameters provided"
    return 1
  fi

  # --------- Defaults -----------------
  local status=""
  local message=""
  local details=""
  local dirs=()
  local files=()
  local suppress_list=()
  declare -A errors_map
  local default_dir="/tmp"
  local default_file="log_callchain_$$.log"

  # --------- Helper to check values ---------
  lcc_check_value() {
    local forbidden_flags=("-s" "--status" "-m" "--message" "--msg" "-D" "--details" "-d" "--dir" "-f" "--file" "-x" "--suppress")
    [[ -z "$1" ]] && { echo "❌ [ERROR] '$2' requires a value"; exit 1; }
    for f in "${forbidden_flags[@]}"; do
      [[ "$1" == "$f" ]] && { echo "❌ [ERROR] '$2' requires a value, got a flag instead"; exit 1; }
    done
  }

  # --------- Parse arguments ---------
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -s|--status)
        lcc_check_value "$2" "$1"
        status="${2^^}"
        shift 2
      ;;
      -m|--message|--msg)
        lcc_check_value "$2" "$1"
        message="$2"
        shift 2
      ;;
      -D|--details)
        lcc_check_value "$2" "$1"
        details="$2"
        shift 2
      ;;
      -d|--dir)
        local prev_flag="$1"
        shift
        while [[ $# -gt 0 && "$1" != "-"* ]]; do
          lcc_check_value "$1" "$prev_flag"
          dirs+=("${1%/}")
          shift
        done
      ;;
      -f|--file)
        local prev_flag="$1"
        shift
        while [[ $# -gt 0 && "$1" != "-"* ]]; do
          lcc_check_value "$1" "$prev_flag"
          files+=("$1")
          shift
        done
      ;;
      -x|--suppress)
        local prev_flag="$1"
        shift
        while [[ $# -gt 0 && "$1" != "-"* ]]; do
          lcc_check_value "$1" "$prev_flag"
          suppress_list+=("$1")
          shift
        done
      ;;
      * )
        echo "❌ [ERROR] Unknown option: $1"
        exit 1
      ;;
    esac
  done

  # --------- Apply defaults -----------------
  [[ ${#dirs[@]} -eq 0 ]] && dirs=("$default_dir")
  [[ ${#files[@]} -eq 0 ]] && files=("$default_file")

  # --------- Validate directories ---------
  lcc_validate_dirs() {
    valid_dirs=()
    for dir in "${dirs[@]}"; do
      if [[ -d "$dir" && -w "$dir" ]]; then
        valid_dirs+=("$dir")
        continue
      fi

      parent_dir="$(dirname "$dir")"

      if [[ ! -d "$parent_dir" ]]; then
        errors_map["$dir"]="Parent folder does not exist"
        continue
      fi

      if [[ ! -w "$parent_dir" ]]; then
        errors_map["$dir"]="Parent folder not writable"
        continue
      fi

      mkdir "$dir" 2>/dev/null && valid_dirs+=("$dir") || errors_map["$dir"]="Cannot create folder"
    done

    [[ ${#valid_dirs[@]} -eq 0 ]] && mkdir -p "$default_dir" 2>/dev/null && valid_dirs=("$default_dir")
  }

  # --------- Resolve files ---------
  lcc_resolve_files() {
    usable_paths=()
    for file in "${files[@]}"; do
      if [[ "$file" = /* ]]; then
        local existed=false
        [[ -f "$file" ]] && existed=true
        touch "$file" 2>/dev/null && usable_paths+=("$file:$existed") || errors_map["$file"]="Cannot create file"
      else
        for dir in "${valid_dirs[@]}"; do
          local path="$dir/$file"
          local existed=false
          [[ -f "$path" ]] && existed=true
          touch "$path" 2>/dev/null && usable_paths+=("$path:$existed") || errors_map["$path"]="Cannot create file"
        done
      fi
    done
  }

  # --------- Write call chain ---------
  lcc_write_callchain() {

    local full_path="$1"
    local status="$2"
    local message="$3"
    local -a suppress_list=("${!4}")
    local -a all_paths=("${!5}")
    declare -n errors_map_ref=$6

    echo "Date: $(date +"%Y-%m-%d %H:%M:%S")" >> "$full_path"
    [[ -n "$status" ]] && echo "Status: $status" >> "$full_path"
    [[ -n "$message" ]] && echo "Message: $message" >> "$full_path"
    [[ -n "$details" ]] && echo "Details: $details" >> "$full_path"
    [[ ${#suppress_list[@]} -gt 0 ]] && echo "Suppressed: ${suppress_list[*]}" >> "$full_path"
    echo "" >> "$full_path"

    echo "Call chain:" >> "$full_path"
    echo "" >> "$full_path"

    declare -A scr_funcs
    local -a scr_order
    local total=${#FUNCNAME[@]}

    for ((i=total-1;i>0;i--)); do
      local func="${FUNCNAME[i]}"
      local src="$(realpath "${BASH_SOURCE[i]}")"
      [[ "$func" == lcc_* || "$func" == "log_call_chain" ]] && continue

      local skip=false
      for s in "${suppress_list[@]}"; do
        [[ "$func" == "$s" || "$src" == "$s" ]] && skip=true
      done
      [[ "$skip" == true ]] && continue

      scr_funcs["$src"]+="$func "
      [[ ! " ${scr_order[*]} " =~ " $src " ]] && scr_order+=("$src")
    done

    declare -A seen_scr
    for scr in "${scr_order[@]}"; do
      [[ -n "${seen_scr[$scr]}" ]] && continue
      seen_scr["$scr"]=1

      short_path="$scr"
      if [[ "$scr" =~ ^/([^/]+)/([^/]+)(/.*)?$ ]]; then
          short_path="/${BASH_REMATCH[1]}/.../$(basename "$scr")"
      fi

      echo "├─ $short_path" >> "$full_path"

      local funcs=(${scr_funcs["$scr"]})
      local prefix="│  "
      for ((j=0;j<${#funcs[@]};j++)); do
        local f="${funcs[j]}"
        local base="$(basename "$scr")"
        local is_last=$(( j == ${#funcs[@]}-1 ))
        local branch="├─"
        [[ $is_last -eq 1 ]] && branch="└─"
        echo "$prefix$branch $f [$base]" >> "$full_path"
        prefix+="│  "
      done
    done

    # --------- Write legend (exclude log files) ---------
    echo "" >> "$full_path"
    echo "Legend:" >> "$full_path"
    declare -A script_map
    for scr in "${scr_order[@]}"; do
      # only include .sh scripts
      [[ "$scr" == *.sh ]] || continue
      script_map["$(basename "$scr")"]="$scr"
    done
    for k in "${!script_map[@]}"; do
      echo "$k -> ${script_map[$k]}" >> "$full_path"
    done

  # --------- List other log files if more than one ---------
  if [[ ${#all_paths[@]} -gt 1 ]]; then
    echo "" >> "$full_path"
    echo "Other Log files:" >> "$full_path"
    for p in "${all_paths[@]}"; do
      echo "${p%%:*}" >> "$full_path"
    done
  fi

  }

  # --------- Write errors ---------
  lcc_write_errors() {
    local full_path="$1"
    if [[ ${#errors_map[@]} -gt 0 ]]; then
      echo "" >> "$full_path"
      echo "Errors:" >> "$full_path"
      for k in "${!errors_map[@]}"; do
        echo "  $k → ${errors_map[$k]}" >> "$full_path"
      done
    fi
  }

  # --------- Write logs ---------
  lcc_write_logs() {

    for full_path_and_flag in "${usable_paths[@]}"; do
      local full_path="${full_path_and_flag%%:*}"
      local existed_before="${full_path_and_flag##*:}"

      if [[ "$existed_before" == true ]]; then
        echo "" >> "$full_path"
        echo "==================== NEW LOG ENTRY ====================" >> "$full_path"
        echo "" >> "$full_path"
      fi

      lcc_write_callchain "$full_path" "$status" "$message" suppress_list[@] usable_paths[@] errors_map
      lcc_write_errors "$full_path"

    done

  }

  # --------- Main execution ---------
  lcc_validate_dirs
  lcc_resolve_files
  lcc_write_logs

  return 0
}
