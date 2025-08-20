#!/usr/bin/env bash

# ========================================================================================
# Bash Check Requirements
#
#
# @author      : Marcel Gräfen
# @version     : 1.0.0
# @date        : 2025-08-20
#
# @requires    : Bash 4.0+
#
# @see         : https://github.com/Marcel-Graefen/Bash-Function-Collection/Check%20Requirements
#
# @copyright   : Copyright (c) 2025 Marcel Gräfen
# @license     : MIT License
# ========================================================================================

#---------------------- FUNCTION: check_requirements --------------------------------
# Checks for required Bash version, functions, programs, and alternative program groups.
#
# GLOBAL VARIABLES:
#   None
#
# Uses Functions:
#   None
#
# Arguments:
#   --major|-M NUMBER               Required major Bash version
#   --minor|-m NUMBER               Required minor Bash version (requires --major)
#   --funcs|-f "func1 func2 ..."    Space-separated list of required Bash functions
#   --programs|-p "prog1 prog2 ..." Space-separated list of required programs
#   --programs-alternative|-a "grp" Space-separated list(s) of alternative programs; at least one must exist per group
#   --root|-r|--sudo|-s             Require root privileges
#   -x|--exit                        Exit immediately on first error
#
# Returns:
#   0 on success
#   2 on error (or if -x/--exit is given, exits immediately)
#
# Behavior:
#   - Validates input arguments and ensures --minor is only used with --major
#   - Checks if the current Bash version meets the requested version
#   - Checks for existence of required functions
#   - Checks for existence of required programs
#   - Checks that at least one program exists per alternative group
#   - Optionally enforces root privileges
#   - Errors are printed with ❌ prefix; exit behavior controlled by -x/--exit

check_requirements() {

  # Fail if no arguments provided
  [[ $# -eq 0 ]] && { echo "❌ ERROR: check_requirements: No arguments provided"; return 2; }

  local major_version="" minor_version=""
  local funcs_raw="" progs_raw="" alt_raw=()
  local funcs_list=() progs_list=() alt_groups_list=()
  local require_root=0 exit_on_error=0

  local major_set=0 minor_set=0 funcs_set=0 progs_set=0
  local error_count=0  # Count all errors


  # Helper functions
  check_value() {
    [[ -z "$1" || "$1" == -* ]] && { echo "❌ ERROR: check_requirements: '$2' requires a value"; (( error_count++ )); return 2; }
  }
  is_number() {
    [[ "$1" =~ ^[0-9]+$ ]] || { echo "❌ ERROR: check_requirements: '$2' must be a number"; (( error_count++ )); return 2; }
  }


  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --major|-M)
        ((major_set)) && { echo "❌ ERROR: check_requirements: --major/-M can only be specified once"; (( error_count++ )); }
        check_value "$2" "$1"
        is_number "$2" "$1"
        major_version="$2"; major_set=1; shift 2
        ;;
      --minor|-m)
        ((minor_set)) && { echo "❌ ERROR: check_requirements: --minor/-m can only be specified once"; (( error_count++ )); }
        check_value "$2" "$1"
        is_number "$2" "$1"
        minor_version="$2"; minor_set=1; shift 2
        ;;
      --funcs|-f)
        ((funcs_set)) && { echo "❌ ERROR: check_requirements: --funcs/-f can only be specified once"; (( error_count++ )); }
        check_value "$2" "$1"
        funcs_raw="$2"; funcs_set=1; shift 2
        ;;
      --programs|-p)
        ((progs_set)) && { echo "❌ ERROR: check_requirements: --programs/-p can only be specified once"; (( error_count++ )); }
        check_value "$2" "$1"
        progs_raw="$2"; progs_set=1; shift 2
        ;;
      --programs-alternative|-a)
        check_value "$2" "$1"
        alt_raw+=("$2"); shift 2
        ;;
      --root|-r|--sudo|-s)
        require_root=1; shift
        ;;
      -x|--exit)
        exit_on_error=1; shift
        ;;
      *)
        echo "❌ ERROR: check_requirements: Unknown option: $1"
        (( error_count++ )); shift
        ;;
    esac
  done



  # Ensure --minor is only used with --major
  if (( minor_set && ! major_set )); then
    echo "❌ ERROR: check_requirements: --minor/-m requires --major/-M to be specified first"
    (( error_count++ ));
  fi


  # Check root privileges if requested
  if (( require_root )); then
    local uid="${EUID:-$(id -u 2>/dev/null || 1)}"
    (( uid == 0 )) || { echo "❌ ERROR: check_requirements: This script must be run as root"; (( error_count++ )); }
  fi


  # Convert space-separated strings to arrays
  [[ -n "$funcs_raw" ]] && read -r -a funcs_list <<< "$funcs_raw"
  [[ -n "$progs_raw" ]] && read -r -a progs_list <<< "$progs_raw"

  # Convert alternative program groups to arrays
  local tmp_group=()
  for group in "${alt_raw[@]}"; do
    read -r -a tmp_group <<< "$group"
    alt_groups_list+=("$(IFS=' '; echo "${tmp_group[*]}")")
  done


  # Check Bash version
  if [[ -n "$major_version" ]]; then
    local major="$major_version"
    local minor="${minor_version:-0}"
    if (( BASH_VERSINFO[0] < major )) ||
      (( BASH_VERSINFO[0] == major && BASH_VERSINFO[1] < minor )); then
        echo "❌ ERROR: check_requirements: This script requires Bash ${major}.${minor} or newer"
        (( error_count++ ))
    fi
  fi


  # Check required functions
  for func in "${funcs_list[@]}"; do
    declare -F "$func" >/dev/null 2>&1 || { echo "❌ ERROR: check_requirements: Required function '$func' not found"; (( error_count++ )); }
  done


  # Check required programs
  for prog in "${progs_list[@]}"; do
    ! command -v "$prog" >/dev/null 2>&1 && { echo "❌ ERROR: check_requirements: Missing required program '$prog'"; (( error_count++ )); }
  done


  # Check alternative program groups
  for group in "${alt_groups_list[@]}"; do
    local ok=false
    for prog in $group; do
      command -v "$prog" >/dev/null 2>&1 && { ok=true; break; }
    done
    ! $ok && { echo "❌ ERROR: check_requirements: Need at least one of [$group], none found"; (( error_count++ )); }
  done


  # Exit or return if any error occurred
  (( error_count > 0 )) && { (( exit_on_error )) && exit 2 || return 2; }

  return 0

}
