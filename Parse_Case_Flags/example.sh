#!/usr/bin/env bash
# Demo: create_folder mit parse_case_flags

source "./parse_case_flags.sh"

directories=()
files=()
depth=1
exists=2
suffix="_(count)"
force=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--dir|--directory)
      parse_case_flags --name "directories" --return tmpdir --array -i "$@" || exit 1
      directories+=("${tmpdir[@]}")
      shift "${#tmpdir[@]}"
      shift 1
      ;;
    -f|--file)
      parse_case_flags --name "files" --return tmpfile --array -i "$@" || exit 1
      files+=("${tmpfile[@]}")
      shift "${#tmpfile[@]}"
      shift 1
      ;;
    -D|--depth)
      parse_case_flags --name "depth" --return depth -i "$2" || exit 1
      shift 2
      ;;
    -e|--exists)
      parse_case_flags --name "exists" --return exists -i "$@" || exit 1
      shift 2
      ;;
    -s|--suffix)
      parse_case_flags --name "suffix" --return suffix -i "$@" || exit 1
      shift 2
      ;;
    -F|--force)
      parse_case_flags -n "force" --toggle || exit 1
      shift 1
      ;;
    *)
      echo "Unbekannte Option: $1" >&2
      exit 1
      ;;
  esac
done

# Demo-Output
echo "=== Demo: create_folder ==="
echo "Directories: ${directories[*]}"
echo "Files: ${files[*]}"
echo "Depth: $depth"
echo "Exists: $exists"
echo "Suffix: $suffix"
echo "Force: $force"


bash demo_create_folder.sh -d "/etc" -d "/home/user" -f "file1.txt" -f "file2.txt" --depth 3 --exists 2 --suffix "_neu" --force


Output Example

# === Demo: create_folder ===
# Directories: /etc /home/user
# Files: file1.txt file2.txt
# Depth: 3
# Exists: 2
# Suffix: _neu
# Force: true
