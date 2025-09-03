#!/bin/bash

#---------------------- FUNCTION: log_to_console --------------------------------
#
# @version 0.0-beta.03
#
# Logs messages to the terminal (console) with severity levels and function call chain.
#
# Features:
#   - Supports standard log types: INFO, WARNING, ERROR
#   - Supports custom log types
#   - Displays the function call chain or script name for debugging
#   - Conditional logging based on global flags:
#       • TERM_LOG_ACTIVE: controls visibility of INFO/WARNING messages
#       • TERM_LOG_WARN: allows/disables WARNING messages (default: true)
#       • TERM_LOG_EXIT_ON_ERROR: exits script on ERROR if set to true
#   - Uses visual markers for warnings (⚠) and errors (❌)
#
# GLOBAL VARIABLES:
#   TERM_LOG_ACTIVE        - true/false, whether INFO/WARNING logs are displayed
#   TERM_LOG_WARN          - true/false, whether WARNING logs are displayed
#   TERM_LOG_EXIT_ON_ERROR - true/false, whether ERROR logs exit the script
#
# Arguments:
#   $1  - Log type (INFO, WARNING, ERROR, or custom)
#   $*  - Log message to display
#
# Returns:
#   0  on success (INFO, WARNING, or custom logs)
#   2  if type is ERROR and TERM_LOG_EXIT_ON_ERROR is not true
#   exits 1 if type is ERROR and TERM_LOG_EXIT_ON_ERROR is true
#
# Notes:
#   - Call chain helps identify the origin of the log message
#   - ERROR logs are always shown regardless of TERM_LOG_ACTIVE
#   - Warnings can be suppressed by setting TERM_LOG_WARN=false
#   - Intended for interactive scripts and debugging in terminal

log_to_console() {

  # First argument defines the log type (INFO, WARNING, ERROR, or custom)
  local type="$1"
  # Shift arguments so $* contains only the log message
  shift || true

  # Build a call chain (like a function stack trace)
  local chain=""
  for ((i=${#FUNCNAME[@]}-1; i>0; i--)); do
    # Skip the helper "log_msg" if present in the call stack
    [[ "${FUNCNAME[i]}" == "log_msg" ]] && continue
    # Skip "main" because we want the script name instead
    [[ "${FUNCNAME[i]}" == "main" ]] && continue
    # Append the function name to the chain
    chain+="${FUNCNAME[i]}"
    # Add "->" between function names for readability
    (( i > 1 )) && chain+="->"
  done

  # If no functions in the chain, default to the script name
  [[ -z "$chain" ]] && chain="$(basename "$0")"

  case "$type" in
    INFO)
      # Print INFO messages only if TERM_LOG_ACTIVE is enabled
      [[ "${TERM_LOG_ACTIVE:-true}" == "true" ]] && echo "[INFO][$chain] $*" >&2
      ;;
    WARNING)
      # Print WARNING messages if logging is enabled OR warnings are not disabled
      if [[ "${TERM_LOG_ACTIVE:-true}" == "true" ]] || [[ "${TERM_LOG_WARN:-true}" != "false" ]]; then
        echo "⚠️  [WARNING][$chain] $*" >&2
      fi
      ;;
    ERROR)
      # Always print ERROR messages
      echo "❌ [ERROR][$chain] $*" >&2
      # If TERM_LOG_EXIT_ON_ERROR is set, exit the whole script
      if [[ "${TERM_LOG_EXIT_ON_ERROR:-true}" == "true" ]]; then
        exit 1
      else
        # Otherwise return error code 2 so the caller can handle it
        return 2
      fi
      ;;
    *)
      # For unknown/custom log types just print them as-is
      echo "[$type][$chain] $*" >&2
      ;;
  esac

}



write_log() {

  # ----------------- No PARAMETER -----------------
  if [[ $# -eq 0 ]]; then
    log_to_console ERROR "No parameters provided"
    return $?
  fi

  # --------- Defaults -----------------
  local inputs=()
  local output=""
  local perms=() _perms=()
  local processed=() processed_missing=()
  local types=("file" "dir")
  local seperator="|"

  # ----------------- Helper -----------------
  check_value() {
    local forbidden_flags=("-i" "-d" "-f" "-o" "--input" "--dir" "--file" "--output")
    [[ -z "$1" ]] && { log_to_console ERROR "'$2' requires a value"; return $?; }
    for f in "${forbidden_flags[@]}"; do
      [[ "$1" != "$f" ]] || { log_to_console ERROR "'$2' requires a value, got a flag instead"; return $?; }
    done
  }

  # --------- Parse arguments ---------
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i|--input|-d|--dir|-f|--file)
        shift
        while [[ $# -gt 0 && "$1" != "-"* ]]; do
          inputs+=("$1")
          shift
        done
        ;;
      -o|--output)
        check_value "$2" "$1" || return $?
        output="$2"
        shift 2
        ;;
      -p|--perm)
        check_value "$2" "$1" || return $?
        perms+=("$2")
        shift 2
        ;;
      -s|--seperator)
        check_value "$2" "$1" || return $?
        seperator="$2"
        shift 2
        ;;
      *)
        log_msg ERROR "Unknown option: $1"
        return $?
        ;;
    esac
  done

}






write_call_chain_tmp() {
  local tmpfile="/tmp/log_callchain_$$.log"
  local msg="$1"

  echo "$msg" > "$tmpfile"
  echo "Call chain (detailliert):" >> "$tmpfile"

  local depth=0
  local prefix=""
  local total=${#FUNCNAME[@]}

  for ((i=total-1; i>0; i--)); do
    [[ "${FUNCNAME[i]}" == "write_call_chain_tmp" ]] && continue
    [[ "${FUNCNAME[i]}" == "log_to_console" ]] && continue
    [[ "${FUNCNAME[i]}" == "main" ]] && continue

    local entry
    # Prüfen, ob es ein Skript oder eine Funktion ist
    if [[ -n "${BASH_SOURCE[i]}" && "${BASH_SOURCE[i]}" != "${BASH_SOURCE[i-1]}" ]]; then
      entry="${BASH_SOURCE[i]}"
    else
      entry="${FUNCNAME[i]}"
    fi

    # Formatierung für verschachtelte Struktur
    if (( depth == 0 )); then
      prefix=""
      echo "$entry" >> "$tmpfile"
    else
      # Alle außer letzten Einträge bekommen ├─, letzte └─
      local line_prefix="$(printf '│  %.0s' $(seq 1 $((depth-1))))"
      line_prefix+="├─ "
      echo "${line_prefix}${entry}" >> "$tmpfile"
    fi

    ((depth++))
  done

  echo "$tmpfile"
}






log_status = INFO( wann habe ich gesagt mach das wixxer änder das in "No Status providet")
wie kommst du auf die SCHEIẞ ide "FATAL" zu NUTZEN =????? schreib wie ÜBERALL ❌(ICON) [ERROR]

Vorschläge für eine sauberere Variante:
- Default-Datei nur setzen, wenn keine Files angegeben
  - Solltest DU eh schon machen IDIOT

