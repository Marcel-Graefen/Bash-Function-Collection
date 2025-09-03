#!/usr/bin/env bash

log_call_chain() {

  [[ $# -eq 0 ]] && { echo "[ERROR] No parameters provided"; exit 1; }

  local status=""
  local message=""
  local dirs=("/tmp")
  local files=("log_callchain_$$.log")
  local suppress_list=()  # Funktionen oder Skripte, die ausgeblendet werden
  local other_logs=()
  declare -A errors_map
  local created_at_least_one=false

  check_value() {
    local forbidden_flags=("-s" "--status" "-m" "--message" "--msg" "-d" "--dir" "-f" "--file" "-x" "--suppress")
    [[ -z "$1" ]] && { echo "[ERROR] '$2' requires a value"; exit 1; }
    for f in "${forbidden_flags[@]}"; do
      [[ "$1" == "$f" ]] && { echo "[ERROR] '$2' requires a value, got a flag instead"; exit 1; }
    done
  }

  # --- ARGUMENTE PARSEN ---
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -s|--status) check_value "$2" "$1"; status="${2^^}"; shift 2 ;;
      -m|--message|--msg) check_value "$2" "$1"; message="$2"; shift 2 ;;
      -d|--dir) shift; while [[ $# -gt 0 && "$1" != "-"* ]]; do dirs+=("$1"); shift; done ;;
      -f|--file) shift; while [[ $# -gt 0 && "$1" != "-"* ]]; do files+=("$1"); shift; done ;;
      -x|--suppress) shift; while [[ $# -gt 0 && "$1" != "-"* ]]; do suppress_list+=("$1"); shift; done ;;
      *) echo "ERROR: Unknown option: $1"; exit 1 ;;
    esac
  done

  local log_status="${status:-INFO}"
  local log_message="${message:-No message provided}"

  # --- LOGDATEIEN ERSTELLEN ---
  for dir in "${dirs[@]}"; do
    if [[ ! -d "$dir" ]]; then
      if ! mkdir -p "$dir" 2>/dev/null; then
        errors_map["$dir"]="Folder could not be created"
      fi
    fi

    for file in "${files[@]}"; do
      local full_path="$dir/$file"

      if [[ -d "$dir" ]]; then
        if ! : >> "$full_path" 2>/dev/null; then
          errors_map["$full_path"]="File could not be created"
        else
          created_at_least_one=true
        fi
      else
        errors_map["$full_path"]="File could not be created (folder missing)"
      fi

      other_logs+=("$full_path")

      # --- HEADER UND TRENNUNG ---
      if [[ -f "$full_path" ]]; then
        echo "" >> "$full_path"
        echo "==================== NEW LOG ENTRY ====================" >> "$full_path"
        echo "Date: $(date +"%Y-%m-%d %H:%M:%S")" >> "$full_path"
        [[ -n "$status" ]] && echo "Status: $log_status" >> "$full_path"
        [[ -n "$message" ]] && echo "Message: $log_message" >> "$full_path"
        [[ ${#suppress_list[@]} -gt 0 ]] && echo "Suppressed: ${suppress_list[*]}" >> "$full_path"
        echo "Call chain:" >> "$full_path"
        echo "" >> "$full_path"

        # --- DYNAMISCHE CALL CHAIN MIT SUPPRESSION ---
        local total=${#FUNCNAME[@]}
        local -a entries=()
        for ((i=total-1; i>0; i--)); do
          local func="${FUNCNAME[i]}"
          local src="$(realpath "${BASH_SOURCE[i]}")"

          # Prüfen, ob Funktion oder Skript in suppress_list ist
          local skip=false
          for s in "${suppress_list[@]}"; do
            [[ "$func" == "$s" || "$src" == "$s" ]] && skip=true
          done

          # Nur aufnehmen, wenn nicht geskippt
          [[ "$skip" == false && "$func" != "main" && "$func" != "log_call_chain" ]] && entries+=("$func")
          [[ "$skip" == false && "$src" != "${BASH_SOURCE[i-1]}" ]] && entries+=("$src")
        done

        # --- PRINT TREE ---
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

        # --- ERRORS direkt unter Datei ---
        if [[ -n "${errors_map[$full_path]}" ]]; then
          echo "" >> "$full_path"
          echo "└─ [ERROR] ${errors_map[$full_path]}" >> "$full_path"
        fi
      fi
    done
  done

  if ! $created_at_least_one; then
    echo "FATAL: No log file could be created."
    exit 1
  fi

  # --- OTHER LOG FILES ---
  if [[ ${#other_logs[@]} -gt 1 ]]; then
    for path in "${other_logs[@]}"; do
      [[ -f "$path" ]] || continue
      echo "" >> "$path"
      echo "Other Log files:" >> "$path"
      for file in "${other_logs[@]}"; do
        echo "|  $file" >> "$path"
        [[ -n "${errors_map[$file]}" ]] && echo "|  └─ [ERROR] ${errors_map[$file]}" >> "$path"
      done
    done
  fi
}
