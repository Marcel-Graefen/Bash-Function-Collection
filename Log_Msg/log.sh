#!/bin/bash

write_log() {

  # --------- Check parameters ---------
  if [[ $# -eq 0 ]]; then
    echo "❌ [ERROR] No parameters provided"
    return 1
  fi

  # --------- Defaults -----------------

  local log_dirs=()
  local log_files=()

  local main_script="$(basename "$0")"
  main_script="${main_script%.*}" # Remove Extension
  local default_log_dir="$(cd "$(dirname "$0")" && pwd)/Log"
  local default_log_file="${main_script}_$$.log"

  local chain_dirs=()
  local chain_files=()
  local chain_status=""
  local chain_message=""
  local chain_details=""
  local chain_suppress_list=()

  local chain_prefix="Call-Chain_"

  # --------- Helper to check values ---------
  check_value() {
    local forbidden_flags=("-ld" "--log_dirs" "-lf" "--log_files" "-cs" "--chain_status" "-cm" "--chain_message" "--chain_msg" "-cD" "--chain_details" "-cd" "--chain_dir" "-cf" "--chain_file" "-cx" "--chain_suppress")
    [[ -z "$1" ]] && { echo "❌ [ERROR] '$2' requires a value"; exit 1; }
    for f in "${forbidden_flags[@]}"; do
      [[ "$1" == "$f" ]] && { echo "❌ [ERROR] '$2' requires a value, got a flag instead"; exit 1; }
    done
  }

  # --------- Parse arguments ---------

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -ld|--log_dir)
        local prev_flag="$1"
        shift
        while [[ $# -gt 0 && "$1" != "-"* ]]; do
          check_value "$1" "$prev_flag"
          log_dirs+=("$1")
          shift
        done
      ;;
      -lf|--log_file)
        local prev_flag="$1"
        shift
        while [[ $# -gt 0 && "$1" != "-"* ]]; do
          check_value "$1" "$prev_flag"
          log_files+=("$1")
          shift
        done
      ;;

      -cd|--chain_dir)
        local prev_flag="$1"
        shift
        while [[ $# -gt 0 && "$1" != "-"* ]]; do
          check_value "$1" "$prev_flag"
          chain_dirs+=("$1")
          shift
        done
      ;;
      -cf|--chain_file)
        local prev_flag="$1"
        shift
        while [[ $# -gt 0 && "$1" != "-"* ]]; do
          check_value "$1" "$prev_flag"
          chain_files+=("$1")
          shift
        done
      ;;
      -cs|--chain_status)
        check_value "$2" "$1"
        chain_status="${2^^}"
        shift 2
      ;;
      -cm|--chain_message|--chain_msg)
        check_value "$2" "$1"
        chain_message="$2"
        shift 2
      ;;
      -cD|--chain_details)
        check_value "$2" "$1"
        chain_details="$2"
        shift 2
      ;;
      -cx|--chain_suppress)
        local prev_flag="$1"
        shift
        while [[ $# -gt 0 && "$1" != "-"* ]]; do
          check_value "$1" "$prev_flag"
          chain_suppress_list+=("$1")
          shift
        done
      ;;
      * )
        echo "❌ [ERROR] Unknown option: $1"
        exit 1
      ;;
    esac
  done

  # --------- Apply defaults Log -----------------
  [[ ${#log_dirs[@]} -eq 0 ]] && log_dirs=("$default_log_dir")
  [[ ${#log_files[@]} -eq 0 ]] && log_files=("$default_log_file")

  # --------- Apply defaults Chain -----------------
  if [[ ${#chain_dirs[@]} -eq 0 ]]; then
    chain_dirs=("${log_dirs[@]}")
  fi

  if [[ ${#chain_files[@]} -eq 0 ]]; then
    for f in "${log_files[@]}"; do
      chain_files+=("${chain_prefix}${f}")
    done
  fi


  wl_validate_dirs() {

    local -n dirs_ref=$1       # Name des Arrays, das geprüft werden soll
    local -n valid_ref=$2      # Name des Arrays für die gültigen Verzeichnisse
    local default_dir="$3"     # Optional: Default-Verzeichnis

    valid_ref=()
    for dir in "${dirs_ref[@]}"; do
      if [[ -d "$dir" && -w "$dir" ]]; then
        valid_ref+=("$dir")
        continue
      fi

      local parent_dir
      parent_dir="$(dirname "$dir")"

      if [[ ! -d "$parent_dir" ]]; then
        echo "❌ [ERROR] Parent folder does not exist: $parent_dir"
        return 1
      fi

      if [[ ! -w "$parent_dir" ]]; then
        echo "❌ [ERROR] Parent folder not writable: $parent_dir"
        return 1
      fi

      if mkdir -p "$dir" 2>/dev/null; then
        valid_ref+=("$dir")
      else
        echo "❌ [ERROR] Cannot create folder: $dir"
        return 1
      fi
    done

    # Falls kein Verzeichnis gültig war, Default verwenden
    if [[ ${#valid_ref[@]} -eq 0 && -n "$default_dir" ]]; then
        if mkdir -p "$default_dir" 2>/dev/null; then
          valid_ref=("$default_dir")
        else
          echo "❌ [ERROR] Cannot create default folder: $default_dir"
          return 1
        fi
    fi

  }


  wl_resolve_files() {

    local -n files_ref=$1        # Array mit den Dateinamen
    local -n dirs_ref=$2         # Array mit gültigen Verzeichnissen (z. B. valid_log_dirs)
    local -n usable_ref=$3       # Array, das die resolvten Dateien speichert

    usable_ref=()

    for file in "${files_ref[@]}"; do
      if [[ "$file" = /* ]]; then
          local existed=false
          [[ -f "$file" ]] && existed=true
          if touch "$file" 2>/dev/null; then
            usable_ref+=("$file:$existed")
          else
            echo "❌ [ERROR] Cannot create file: $file"
            return 1
          fi
      else
        local created_any=false
        for dir in "${dirs_ref[@]}"; do
          local path="$dir/$file"
          local existed=false
          [[ -f "$path" ]] && existed=true
          if touch "$path" 2>/dev/null; then
            usable_ref+=("$path:$existed")
            created_any=true
          else
            echo "❌ [ERROR] Cannot create file: $path"
            return 1
          fi
        done
      fi
    done

  }



  # Log-Verzeichnisse prüfen
  wl_validate_dirs log_dirs valid_log_dirs "$default_log_dir" || return 1
  # Beispiel für Log-Files
  lcc_resolve_files log_files valid_log_dirs usable_log_files || return 1


  # Chain-Verzeichnisse prüfen
  wl_validate_dirs chain_dirs valid_chain_dirs "$default_log_dir" || return 1
  # Beispiel für Chain-Files
  lcc_resolve_files chain_files valid_chain_dirs usable_chain_files || return 1









}
