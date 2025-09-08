#!/usr/bin/env bash

# -------------------------------------------------------------
# Demo Script: Using parse_case_flags
# Version: 1.0.0-beta.01
# Purpose: Demonstrates all features including Arrays, Toggle,
#          Allow/Forbid, Forbid-Full, Dropping, Deduplicate,
#          Number/Letter validation, and Verbose mode
# -------------------------------------------------------------

source ./parse_case_flags.sh

# ----------------- Example Function ------------------------
Process_Files() {
  # ----------------- Variables -----------------------------
  local dirs=()           # Array to store directories
  local files=()          # Array to store files
  local verbose=false     # Toggle flag for verbose output
  local numbers=()        # Array to store numeric values
  local letters=()        # Array to store alphabetic values
  local files_forbidden=()# Array to collect files failing forbidden checks
  local files_allowed=()  # Array to store files passing allowed check
  local files_dropped=()  # Array to collect invalid values (dropping)
  local files_dedup=()    # Array to store deduplicated values

  echo "=== Starting Processing ==="

  # ----------------- Parse CLI Arguments -------------------
  while [[ $# -gt 0 ]]; do
    case "$1" in

      # ---------------------------------
      # Collect directories into an array
      -d|--dir)
        shift
        parse_case_flags --name "Directories" --return dirs --array -i "$@" || return 1
        shift ${#dirs[@]}
        ;;

      # ---------------------------------
      # Collect files into an array
      -f|--file)
        shift
        parse_case_flags --name "Files" --return files --array -i "$@" || return 1
        shift ${#files[@]}
        ;;

      # ---------------------------------
      # Toggle flag to enable verbose output
      -v|--verbose)
        parse_case_flags --name "Verbose" --return verbose --toggle || return 1
        shift
        ;;

      # ---------------------------------
      # Only numeric values allowed
      -n|--number)
        shift
        parse_case_flags --name "Numbers" --return numbers --array --number -i "$@" || return 1
        shift ${#numbers[@]}
        ;;

      # ---------------------------------
      # Only alphabetic values allowed
      -l|--letters)
        shift
        parse_case_flags --name "Letters" --return letters --array --letters -i "$@" || return 1
        shift ${#letters[@]}
        ;;

      # ---------------------------------
      # Forbid specific characters and store invalid values
      -x|--forbid)
        shift
        parse_case_flags --name "Files_Forbid_Chars" --return files --array --forbid "!@#" --dropping files_dropped -i "$@" || return 1
        shift ${#files[@]}
        ;;

      # ---------------------------------
      # Forbid full strings (exact match) and store invalid values
      -k|--forbid_full)
        shift
        forbidden_values=("hallo" "admin" "error_file")
        parse_case_flags --name "Files_Forbid_Full" --return files --array --forbid-full "${forbidden_values[@]}" --dropping files_dropped -i "$@" || return 1
        shift ${#files[@]}
        ;;

      # ---------------------------------
      # Only allow specific characters and remove duplicates
      -a|--allow)
        shift
        parse_case_flags --name "Files_Allowed" --return files_allowed --array --allow "a-zA-Z0-9._" --deduplicate files_dedup -i "$@" || return 1
        shift ${#files_allowed[@]}
        ;;

      # ---------------------------------
      # Unknown parameter
      *)
        echo "❌ [ERROR] Unknown parameter: $1"
        return 1
        ;;
    esac
  done

  # ----------------- Display Results ----------------------
  echo
  echo "=== Results ==="
  echo "Directories: ${dirs[*]}"
  echo "Files: ${files[*]}"
  echo "Numbers: ${numbers[*]}"
  echo "Letters: ${letters[*]}"
  echo "Verbose: $verbose"
  echo "Allowed files: ${files_allowed[*]}"
  echo "Dropped files: ${files_dropped[*]}"
  echo "Deduplicated allowed files: ${files_dedup[*]}"
  echo "===================="
  echo
}

# ----------------- Example Calls -------------------------

# Example 1: Simple array, toggle, and numeric values
echo ">>> Example 1: Array, Toggle, Numbers"
Process_Files \
  -d "output_dir" \
  -f "file1.txt" "file2.log" \
  -v \
  -n "123" "456"

# Example 2: Letters only, allowed/forbidden characters
echo ">>> Example 2: Letters, Allow, Forbid"
Process_Files \
  -f "hello" "world" "bad@file" \
  -l "abc" "XYZ" \
  -a "hello" "world" "safe_file" \
  -x "!@#"

# Example 3: Forbid-Full and Dropping invalid values
echo ">>> Example 3: Forbid-Full and Dropping"
Process_Files \
  -f "admin" "user1" "error_file" \
  -k "admin" "error_file" \
  -d "tmp_dropped" \
  -v

# Example 4: Deduplicate Array
echo ">>> Example 4: Deduplicate"
Process_Files \
  -f "dup1" "dup2" "dup1" "dup2" "unique" \
  -a "dup1" "dup2" "unique" \
  -d "tmp" \
  -D files_dedup

# -------------------------------------------------------------
# End of Demo
# -------------------------------------------------------------
