#!/usr/bin/env bash

# ========================================================================================
#  Bash
#
# @author      : Marcel Gräfen
# @version     : 0.0.1-Beta.01
# @date        : 2025-09-28
#
# @requires    : Bash 4.0+
#
# @see         : https://github.com/Marcel-Graefen/
#
# @copyright   : Copyright (c) 2025 Marcel Gräfen
# @license     : MIT License
# ========================================================================================



help() {

  declare -A help_config
  declare -a menu_sections output_sections

  CURRENT_MENU="Main"
  MENU_HISTORY=()
  CURRENT_LANG="de"

  # Konfigurierbare Pfade
  HELP_FILES_DIR="${HELP_FILES_DIR:-.}"
  HELP_FILES_PATTERN="${HELP_FILES_PATTERN:-help.*.ini}"
  LANGUAGES_INI_FILE="${LANGUAGES_INI_FILE:-languages.ini}"

  # Findet verfügbare Sprachen aus ALLEN INI-Dateien
  find_available_languages() {

    local search_pattern="${1:-$HELP_FILES_PATTERN}"
    local search_dir="${2:-$HELP_FILES_DIR}"
    languages=()

    # 1. Aus languages.ini lesen
    if [ -f "$LANGUAGES_INI_FILE" ]; then
      local current_lang=""
      local lang_name=""
      local in_lang_section=false
      local in_meta_section=false

      while IFS= read -r line; do
        line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        if [[ "$line" =~ ^\[([a-z]{2})\]$ ]]; then
          if [[ -n "$current_lang" ]]; then
            languages+=("$current_lang" "$lang_name")
          fi
          current_lang="${BASH_REMATCH[1]}"
          lang_name="$current_lang"
          in_lang_section=true
          in_meta_section=false
        elif [[ "$in_lang_section" = true && "$line" =~ ^\[meta\]$ ]]; then
          in_meta_section=true
        elif [[ "$in_meta_section" = true && "$line" =~ ^lang=(.*)$ ]]; then
          lang_name="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^\[.*\]$ ]] && [[ "$in_meta_section" = true ]]; then
          in_meta_section=false
        elif [[ "$line" =~ ^\[.*\]$ ]] && [[ "$in_lang_section" = true ]]; then
          in_lang_section=false
          in_meta_section=false
        fi
      done < "$LANGUAGES_INI_FILE"

      if [[ -n "$current_lang" ]]; then
        languages+=("$current_lang" "$lang_name")
      fi
    fi

    # 2. Aus Sprachdateien lesen - MIT VERZEICHNIS
    for file in "$search_dir"/$search_pattern; do
      if [[ -f "$file" ]]; then
        local lang_code=""
        local lang_name=""

        # Zuerst lang_code aus meta section lesen
        local in_meta_section=false
        while IFS= read -r line; do
          line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

          if [[ "$line" =~ ^\[meta\]$ ]]; then
            in_meta_section=true
          elif [[ "$in_meta_section" = true && "$line" =~ ^lang_code=([a-z]{2})$ ]]; then
            lang_code="${BASH_REMATCH[1]}"
          elif [[ "$in_meta_section" = true && "$line" =~ ^lang=(.*)$ ]]; then
            lang_name="${BASH_REMATCH[1]}"
          elif [[ "$line" =~ ^\[.*\]$ ]] && [[ "$in_meta_section" = true ]]; then
            break
          fi
        done < "$file"

        # Falls keine meta lang_code, versuche aus Dateinamen
        if [[ -z "$lang_code" ]]; then
          if [[ "$file" =~ [._-]?([a-z]{2})\.ini$ ]]; then
            lang_code="${BASH_REMATCH[1]}"
          fi
        fi

        # Falls kein lang_name gefunden, suche in der gesamten Datei nach lang=
        if [[ -z "$lang_name" ]]; then
          while IFS= read -r line; do
            line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
            if [[ "$line" =~ ^lang=(.*)$ ]]; then
              lang_name="${BASH_REMATCH[1]}"
              break
            fi
          done < "$file"
        fi

        # Fallback: Verwende lang_code als Name
        if [[ -z "$lang_name" ]]; then
          lang_name="$lang_code"
        fi

        if [[ -n "$lang_code" ]]; then
          # Prüfe ob Sprache bereits existiert
          local exists=false
          for ((i=0; i<${#languages[@]}; i+=2)); do
            if [[ "${languages[i]}" == "$lang_code" ]]; then
              exists=true
              break
            fi
          done
          if [[ "$exists" = false ]]; then
            languages+=("$lang_code" "$lang_name")
          fi
        fi
      fi
    done

    printf '%s\n' "${languages[@]}"
    
  }

}
