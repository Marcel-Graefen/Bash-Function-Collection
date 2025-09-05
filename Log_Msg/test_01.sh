#!/bin/bash

log_to_console() {

  # --------- Check parameters ---------
  if [[ $# -eq 0 ]]; then
    echo "❌ [ERROR] No parameters provided"
    return 1
  fi

  # --------- Helper to check values ---------
  log_check_value() {
    local forbidden_flags=("-s" "--status" "-m" "--message" "-D" "--details" "-d" "--dir" "-f" "--file" "-l" "--log")
    [[ -z "$1" ]] && { echo "❌ [ERROR] '$2' requires a value"; exit 1; }
    for f in "${forbidden_flags[@]}"; do
      [[ "$1" == "$f" ]] && { echo "❌ [ERROR] '$2' requires a value, got a flag instead"; exit 1; }
    done
  }

  # --------- Defaults ---------
  local type=""
  local message=""
  local details=""
  local log_dirs=()
  local log_files=()
  local enable_log=false
  local log_path=""

  # --------- Parse parameters ---------
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -s|--status)
        log_check_value "$2" "$1"
        type="$2"
        shift 2
      ;;
      -m|--message)
        log_check_value "$2" "$1"
        message="$2"
        shift 2
      ;;
      -D|--details)
        log_check_value "$2" "$1"
        details="$2"
        shift 2
      ;;
      -d|--dir)
        shift
        while [[ $# -gt 0 && "$1" != "-"* ]]; do
          log_dirs+=("${1%/}")
          shift
        done
      ;;
      -f|--file)
        shift
        while [[ $# -gt 0 && "$1" != "-"* ]]; do
          log_files+=("$1")
          shift
        done
      ;;
      -l|--log)
        if timeout 1s bash -c 'source <(wget -qO- https://raw.githubusercontent.com/Marcel-Graefen/Bash-Function-Collection/refs/heads/main/Log_Call_Chain/log_call_chain.sh)'; then
            enable_log=true
        fi
        shift
      ;;
      *)
        echo "❌ [ERROR] Unknown option: $1"
        return 1
      ;;
    esac
  done

  # --------- Resolve log path if logging enabled ---------
  if $enable_log; then
    if [[ ${#log_files[@]} -eq 0 ]]; then
      log_files=("log_callchain_$$.log")
    fi
    if [[ ${#log_dirs[@]} -eq 0 ]]; then
      log_dirs=("/tmp")
    fi
    # Use first valid combination
    for dir in "${log_dirs[@]}"; do
      mkdir -p "$dir" 2>/dev/null
      for file in "${log_files[@]}"; do
        log_path="$dir/$file"
        touch "$log_path" 2>/dev/null && break 2
      done
    done
  fi

  # --------- Build call chain ---------
  local chain=""
  for ((i=${#FUNCNAME[@]}-1; i>0; i--)); do
    [[ "${FUNCNAME[i]}" == "log_msg" ]] && continue
    [[ "${FUNCNAME[i]}" == "main" ]] && continue
    chain+="${FUNCNAME[i]}"
    (( i > 1 )) && chain+="->"
  done
  [[ -z "$chain" ]] && chain="$(basename "$0")"

  # --------- Select icon ---------
  local icon=""
  case "$type" in
    INFO) icon="💡" ;;
    WARNING) icon="⚠️" ;;
    ERROR) icon="❌" ;;
    *) icon="$type" ;;
  esac

  # --------- Print to console ---------
  echo "[$icon $type][$chain] $message" >&2

  if $enable_log; then
    echo "   ↳ See detailed log here ($log_path)" >&2
    if declare -F log_call_chain >/dev/null 2>&1; then
      log_call_chain -s "$type" -m "$message" -D "$details" -d "${log_dirs[@]}" -f "${log_files[@]}" -x "log_to_console"
    fi
  fi
}


# log_to_console -s WARNING -m "Configuration incomplete"
log_to_console -s ERROR -m "Failed to open file" -D "Permission denied u musst habe sudo or root" -d "/tmp" -f "error.log" -l
