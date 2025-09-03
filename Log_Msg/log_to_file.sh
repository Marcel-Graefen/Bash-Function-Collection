#!/usr/bin/env bash

log_call_chain() {

  [[ $# -eq 0 ]] && { echo "[ERROR] No parameters provided"; exit 1; }

  local status=""
  local message=""
  local dirs=("/tmp")
  local files=("log_callchain_$$.log")
  local other_logs=()
  declare -A errors_map
  local created_at_least_one=false

  # ----------------- HELPER -----------------
  check_value() {
    local forbidden_flags=("-s" "--status" "-m" "--message" "--msg" "-d" "--dir" "-f" "--file")
    [[ -z "$1" ]] && { echo "[ERROR] '$2' requires a value"; exit 1; }
    for f in "${forbidden_flags[@]}"; do
      [[ "$1" == "$f" ]] && { echo "[ERROR] '$2' requires a value, got a flag instead"; exit 1; }
    done
  }

  # ----------------- PARSE ARGUMENTS -----------------
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -s|--status) check_value "$2" "$1"; status="${2^^}"; shift 2 ;;
      -m|--message|--msg) check_value "$2" "$1"; message="$2"; shift 2 ;;
      -d|--dir) shift; while [[ $# -gt 0 && "$1" != "-"* ]]; do dirs+=("$1"); shift; done ;;
      -f|--file) shift; while [[ $# -gt 0 && "$1" != "-"* ]]; do files+=("$1"); shift; done ;;
      *) echo "ERROR: Unknown option: $1"; exit 1 ;;
    esac
  done

  local log_status="${status:-INFO}"
  local log_message="${message:-No message provided}"

  # ----------------- CREATE LOG FILES -----------------
  for dir in "${dirs[@]}"; do
    if [[ ! -d "$dir" ]]; then
      mkdir -p "$dir" 2>/dev/null || {
        for file in "${files[@]}"; do
          local full_path="$dir/$file"
          errors_map["$full_path"]="Create Folder failed | no Permission"
        done
        continue
      }
    fi

    for file in "${files[@]}"; do
      local full_path="$dir/$file"
      { : > "$full_path"; } 2>/dev/null || { errors_map["$full_path"]="Create File failed | no Permission"; continue; }

      created_at_least_one=true
      other_logs+=("$full_path")

      # ----------------- HEADER -----------------
      {
        echo "Date: $(date +"%Y-%m-%d %H:%M:%S")"
        echo "Status: $log_status"
        echo "Message: $log_message"
        echo "Call chain:"
        echo ""
      } > "$full_path"

      # ----------------- BUILD CALL CHAIN -----------------
      local total=${#FUNCNAME[@]}
      local -a entries=()
      for ((i=total-1; i>0; i--)); do
        [[ "${BASH_SOURCE[i]}" != "${BASH_SOURCE[i-1]}" ]] && entries+=("$(realpath "${BASH_SOURCE[i]}")")
        [[ "${FUNCNAME[i]}" != "log_call_chain" ]] && entries+=("${FUNCNAME[i]}")
      done

      # log_call_chain nur am Ende, wenn direkt aus Skript aufgerufen
      if [[ "${FUNCNAME[1]}" == "main" ]]; then
        entries+=("log_call_chain")
      fi

      # ----------------- PRINT TREE -----------------
      local depth=0
      local n=${#entries[@]}
      for ((i=0; i<n; i++)); do
        local prefix="|"
        for ((j=1; j<depth; j++)); do prefix+="  │"; done
        if (( i == n-1 )); then
          echo "${prefix}  └─ ${entries[i]}" >> "$full_path"
        else
          echo "${prefix}  ├─ ${entries[i]}" >> "$full_path"
        fi
        ((depth++))
      done

      # ----------------- ERRORS direkt unter Datei -----------------
      if [[ -n "${errors_map[$full_path]}" ]]; then
        IFS="|" read -r e1 e2 <<< "${errors_map[$full_path]}"
        echo "" >> "$full_path"
        echo "|  ├─ $e1" >> "$full_path"
        echo "|  └─ $e2" >> "$full_path"
      fi
    done
  done

  ! $created_at_least_one && { echo "FATAL: No log file could be created."; exit 1; }

  # ----------------- OTHER LOG FILES -----------------
  if [[ ${#other_logs[@]} -gt 1 ]]; then
    for path in "${other_logs[@]}"; do
      echo "" >> "$path"
      echo "Other Log files:" >> "$path"
      for file in "${other_logs[@]}"; do
        echo "|  $file" >> "$path"
        if [[ -n "${errors_map[$file]}" ]]; then
          IFS="|" read -r e1 e2 <<< "${errors_map[$file]}"
          echo "|  ├─ $e1" >> "$path"
          echo "|  └─ $e2" >> "$path"
        fi
      done
    done
  fi
}




log_call_chain -m "hallo"
