#!/usr/bin/env bash

# ========================================================================================
# Bash Log Message Function
#
#
# @author      : Marcel Gräfen
# @version     : 0.0.0-beta.01
# @date        : 2025-09-03
#
# @requires    : Bash 4.3+
#
# @see         : https://github.com/Marcel-Graefen/Bash-Function-Collection/
#
# @copyright   : Copyright (c) 2025 Marcel Gräfen
# @license     : MIT License
# ========================================================================================

#---------------------- FUNCTION: -log_msg-----------------------------------
#
# @version 0.0.0-beta.01
#
# Logs messages with different severity levels: INFO, WARNING, ERROR, or custom.
# Supports hierarchical function call tracing and configurable output behavior.
#
# GLOBAL DEFAULTS:
#   SHOW_LOG_IN_TERMINAL  - If true, prints INFO and WARNING messages to terminal
#   SHOW_WARNING          - If true, WARNING messages are displayed
#   LOG_ON_ERROR_EXIT     - If true, ERROR messages exit the script; otherwise return 2
#
# USAGE:
#   log_msg <TYPE> <MESSAGE>
#
# PARAMETERS:
#   TYPE    - Severity level: INFO, WARNING, ERROR, or custom
#   MESSAGE - Message string to log
#
# FEATURES:
#   - Prepends the call chain (function hierarchy) to the log message
#   - Uses icons for WARNING (⚠) and ERROR (❌) messages
#   - Respects global configuration variables for flexible logging behavior
#
# RETURN:
#   - INFO/WARNING: always returns 0
#   - ERROR: returns 2 or exits (depending on LOG_ON_ERROR_EXIT)


# Global defaults
: "${SHOW_LOG_IN_TERMINAL:=true}"   # steuert, ob Meldungen im Terminal angezeigt werden
: "${SHOW_WARNING:=true}"           # steuert, ob WARNINGS angezeigt werden
: "${LOG_ON_ERROR_EXIT:=false}"     # steuert, ob ERROR ein exit auslöst oder nur return

log_msg() {
  local type="$1"
  shift || true

  # Call chain
  local chain=""
  for ((i=${#FUNCNAME[@]}-1; i>0; i--)); do
    [[ "${FUNCNAME[i]}" == "log_msg" ]] && continue
    chain+="${FUNCNAME[i]}"
    (( i > 1 )) && chain+="->"
  done
  chain="${chain:-MAIN}"

  case "$type" in
    INFO)
      [[ "$SHOW_LOG_IN_TERMINAL" == "true" ]] && echo "[INFO][$chain] $*" >&2
      ;;
    WARNING)
      if [[ "$SHOW_LOG_IN_TERMINAL" == "true" ]] || [[ "${SHOW_WARNING:-true}" != "false" ]]; then
        echo "⚠ [WARNING][$chain] $*" >&2
      fi
      ;;
    ERROR)
      echo "❌ [ERROR][$chain] $*" >&2
      if [[ "$LOG_ON_ERROR_EXIT" == "true" ]]; then
        exit 1
      else
        return 2
      fi
      ;;
    *)
      echo "[$type][$chain] $*" >&2
      ;;
  esac
}
