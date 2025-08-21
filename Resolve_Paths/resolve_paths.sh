#!/usr/bin/env bash

# ========================================================================================
# Bash Resolve Paths
#
#
# @author      : Marcel Gräfen
# @version     : 2.0.0
# @date        : 2025-08-21
#
# @requires    : Bash 4.0+
# @requires    : realpath
# @requires    : Function   =>  Normalize List v1.X.X
# @requires    : Function   =>  check_requirements v1.X.X
#
# @see         : https://github.com/Marcel-Graefen/Bash-Function-Collection/Resolve%20Paths
#
# @copyright   : Copyright (c) 2025 Marcel Gräfen
# @license     : MIT License
# ========================================================================================

# Function -> Normaliz List
source <(wget -qO- "https://raw.githubusercontent.com/Marcel-Graefen/Bash-Function-Collection/refs/heads/main/Normalize_List/normalize_list.sh")

#---------------------- FUNCTION: resolve_paths --------------------------------
# Resolves and classifies given filesystem paths.
#
# Features:
#   - Normalizes input (via normalize_list)
#   - Expands wildcards (*, ?) automatically
#   - Resolves absolute paths (via realpath -m)
#   - Removes duplicates (except for -o-all, which preserves all before dedup)
#   - Classifies paths by:
#       • Existence (exist / missing)
#       • Read (r / not-r)
#       • Write (w / not-w)
#       • Execute (x / not-x)
#       • Read+Write (rw / not-rw)
#       • Read+Execute (rx / not-rx)
#       • Write+Execute (wx / not-wx)
#       • Read+Write+Execute (rwx / not-rwx)
#   - Assigns results to caller-provided arrays via namerefs
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
#
# Arguments:
#   -i, --input          Space-separated list of input paths
#   -s, --separator      Separator characters for splitting input
#   -o-all               Output array with all normalized paths (before dedup)
#   -o-exist             Output array: existing paths
#   -o-missing           Output array: missing paths
#   -o-r                 Output array: readable paths
#   -o-not-r             Output array: not-readable paths
#   -o-w                 Output array: writable paths
#   -o-not-w             Output array: not-writable paths
#   -o-x                 Output array: executable paths
#   -o-not-x             Output array: not-executable paths
#   -o-rw, -o-wr         Output array: read+write paths
#   -o-not-rw, -o-not-wr Output array: not-read+write paths
#   -o-rx, -o-xr         Output array: read+execute paths
#   -o-not-rx, -o-not-xr Output array: not-read+execute paths
#   -o-wx, -o-xw         Output array: write+execute paths
#   -o-not-wx, -o-not-xw Output array: not-write+execute paths
#   -o-rwx, -o-rxw, -o-wrx, -o-wxr, -o-xrw, -o-xwr
#                        Output array: read+write+execute paths
#   -o-not-rwx, -o-not-rxw, -o-not-wrx, -o-not-wxr, -o-not-xrw, -o-not-xwr
#                        Output array: not-read+write+execute paths
#
# Returns:
#   0  on success
#   2  on error (e.g., missing input, unknown option, or missing -o-* output array)
#
# Notes:
#   - Requires at least one -o-* output option
#   - Errors are printed with ❌ prefix via log_msg

