#!/bin/bash



# FUNCTION: write_log
# Writes a log message or keyword marker to logfile and optionally terminal.
#
# Arguments:
#   $1 - Log message or keyword ("start", "end", "line", etc.)
#   $2 - Optional template name
#   $3 - Optional additional template value
#
# Returns:
#   0 on success.
#   2 on failure with an error message via error_exit.

write_log() {

  if [ -z "$LOGFILE" ]; then
    error_exit "logfile is not set. Please call start_log first!" 2
    return 2
  fi

  local log_message="$1"
  local template="$2"
  local template_value="$3"

  # If template is specified, try to use corresponding function
  if [ -n "$template" ]; then
    template="${template,,}"  # to lowercase
    [[ "$template" =~ _log_template$ ]] || template="${template}_log_template"

    if declare -f "$template" >/dev/null 2>&1; then
      log_message="$("$template" "$log_message" "$template_value")"
    else
      error_exit "Unknown template function: '$template'" 2
      return 2
    fi
  fi

  # If no template, check for keyword functions like start_log_keyword etc.
  if [ -z "$template" ]; then
    local keyword="${log_message,,}"
    [[ "$keyword" =~ _log_keyword$ ]] || keyword="${keyword}_log_keyword"

    if declare -f "$keyword" >/dev/null 2>&1; then
      log_message="$("$keyword")"
    else
      # Format standard log line with timestamp and script name depending on LOG_TYPE
      if [[ "${LOG_TYPE,,}" == "multi" ]]; then
        log_message="[$(date +"$LOG_TIME_FORMAT")][$(basename "$0")] $log_message"
      else
        log_message="[$(date +"$LOG_TIME_FORMAT")] $log_message"
      fi
    fi
  fi

  # Output to terminal optionally and always append to logfile
  if [[ "${SHOW_LOG_IN_TERMINAL,,}" == "true" ]]; then
    echo -e "$log_message" | tee -a "$LOGFILE"
  else
    echo -e "$log_message" >> "$LOGFILE"
  fi

  # Ensure ownership of the log file
  set_ownership_file || return $?

}
