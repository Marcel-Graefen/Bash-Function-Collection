#!/usr/bin/env bash

# ========================================================================================
#  Bash Function Call Manager
#
# @author      : Marcel Gräfen
# @version     : 0.0.1-Beta.01
# @date        : 2025-09-23
#
# @requires    : Bash 4.0+
#
# @see         : https://github.com/Marcel-Graefen/Bash-Function-Call-Manager.git
#
# @copyright   : Copyright (c) 2025 Marcel Gräfen
# @license     : MIT License
# ========================================================================================

source /home/marcel/Git_Public/Bash-Function-Collection/Parse_Case_Flags/parse_case_flags.sh

create_folder() {

  # --------- Defaults -----------------
  local directories=()      # --directory Pfade
  local files=()            # --file Pfade
  local depth=0             # --depth
  local exists="suffix-new" # --exists
  local suffix="_%d"        # --suffix
  local force=false         # --force Toggle

  local dedub_dirs=()
  local dedub_files=()

  local exists_allow=("suffix-new" "suffix-old" "overwrite" "abort")

  # --------- Interne Funktion: Split File Paths ---------
  _split_file_path() {

    local paths=("$@")
    local f dir file
    local result=()

    for f in "${paths[@]}"; do
      if [[ "$f" == "/" ]]; then
        dir="/"
        file=""
        [[ ! " ${directories[*]} " =~ " ${dir} " ]] && directories+=("$dir")
      elif [[ "$f" == */* ]]; then
        dir="${f%/*}"
        file="${f##*/}"
        [[ -n "$dir" && ! " ${directories[*]} " =~ " ${dir} " ]] && directories+=("$dir")
      else
        file="$f"
      fi
      result+=("$file")
    done

    echo "${result[@]}"

  }

  local rest_params=""

  # --------- Argumente parsen ---------
  while [[ $# -gt 0 ]]; do

    case "$1" in
      -d|--dir|--directory)
          parse_case_flags -v -l "directories" --return directories --dedub dedub_dirs --dedub-input "${directories[@]}" --rest-params rest_params -i "$@" || return 1
          set -- "${rest_params[@]}"
          ;;
      -f|--file)
        parse_case_flags -v -l "files" --return files --dedub dedub_files --dedub-input "${files[@]}" --rest-params rest_params -i "$@" || return 1
        set -- "${rest_params[@]}"
        ;;
      -D|--depth)
        parse_case_flags -l "depth" --return depth -n --verbose -M 5 -m "3" -i "$@" || return 1
        shift 2 ;;
      -e|--exists)
        parse_case_flags -l "exists" --return exists --allow-full "${exists_allow[@]}" -v -i "$@" || return 1
        shift 2 ;;
      -s|--suffix)
        parse_case_flags -v -l "suffix" --return suffix -i "$@" || return 1
        shift 2 ;;
      -F|--force)
        parse_case_flags -l "force" -vt --return force || return 1
        shift 1 ;;
      *)
        echo "Unbekannte Option: $1" >&2
        return 1 ;;
    esac
  done

  # --------- Dateien prüfen und Pfade trennen ---------
  # if [[ ${#files[@]} -gt 0 ]]; then
  #   files=($(_split_file_path "${files[@]}"))
  # fi

  # --------- Demo-Ausgabe ---------
  echo "Directories: ${directories[*]}"
  echo "Files: ${files[*]}"
  echo "Depth: $depth"
  echo "Exists: $exists"
  echo "Suffix: $suffix"
  echo "Force: $force"
}

parse_case_flags -h

array=("/etc1" "/home" "/etc")
create_folder -f "${array[@]}" --depth "444" -d "/hallo" -d "/etc" -e overwrite -s "_neu" -d "/haus" -F -d "NEU" -f "/etc"

# GEHT NICHT:
# array=("/etc1" "/home" "/etc")
# create_folder -d "${array[@]}" --depth "4" -e overwrite -f "ausgabe.txt" -d "/etc1" -d "/haus"
