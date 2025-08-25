#!/usr/bin/env bash

# ========================================================================================
# Bash Classify Paths
#
#
# @author      : Marcel Gräfen
# @version     : 0.0.-beta.01
# @date        : 2025-08-22
#
# @requires    : Bash 4.3+
# @requires    : realpath
# @requires    : Function   =>  Normalize List
#
# @see         : https://github.com/Marcel-Graefen/Bash-Function-Collection/
#
# @copyright   : Copyright (c) 2025 Marcel Gräfen
# @license     : MIT License
# ========================================================================================


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

# Function -> Normaliz List
# source <(wget -qO- "https://raw.githubusercontent.com/Marcel-Graefen/Bash-Function-Collection/refs/heads/main/Normalize_List/normalize_list.sh")

source /home/marcel/Git_Public/Bash-Function-Collection/Normalize_List/normalize_list.sh




#---------------------- FUNCTION: check_perm_mask -----------------------------------
# Checks the file or directory permissions based on a given mask.
#
# GLOBAL VARIABLES:
#   None
#
# Uses Functions:
#   None
#
# Arguments:
#   $1 STRING   Path to the file or directory to check
#   $2 STRING   Permission mask, e.g., "rwx", "rw-", "r--", "-wx"
#
# Returns:
#   0 if the permissions match the mask
#   1 if the permissions do not match
#
# Behavior:
#   - Normalizes the mask into standard order: r, w, x
#   - Keeps '-' as explicit negative checks
#   - Checks positive permissions (r, w, x) and negative permissions ('-')
#   - Supports masks of length 1, 2, or 3
#   - Returns 1 if any required permission is missing or forbidden permission is present
check_perm_mask() {
  local path="$1"
  local rawmask="$2"
  local mask norm=""

  # Normalize: keep letters r, w, x in order; keep '-' for negative checks
  [[ "$rawmask" == *r* ]] && norm+="r"
  [[ "$rawmask" == *w* ]] && norm+="w"
  [[ "$rawmask" == *x* ]] && norm+="x"
  norm+="${rawmask//[rwx]/}" # append all '-' from original mask
  mask="$norm"

  local ok=0
  case ${#mask} in
    1)
      [[ "$mask" == "r" && -r "$path" ]] && ok=1
      [[ "$mask" == "w" && -w "$path" ]] && ok=1
      [[ "$mask" == "x" && -x "$path" ]] && ok=1
      ;;
    2)
      [[ "$mask" == "rw" && -r "$path" && -w "$path" ]] && ok=1
      [[ "$mask" == "rx" && -r "$path" && -x "$path" ]] && ok=1
      [[ "$mask" == "wx" && -w "$path" && -x "$path" ]] && ok=1
      ;;
    3)
      [[ "$mask" == "rwx" && -r "$path" && -w "$path" && -x "$path" ]] && ok=1
      [[ "$mask" == "r--" && -r "$path" && ! -w "$path" && ! -x "$path" ]] && ok=1
      [[ "$mask" == "rw-" && -r "$path" && -w "$path" && ! -x "$path" ]] && ok=1
      [[ "$mask" == "r-x" && -r "$path" && ! -w "$path" && -x "$path" ]] && ok=1
      [[ "$mask" == "-w-" && ! -r "$path" && -w "$path" && ! -x "$path" ]] && ok=1
      [[ "$mask" == "-wx" && ! -r "$path" && -w "$path" && -x "$path" ]] && ok=1
      [[ "$mask" == "--x" && ! -r "$path" && ! -w "$path" && -x "$path" ]] && ok=1
      [[ "$mask" == "---" && ! -r "$path" && ! -w "$path" && ! -x "$path" ]] && ok=1
      ;;
  esac
  return $ok
}




