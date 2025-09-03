#!/usr/bin/env bash

log_call_chain() {
  [[ $# -eq 0 ]] && { echo "[ERROR] No parameters provided"; exit 1; }

  local status=""
  local message=""
  local dirs=()
  local files=()
  local suppress_list=()
  declare -A errors_map
  local created_at_least_one=false

  local default_dir="/tmp"
  local default_file="log_callchain_$$.log"

  check_value() {
    local forbidden_flags=("-s" "--status" "-m" "--message" "--msg" "-d" "--dir" "-f" "--file" "-x" "--suppress")
    [[ -z "$1" ]] && { echo "[ERROR] '$2' requires a value"; exit 1; }
    for f in "${forbidden_flags[@]}"; do
      [[ "$1" == "$f" ]] && { echo "[ERROR] '$2' requires a value, got a flag instead"; exit 1; }
    done
  }

  # --- Argumente parsen und Pfad bereinigen ---
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -s|--status) check_value "$2" "$1"; status="${2^^}"; shift 2 ;;
      -m|--message|--msg) check_value "$2" "$1"; message="$2"; shift 2 ;;
      -d|--dir) shift; while [[ $# -gt 0 && "$1" != "-"* ]]; do dirs+=("${1%/}"); shift; done ;;
      -f|--file) shift; while [[ $# -gt 0 && "$1" != "-"* ]]; do files+=("$1"); shift; done ;;
      -x|--suppress) shift; while [[ $# -gt 0 && "$1" != "-"* ]]; do suppress_list+=("$1"); shift; done ;;
      *) echo "ERROR: Unknown option: $1"; exit 1 ;;
    esac
  done

  [[ ${#dirs[@]} -eq 0 ]] && dirs=("$default_dir")
  [[ ${#files[@]} -eq 0 ]] && files=("$default_file")

  # --- Alle Pfade kombinieren ---
  local all_paths=()
  for file in "${files[@]}"; do
    if [[ "$file" = /* ]]; then
      # Absoluter Pfad, Verzeichnis ignorieren
      all_paths+=("$file")
    else
      for dir in "${dirs[@]}"; do
        all_paths+=("$dir/$file")
      done
    fi
  done

  local usable_paths=()
  local default_used=false

  # --- Zuerst alle Verzeichnisse prüfen ---
  local valid_dirs=()
  for dir in "${dirs[@]}"; do
    if [[ ! -d "$dir" ]]; then
      errors_map["$dir"]="Folder does not exist"
      continue
    elif [[ ! -w "$dir" ]]; then
      errors_map["$dir"]="No permission to write folder"
      continue
    fi
    valid_dirs+=("$dir")
  done

  # --- Default fallback nur wenn KEIN Verzeichnis nutzbar ---
  if [[ ${#valid_dirs[@]} -eq 0 ]]; then
    # Prüfe, ob files absolute Pfade enthalten
    local abs_file=""
    for file in "${files[@]}"; do
      if [[ "$file" = /* ]]; then
        abs_file="$file"
        break
      fi
    done
    if [[ -n "$abs_file" ]]; then
      # Versuche, absolute Datei direkt zu nutzen
      if touch "$abs_file" 2>/dev/null; then
        usable_paths=("$abs_file")
        default_used=false
      else
        errors_map["$abs_file"]="Cannot create file"
        error_found=true
      fi
    else
      # Nimm den Namen aus -f, falls gesetzt, sonst default_file
      local fallback_file="${files[0]:-$default_file}"
      mkdir -p "$default_dir" 2>/dev/null
      : > "$default_dir/$fallback_file" 2>/dev/null
      usable_paths=("$default_dir/$fallback_file")
      default_used=true
    fi
  else
    # --- Jetzt alle Datei-Pfade prüfen ---
    for dir in "${valid_dirs[@]}"; do
      for file in "${files[@]}"; do
        local use_path="$dir/$file"
        local existed_before=false
        [[ -f "$use_path" ]] && existed_before=true

        if [[ -e "$use_path" ]]; then
          if [[ ! -w "$use_path" ]]; then
            errors_map["$use_path"]="File exists but not writable"
            error_found=true
            continue
          else
            usable_paths+=("$use_path:$existed_before")
            created_at_least_one=true
          fi
        else
          if touch "$use_path" 2>/dev/null; then
            usable_paths+=("$use_path:$existed_before")
            created_at_least_one=true
          else
            errors_map["$use_path"]="Cannot create file"
            error_found=true
            continue
          fi
        fi
      done
    done
    # ACHTUNG: KEIN Default setzen, wenn usable_paths leer bleibt!
    # Fehler werden unten gemeldet und Skript ggf. beendet.
  fi

  # --- Log schreiben ---
  for full_path_and_flag in "${usable_paths[@]}"; do
    local full_path="${full_path_and_flag%%:*}"
    local existed_before="${full_path_and_flag##*:}"

    if [[ "$existed_before" == true ]]; then
      echo "" >> "$full_path"
      echo "==================== NEW LOG ENTRY ====================" >> "$full_path"
      echo "" >> "$full_path"
    fi

    # Header
    echo "Date: $(date +"%Y-%m-%d %H:%M:%S")" >> "$full_path"
    [[ -n "$status" ]] && echo "Status: $status" >> "$full_path"
    [[ -n "$message" ]] && echo "Message: $message" >> "$full_path"
    [[ ${#suppress_list[@]} -gt 0 ]] && echo "Suppressed: ${suppress_list[*]}" >> "$full_path"

    # Call chain
    echo "Call chain:" >> "$full_path"
    echo "" >> "$full_path"
    local total=${#FUNCNAME[@]}
    local -a entries=()
    for ((i=total-1; i>0; i--)); do
      local func="${FUNCNAME[i]}"
      local src="$(realpath "${BASH_SOURCE[i]}")"
      local skip=false
      for s in "${suppress_list[@]}"; do
        [[ "$func" == "$s" || "$src" == "$s" ]] && skip=true
      done
      [[ "$skip" == false && "$func" != "main" && "$func" != "log_call_chain" ]] && entries+=("$func")
      [[ "$skip" == false && "$src" != "${BASH_SOURCE[i-1]}" ]] && entries+=("$src")
    done

    local depth=0
    local n=${#entries[@]}
    for ((i=0; i<n; i++)); do
      local prefix=""
      for ((j=1; j<depth; j++)); do prefix+="│  "; done
      if (( i == n-1 )); then
        echo "${prefix}└─ ${entries[i]}" >> "$full_path"
      else
        echo "${prefix}├─ ${entries[i]}" >> "$full_path"
      fi
      ((depth++))
    done

    # Other Log files inkl. Fehler
    echo "" >> "$full_path"
    echo "Other Log files:" >> "$full_path"
    for file in "${all_paths[@]}"; do
      local dir_name="$(dirname "$file")"
      if [[ -n "${errors_map[$dir_name]}" ]]; then
        echo "|  $dir_name" >> "$full_path"
        echo "|  └─ [ERROR] ${errors_map[$dir_name]}" >> "$full_path"
      elif [[ -n "${errors_map[$file]}" ]]; then
        echo "|  $file" >> "$full_path"
        echo "|  └─ [ERROR] ${errors_map[$file]}" >> "$full_path"
      else
        echo "|  $file" >> "$full_path"
      fi
    done
  done

  # Fehler am Ende melden und Skript ggf. mit Fehlercode beenden
  if [[ "$error_found" == true ]]; then
    echo "[ERROR] Mindestens ein Logfile konnte nicht geschrieben werden." >&2
    exit 1
  fi
}