resolve_paths() {

  # NOTE: see check_requirements.sh
  # @ see https://github.com/Marcel-Graefen/Bash-Function-Collection/tree/main/Check%20Requirements

  if [[ $# -eq 0 ]]; then
    log_msg ERROR "${FUNCNAME[0]}: No parameters provided"
    return 2
  fi

  # Defaults
  local inputs=() sep=" " wildcard_chars="*?"
  local output_all_var="" output_exist_var="" output_missing_var=""

  local output_r_var="" output_not_r_var=""
  local output_w_var="" output_not_w_var=""
  local output_x_var="" output_not_x_var=""
  local output_rw_var="" output_not_rw_var=""
  local output_rx_var="" output_not_rx_var=""
  local output_wx_var="" output_not_wx_var=""
  local output_rwx_var="" output_not_rwx_var=""

  # ----------------- Helper -----------------
  check_value() {
    local val="$1" name="$2"
    if [[ -z "$val" || "$val" == -* ]]; then
      log_msg ERROR "${FUNCNAME[1]}: $name requires a value"; return 2
    fi
  }

  # --------- Parse arguments ---------
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i|--input)     check_value "$2" "$1" || return 2; inputs+=("$2")           ;;
      -s|--separator) check_value "$2" "$1" || return 2; sep="$2"                 ;;
      -o-all)         check_value "$2" "$1" || return 2; output_all_var="$2"      ;;
      -o-exist)       check_value "$2" "$1" || return 2; output_exist_var="$2"    ;;
      -o-missing)     check_value "$2" "$1" || return 2; output_missing_var="$2"  ;;

      -o-r)           check_value "$2" "$1" || return 2; output_r_var="$2"        ;;
      -o-not-r)       check_value "$2" "$1" || return 2; output_not_r_var="$2"    ;;
      -o-w)           check_value "$2" "$1" || return 2; output_w_var="$2"        ;;
      -o-not-w)       check_value "$2" "$1" || return 2; output_not_w_var="$2"    ;;
      -o-x)           check_value "$2" "$1" || return 2; output_x_var="$2"        ;;
      -o-not-x)       check_value "$2" "$1" || return 2; output_not_x_var="$2"    ;;

      -o-rw|-o-wr)                    check_value "$2" "$1" || return 2; output_rw_var="$2"       ;;
      -o-not-rw|-o-not-wr)            check_value "$2" "$1" || return 2; output_not_rw_var="$2"   ;;
      -o-rx|-o-xr)                    check_value "$2" "$1" || return 2; output_rx_var="$2"       ;;
      -o-not-rx|-o-not-xr)            check_value "$2" "$1" || return 2; output_not_rx_var="$2"   ;;
      -o-wx|-o-xw)                    check_value "$2" "$1" || return 2; output_wx_var="$2"       ;;
      -o-not-wx|-o-not-xw)            check_value "$2" "$1" || return 2; output_not_wx_var="$2"   ;;
      -o-rwx|-o-rxw|-o-wrx|-o-wxr|-o-xrw|-o-xwr)
                                     check_value "$2" "$1" || return 2; output_rwx_var="$2"      ;;
      -o-not-rwx|-o-not-rxw|-o-not-wrx|-o-not-wxr|-o-not-xrw|-o-not-xwr)
                                     check_value "$2" "$1" || return 2; output_not_rwx_var="$2"  ;;

      *) log_msg ERROR "${FUNCNAME[0]}: Unknown option: $1"; return 1 ;;
    esac
    shift 2
  done

  # --------- Check for at least one output variable ---------
  [[ -z "$output_all_var" && -z "$output_exist_var" && -z "$output_missing_var" && \
     -z "$output_r_var" && -z "$output_not_r_var" && \
     -z "$output_w_var" && -z "$output_not_w_var" && \
     -z "$output_x_var" && -z "$output_not_x_var" && \
     -z "$output_rw_var" && -z "$output_not_rw_var" && \
     -z "$output_rx_var" && -z "$output_not_rx_var" && \
     -z "$output_wx_var" && -z "$output_not_wx_var" && \
     -z "$output_rwx_var" && -z "$output_not_rwx_var" ]] && {
        log_msg ERROR "${FUNCNAME[0]}: At least one output option is required"
        return 2
      }

  # --------- Normalize input ---------
  local normalized=()
  normalize_list -i "${inputs[*]}" -o normalized -s "$sep"

  # --------- Wildcard resolution (globbing for * and ?) ---------
  local processed=()
  shopt -s nullglob dotglob
  for p in "${normalized[@]}"; do
    if [[ "$p" == *"*"* || "$p" == *"?"* ]]; then
      for f in $p; do
        processed+=("$(realpath -m "$f")")
      done
    else
      processed+=("$(realpath -m "$p")")
    fi
  done
  shopt -u nullglob dotglob

  # --------- Map -o-all BEFORE removing duplicates ---------
  if [[ -n "$output_all_var" ]]; then
    local -n _dest_all="$output_all_var"
    _dest_all=( "${processed[@]}" )
  fi

  # --------- Remove duplicates ---------
  local unique=(); declare -A seen
  for f in "${processed[@]}"; do
    [[ -z "${seen[$f]}" ]] && { unique+=("$f"); seen[$f]=1; }
  done
  processed=("${unique[@]}")

  # --------- Classify (existence + requested permissions only) ---------
  local _exist=() _missing=()
  local _r=() _not_r=() _w=() _not_w=() _x=() _not_x=()
  local _rw=() _not_rw=() _rx=() _not_rx=() _wx=() _not_wx=() _rwx=() _not_rwx=()

  for p in "${processed[@]}"; do
    if [[ -e "$p" ]]; then
      _exist+=("$p")
      [[ -n "$output_r_var"   || -n "$output_not_r_var"  ]] && { [[ -r "$p"             ]] && _r+=("$p")   || _not_r+=("$p"); }
      [[ -n "$output_w_var"   || -n "$output_not_w_var"  ]] && { [[ -w "$p"             ]] && _w+=("$p")   || _not_w+=("$p"); }
      [[ -n "$output_x_var"   || -n "$output_not_x_var"  ]] && { [[ -x "$p"             ]] && _x+=("$p")   || _not_x+=("$p"); }
      [[ -n "$output_rw_var"  || -n "$output_not_rw_var" ]] && { [[ -r "$p" && -w "$p"  ]] && _rw+=("$p")  || _not_rw+=("$p"); }
      [[ -n "$output_rx_var"  || -n "$output_not_rx_var" ]] && { [[ -r "$p" && -x "$p"  ]] && _rx+=("$p")  || _not_rx+=("$p"); }
      [[ -n "$output_wx_var"  || -n "$output_not_wx_var" ]] && { [[ -w "$p" && -x "$p"  ]] && _wx+=("$p")  || _not_wx+=("$p"); }
  [[ -n "$output_rwx_var" || -n "$output_not_rwx_var" ]] && { [[ -r "$p" && -w "$p" && -x "$p" ]] && _rwx+=("$p") || _not_rwx+=("$p"); }
    else
      _missing+=("$p")
    fi
  done

  # --------- Map to output variables ---------
  [[ -n "$output_exist_var"    ]] && { local -n d1="$output_exist_var";    d1=( "${_exist[@]}" ); }
  [[ -n "$output_missing_var"  ]] && { local -n d2="$output_missing_var";  d2=( "${_missing[@]}" ); }
  [[ -n "$output_r_var"        ]] && { local -n d3="$output_r_var";        d3=( "${_r[@]}" ); }
  [[ -n "$output_not_r_var"    ]] && { local -n d4="$output_not_r_var";    d4=( "${_not_r[@]}" ); }
  [[ -n "$output_w_var"        ]] && { local -n d5="$output_w_var";        d5=( "${_w[@]}" ); }
  [[ -n "$output_not_w_var"    ]] && { local -n d6="$output_not_w_var";    d6=( "${_not_w[@]}" ); }
  [[ -n "$output_x_var"        ]] && { local -n d7="$output_x_var";        d7=( "${_x[@]}" ); }
  [[ -n "$output_not_x_var"    ]] && { local -n d8="$output_not_x_var";    d8=( "${_not_x[@]}" ); }
  [[ -n "$output_rw_var"       ]] && { local -n d9="$output_rw_var";       d9=( "${_rw[@]}" ); }
  [[ -n "$output_not_rw_var"   ]] && { local -n d10="$output_not_rw_var";  d10=( "${_not_rw[@]}" ); }
  [[ -n "$output_rx_var"       ]] && { local -n d11="$output_rx_var";      d11=( "${_rx[@]}" ); }
  [[ -n "$output_not_rx_var"   ]] && { local -n d12="$output_not_rx_var";  d12=( "${_not_rx[@]}" ); }
  [[ -n "$output_wx_var"       ]] && { local -n d13="$output_wx_var";      d13=( "${_wx[@]}" ); }
  [[ -n "$output_not_wx_var"   ]] && { local -n d14="$output_not_wx_var";  d14=( "${_not_wx[@]}" ); }
  [[ -n "$output_rwx_var"      ]] && { local -n d15="$output_rwx_var";     d15=( "${_rwx[@]}" ); }
  [[ -n "$output_not_rwx_var"  ]] && { local -n d16="$output_not_rwx_var"; d16=( "${_not_rwx[@]}" ); }

  return 0
}
