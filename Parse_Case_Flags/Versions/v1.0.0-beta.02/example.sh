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
  local files_allowed=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--dir)
        parse_case_flags -n dir dirs -i "$2" || return 1
        shift 2
        ;;
      -f|--file)
        parse_case_flags -n files --array -i "$@" || return 1
        break
        ;;
      -v|--verbose)
        parse_case_flags -n verbose --toggle || return 1
        ;;
      -n|--number)
        parse_case_flags -n numbers --array --number -i "$@" || return 1
        break
        ;;
      -l|--letters)
        parse_case_flags -n letters --array --letters -i "$@" || return 1
        break
        ;;
      -x|--forbid)
        parse_case_flags -n files --array --forbid "!@#" -i "$@" || return 1
        break
        ;;
      -k|--forbid_full)
        forbidden_values=("hallo" "error_file")
        parse_case_flags -n "--forbid-full files" --array --forbid-full "${forbidden_values[@]}" || return 1
        break
        ;;
      -a|--allow)
        parse_case_flags -n files_allowed --array --allow "a-zA-Z0-9._" -i "$@" || return 1
        break
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
  echo "Allowed files: ${files_allowed[*]}"
}

# ---------------- Example call ----------------
Write_File -d "output_dir" -f "wow" -a "test_file" "okay_123" "BAD!file"
