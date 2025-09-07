#!/usr/bin/env bash

source ./parse_case_flags.sh

# --------- Main function ---------
Write_File() {
  local dirs=()
  local files=()
  local verbose=false
  local numbers=()
  local letters=()
  local files_forbidden=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--dir)
        shift
        parse_case_flags "-d" dirs -i "$@" || return 1
        shift ${#dirs[@]}
        ;;
      -f|--file)
        shift
        parse_case_flags "-f" files --array -i "$@" || return 1
        shift ${#files[@]}
        ;;
      -v|--verbose)
        parse_case_flags "-v" verbose --toggle || return 1
        ;;
      -n|--number)
        shift
        parse_case_flags "-n" numbers --array --number -i "$@" || return 1
        shift ${#numbers[@]}
        ;;
      -l|--letters)
        shift
        parse_case_flags "-l" letters --array --letters -i "$@" || return 1
        shift ${#letters[@]}
        ;;
      -x|--forbid)
        shift
        parse_case_flags "-x" files --array --forbid "!@#" -i "$@" || return 1
        shift ${#files[@]}
        ;;
      -k|--forbid_full)
        shift
        forbidden_values=("hallo" "error_file")
        parse_case_flags "--forbid-full" files --array --forbid-full "${forbidden_values[@]}" #-i "$@" || return 1
        shift ${#files[@]}
        ;;
      *)
        echo "❌ [ERROR] Unknown parameter: $1"
        return 1
        ;;
    esac
  done

  if [[ ${#dirs[@]} -eq 0 ]]; then
    echo "❌ [ERROR] dirs not set. Use -d|--dir"
    return 1
  fi

  if [[ ${#files[@]} -eq 0 ]]; then
    echo "❌ [ERROR] files not set. Use -f|--file"
    return 1
  fi



  # --- Output ---
  echo "Dirs: ${dirs[*]}"
  echo "Files: ${files[*]}"
  echo "Numbers: ${numbers[*]}"
  echo "Letters: ${letters[*]}"
  echo "Verbose: $verbose"
}

# ---------------- Example call ----------------
input=("test_file" "hallo" "safe_file" "error_file")

Write_File -d "hallo" -f "wow"
