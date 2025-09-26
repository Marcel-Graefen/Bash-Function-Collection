#!/usr/bin/env bash
# Demo: create_folder mit parse_case_flags (Version 1.1.0)

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
      local rest_params
      parse_case_flags --name "directories" --return directories --array --rest-params rest_params -i "$@" || exit 1
      set -- "${rest_params[@]}"
      ;;

    -f|--file)
      local rest_params
      parse_case_flags --name "files" --return files --array --rest-params rest_params -i "$@" || exit 1
      set -- "${rest_params[@]}"
      ;;

    -D|--depth)
      local rest_params
      parse_case_flags --name "depth" --return depth --rest-params rest_params -i "$@" || exit 1
      set -- "${rest_params[@]}"
      ;;

    -e|--exists)
      local rest_params
      parse_case_flags --name "exists" --return exists --rest-params rest_params -i "$@" || exit 1
      set -- "${rest_params[@]}"
      ;;

    -s|--suffix)
      local rest_params
      parse_case_flags --name "suffix" --return suffix --rest-params rest_params -i "$@" || exit 1
      set -- "${rest_params[@]}"
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
echo "=== Demo: create_folder (v1.1.0) ==="
echo "Directories: ${directories[*]}"
echo "Files: ${files[*]}"
echo "Depth: $depth"
echo "Exists: $exists"
echo "Suffix: $suffix"
echo "Force: $force"


# **Testaufruf:**
bash demo_create_folder.sh -d "/etc" -d "/home/user" -f "file1.txt" -f "file2.txt" --depth 3 --exists 2 --suffix "_neu" --force


# **Erwarteter Output:**

# === Demo: create_folder (v1.1.0) ===
# Directories: /etc /home/user
# Files: file1.txt file2.txt
# Depth: 3
# Exists: 2
# Suffix: _neu
# Force: true


# **Vorteile der neuen Syntax:**
# - ✅ **Keine temporären Variablen** (`tmpdir`, `tmpfile`) mehr nötig
# - ✅ **Kein manuelles Shiften** mit komplizierten Berechnungen
# - ✅ **Einheitliche Syntax** für alle Case-Blöcke
# - ✅ **Weniger Code** pro Case
# - ✅ **Robuster** gegen Parameter-Änderungen

# Die Demo zeigt jetzt die **empfohlene moderne Syntax** mit automatischer Parameter-Weiterleitung! 🚀