#---------------------- FUNCTION: classify_paths --------------------------------
# Classifies and organizes filesystem paths based on existence and permissions.
#
# Features:
#   - Parses input arguments (-i/--input, -d/--dir, -f/--file)
#   - Normalizes permission masks (via normalize_list)
#   - Expands wildcards (*, **) automatically
#   - Resolves absolute paths (via realpath -m)
#   - Detects missing paths and keeps track separately
#   - Removes duplicates
#   - Classifies paths by:
#       • Type (file, dir, missing)
#       • Permissions according to provided masks (r, w, x, rw, rx, wx, rwx)
#       • Not matching permissions (not-r, not-w, etc.)
#   - Assigns results to caller-provided associative array via nameref
#
# GLOBAL VARIABLES:
#   None
#
# External programs used:
#   realpath
#
# Internal functions used:
#   normalize_list
#   log_msg
#   check_perm_mask
#
# Arguments:
#   -i, --input, -d, --dir, -f, --file    Space-separated list of input paths
#   -o, --output                           Name of the output associative array
#   -p, --perm                             Permission masks to filter paths (optional)
#
# Returns:
#   0  on success
#   1  on error (e.g., missing input, invalid option, or invalid permission mask)
#
# Notes:
#   - Requires at least one input path and an output array name
#   - Handles leading wildcards '**/' and normalizes paths
#   - Errors and warnings are logged via log_msg

classify_paths() {

  # ----------------- No PARAMETER -----------------
  if [[ $# -eq 0 ]]; then
    log_msg ERROR "No parameters provided"
    return $?
  fi

  # --------- Defaults -----------------
  local inputs=()
  local output=""
  local perms=() _perms=()
  local processed=() processed_missing=()
  local types=("file" "dir")


  # ----------------- Helper -----------------
  check_value() {
    local forbidden_flags=("-i" "-d" "-f" "-o" "--input" "--dir" "--file" "--output")
    [[ -z "$1" ]] && { log_msg ERROR "'$2' requires a value"; return $?; }
    for f in "${forbidden_flags[@]}"; do
      [[ "$1" != "$f" ]] || { log_msg ERROR "'$2' requires a value, got a flag instead"; return $?; }
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
        output="$2"      # Nur einmal
        shift 2
        ;;
      -p|--perm)
        check_value "$2" "$1" || return $?
        perms+=("$2")    # Optional mehrfach
        shift 2
        ;;
      *)
        log_msg ERROR "Unknown option: $1"
        return $?
        ;;
    esac
  done


  # --------- Check arguments Values ---------
  (( ${#inputs[@]} )) || { log_msg ERROR "No input paths"; return $?; }
  [[ -n $output ]] || { log_msg ERROR "Output not set"; return $?; }


  # --------- Check for leading /**/ in any input ---------
  for p in "${inputs[@]}"; do
    [[ "$p" == "/**/"* ]] && { log_msg ERROR "Leading '/**/' is not allowed. Try with '**/'."; return $?; }
  done

  # --------- Check Separator ---------
  [[ -n "$sep" && ( "$sep" == *"/"* || "$sep" == *"*"* || "$sep" == *"."* ) ]] && {
    log_msg ERROR "Separator cannot contain /, * or ."
    return $?
  }

  # --------- Check perms ---------
  if (( ${#perms[@]} )); then
    normalize_list -i "${perms[*]}" -o _perms || return $?
    valid_masks=()
    invalid_masks=()
    for m in "${_perms[@]}"; do
      if [[ ! "$m" =~ ^[rwx-]+$ ]]; then
        invalid_masks+=("$m")
      elif (( $(grep -o "r" <<< "$m" | wc -l) > 1 )) \
        || (( $(grep -o "w" <<< "$m" | wc -l) > 1 )) \
        || (( $(grep -o "x" <<< "$m" | wc -l) > 1 )) \
        || (( $(grep -o "-" <<< "$m" | wc -l) > 3 )); then
        invalid_masks+=("$m")
      else
        valid_masks+=("$m")
      fi
    done
    _perms=("${valid_masks[@]}")
    (( ${#valid_masks[@]} == 0 )) && { log_msg ERROR "All permission masks invalid: ${invalid_masks[*]}"; return $?; }
    (( ${#invalid_masks[@]} )) && log_msg WARNING "Some masks ignored: ${invalid_masks[*]}"
  fi


  # --------- Initialize output ---------
  if ! declare -p "$output" &>/dev/null; then
    declare -g -A "$output"
  fi
  declare -n _ref="$output"
  _ref=()
  _ref[all]=""
  _ref[file]=""
  _ref[dir]=""
  _ref[missing]=""


  # --------- Wildcard expansion -----------------
  shopt -s dotglob globstar   # nullglob nicht gesetzt, damit fehlende Wildcards erkannt werden
  for p in "${inputs[@]}"; do
    if [[ "$p" == *"*"* ]]; then
      if compgen -G "$p" > /dev/null; then
        for f in $p; do
          processed+=("$(realpath -m "$f")")
        done
      else
        processed_missing+=("$(realpath -m "$p")")
      fi
    else
    processed+=("$(realpath -m "$p")")
    fi
  done
  shopt -u dotglob globstar


  # --------- Remove duplicates -----------------
  local unique=()
  local unique_missing=()
  declare -A seen seen_missing

  for f in "${processed[@]}"; do
    [[ -z "${seen[$f]}" ]] && { unique+=("$f"); seen[$f]=1; }
  done
  processed=("${unique[@]}")

  for f in "${processed_missing[@]}"; do
    [[ -z "${seen_missing[$f]}" ]] && { unique_missing+=("$f"); seen_missing[$f]=1; }
  done

  # --------- Set Variable -----------------
  _ref[missing]="${processed_missing[@]}"
  _ref[all]="${processed[@]} ${processed_missing[@]}"

  # --------- Separate exist / missing ---------
  for p in "${processed[@]}"; do
    if [[ -d "$p" ]]; then
      type="dir"
      # _ref[dir]+="$p" "# NOTE Original
      # NOTE This Make a | in the string so can we Split
      # BUG Problem with Space in Folder/File Path
      [[ -n "${_ref[dir]}" ]] && _ref[dir]+="|$p" || _ref[dir]="$p"
    elif [[ -f "$p" ]]; then
      type="file"
      # _ref[file]+="$p" "# NOTE Original
      # NOTE This Make a | in the string so can we Split
      # BUG Problem with Space in Folder/File Path
      [[ -n "${_ref[file]}" ]] && _ref[file]+="|$p" || _ref[file]="$p"
    else
      type="missing"
      _ref[missing]+="$p"
    fi
    if [[ -e "$p" ]]; then
      for perm_mask in "${_perms[@]}"; do
        if check_perm_mask "$p" "$perm_mask"; then
          # _ref[$type,$perm_mask,not]+="$p "# NOTE Original
          # NOTE This Make a | in the string so can we Split
          # BUG Problem with Space in Folder/File Path
          [[ -n "${_ref[$type,$perm_mask,not]}" ]] && _ref[$type,$perm_mask,not]+="|$p" || _ref[$type,$perm_mask,not]="$p"

          # _ref[$perm_mask,not]+="$p " "# NOTE Original
          # NOTE This Make a | in the string so can we Split
          # BUG Problem with Space in Folder/File Path
          [[ -n "${_ref[$perm_mask,not]}" ]] && _ref[$perm_mask,not]+="|$p" || _ref[$perm_mask,not]="$p"
        else
          # _ref[$type,$perm_mask]+="$p  "# NOTE Original
          # NOTE This Make a | in the string so can we Split
          # BUG Problem with Space in Folder/File Path
          [[ -n "${_ref[$type,$perm_mask]}" ]] && _ref[$type,$perm_mask]+="|$p" || _ref[$type,$perm_mask]="$p"

          # _ref[$perm_mask]+="$p " "# NOTE Original
          # NOTE This Make a | in the string so can we Split
          # BUG Problem with Space in Folder/File Path
          [[ -n "${_ref[$perm_mask]}" ]] && _ref[$perm_mask]+="|$p" || _ref[$perm_mask]="$p"
        fi
      done
    fi
  done

  return 0

}


#---------------------- EXAMPLE --------------------------------

rein=("/home/marcel/Git_Public/Bash-Function-Collection/test dir/file1.txt" "/home/marcel/Git_Public/Bash-Function-Collection/test dir/file2.txt")
classify_paths -i "${rein[@]}" -o Hallo -p "r w x wr-"

IFS='|' read -r -a File <<< "${Hallo[file]}"
echo "1: ${File[0]}"
echo "2: ${File[1]}"


IFS='|' read -r -a R <<< "${Hallo[r,not]}"
echo "1: ${R[0]}"
echo "2: ${R[1]}"
