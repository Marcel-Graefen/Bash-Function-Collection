#!/bin/bash

declare -A config available_languages language_files language_names config_cache menu_order
declare -a section_order menu_sections MENU_HISTORY

# -------------------------------
# Globale Variablen
# -------------------------------
NAME_KEY="help"
LOG_FILE="/tmp/help_system_$NAME_KEY.log"
LOG=false

CURRENT_LANG_FILE=""
CURRENT_LANG_CODE=""
CURRENT_LANG_NAME=""
CURRENT_MENU=""
CONFIG_LOADED=false

HELP_FILES_DIR="./**/**/"

# -------------------------------
# Min/Max/Padding fuer Menues und Ausgaben
# -------------------------------
MIN_WIDTH=50
MAX_WIDTH=100
MIN_HEIGHT=10
MAX_HEIGHT=40
PADDING=10

# -------------------------------
# Default Werte
# -------------------------------
DEFAULT_LANG="de"
DEFAULT_LANG_FALLBACK="en"

DEFAULT_BACKTITLE="Help System"
DEFAULT_OPTION_ERROR="Option not found!"
DEFAULT_FILE_ERROR="File not found or cannot be read!"
DEFAULT_FILE_LABEL="File"
DEFAULT_MENU_TEXT="Choose an option:"
DEFAULT_BUTTON_LANG="Change Language"
DEFAULT_BUTTON_OK="OK"
DEFAULT_BUTTON_CANCEL="Cancel"
DEFAULT_BUTTON_BACK="Back"
DEFAULT_BUTTON_BACK_MAIN="To Main Menu"
DEFAULT_BUTTON_EXIT="Exit"

INI_FILES=()

INI_FILE_ERROR=false

# -------------------------------
# Dimension Berechnung
# -------------------------------
calculate_dimensions() {
  local content="$1"
  local TERM_WIDTH=$(tput cols)
  local TERM_HEIGHT=$(tput lines)
  local width height

  if [[ -f "$content" ]]; then
    # Datei-Behandlung (unverändert)
    local max_len=$(awk '{if(length>m)m=length}END{print m}' "$content" 2>/dev/null || echo 0)
    width=$((max_len + PADDING*2))
    height=$(wc -l < "$content" 2>/dev/null || echo 0)
    height=$(echo "$height" | tr -d '[:space:]')
    height=$((height + PADDING*2))
  else
    # Text-Input Behandlung (korrigiert)
    local line_count=0
    local max_len=0

    # Verwende Process Substitution für die while-Schleife
    while IFS= read -r line; do
      (( ${#line} > max_len )) && max_len=${#line}
      ((line_count++))
    done < <(echo "$content")

    width=$((max_len + PADDING*2))
    height=$((line_count + PADDING*2))
  fi

  # Größen-Begrenzungen (unverändert)
  (( width < MIN_WIDTH )) && width=$MIN_WIDTH
  (( width > MAX_WIDTH )) && width=$MAX_WIDTH
  (( width > TERM_WIDTH - 10 )) && width=$((TERM_WIDTH - 10))
  (( height < MIN_HEIGHT )) && height=$MIN_HEIGHT
  (( height > MAX_HEIGHT )) && height=$MAX_HEIGHT
  (( height > TERM_HEIGHT - 5 )) && height=$((TERM_HEIGHT - 5))

  echo "$width $height"
}

# -------------------------------
# Breadcrumb
# -------------------------------
build_breadcrumb() {
  local bc=""

  if [[ ${#MENU_HISTORY[@]} -eq 0 && -z "$CURRENT_MENU" ]]; then
    # Keine History und kein aktuelles Menü -> Default Backtitle
    bc="$DEFAULT_BACKTITLE"
  else
    # Start mit BACKTITLE oder Default
    bc="${BACKTITLE:-$DEFAULT_BACKTITLE}"
    for h in "${MENU_HISTORY[@]}"; do
      bc="$bc › ${h//_/ }"
    done
    [[ -n "$CURRENT_MENU" ]] && bc="$bc › ${CURRENT_MENU//_/ }"
  fi

  # Sicherstellen, dass es Buchstaben enthält, sonst Default
  if [[ ! "$bc" =~ [a-zA-Z] ]]; then
    bc="$DEFAULT_BACKTITLE"
  fi

  echo "$bc"
}

# -------------------------------
# Logging
# -------------------------------
log_message() {
  [[ "$LOG" != "true" ]] && return 0
  local level="$1" message="$2"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $level: $message" >> "$LOG_FILE"
}

# -------------------------------
# Fehlerfunktionen
# -------------------------------
show_error() {
  local type="$1" msg="$2" mode="${3:-}"
  local title="" ok_button="${config[Buttons.ok]:-$DEFAULT_BUTTON_OK}"

  case "$type" in
    "config") title="Configuration Error" ;;
    "file") title="File Error" ;;
    "menu") title="Menu Error" ;;
    "security") title="Security Error" ;;
    *) title="$type" ;;
  esac

  log_message "ERROR" "$type: $msg"

  if [[ "$mode" == "exit" ]]; then

    read -r width height < <(calculate_dimensions "$msg")
    whiptail --backtitle "$(build_breadcrumb)" \
            --title "$title" \
            --ok-button "Close" \
            --msgbox "$msg" 0 $width
    exit 1
  else
    read -r width height < <(calculate_dimensions "$msg")
    whiptail --backtitle "$(build_breadcrumb)" \
             --title "$title" \
             --ok-button "$ok_button" \
             --msgbox "$msg" 0 $width
  fi

}

show_option_error() {
  local msg="${1:-${config[Messages.option_error]:-$DEFAULT_OPTION_ERROR}}"
  local mode="${2:-}"
  show_error "menu" "$msg" "$mode"
  return 0
}

show_file_error() {
  local file_path="$1"
  local file_error_message="${config[Messages.file_error]:-$DEFAULT_FILE_ERROR}"
  local file_label="${config[Messages.file_label]:-$DEFAULT_FILE_LABEL}"
  local full_message="$file_error_message\n\n$file_label: $file_path"
  show_error "file" "$full_message"
  return 0
}

# -------------------------------
# Validierung
# -------------------------------
validate_file_path() {
  local file="$1"
  [[ "$file" =~ \.\. ]] && show_error "security" "Invalid file path: $file" "exit"
  [[ -f "$file" && -r "$file" ]] || return 1
  return 0
}

validate_config() {
  local required_keys=("meta.name" "meta.lang" "meta.lang_code")
  for key in "${required_keys[@]}"; do
    [[ -z "${config[$key]}" ]] && show_error "config" "Missing required configuration: $key" "exit"
  done
  return 0
}

# -------------------------------
# Scan Help Directories
# -------------------------------
scan_help_dirs() {
  local dir_pattern="$HELP_FILES_DIR"
  local valid_dirs=()
  local dirs_array=($dir_pattern)

  # Bei nur einem expliziten Ordner: Sofort abbrechen bei Fehlern
  if [[ ${#dirs_array[@]} -eq 1 ]]; then
    local dir="${dirs_array[0]}"
    if [[ ! -d "$dir" ]]; then
      show_error "Error Directory" "Directory does not exist: $dir" "exit"
    fi
    local ini_files=()
    for file in "$dir"/*.ini; do
      [[ -f "$file" ]] && ini_files+=("$file")
    done
    if [[ ${#ini_files[@]} -eq 0 ]]; then
      show_error "Error Directory" "Directory contains no INI files: $dir" "exit"
    fi
    valid_dirs+=("$dir")
  else
    # Bei Wildcards/mehreren Ordnern: Alle prüfen, nur abbrechen wenn alle fehlschlagen
    local errors=()
    for dir in $dir_pattern; do
      if [[ ! -d "$dir" ]]; then
        errors+=("Directory does not exist: $dir")
        continue
      fi
      local ini_files=()
      for file in "$dir"/*.ini; do
        [[ -f "$file" ]] && ini_files+=("$file")
      done
      if [[ ${#ini_files[@]} -eq 0 ]]; then
        errors+=("Directory contains no INI files: $dir")
        continue
      fi
      valid_dirs+=("$dir")
    done

    if [[ ${#valid_dirs[@]} -eq 0 ]]; then
      local error_msg=""
      for err in "${errors[@]}"; do
        error_msg+="$err\n"
      done
      show_error "Error Directory" "${error_msg}No valid directories found!" "exit"
    fi

    # Einzelne Fehler nur loggen
    for err in "${errors[@]}"; do
      log_message "WARN" "$err"
    done
  fi

  INI_FILES=("${valid_dirs[@]}")
}

# -------------------------------
# INI File Parsing mit Cache
# -------------------------------
parse_ini_file() {
  local file="$1"
  local cache_key="${file}_parsed"

  # Cache prüfen
  if [[ -n "${config_cache[$cache_key]}" ]]; then
    log_message "DEBUG" "Using cached config for: $file"
    return 0
  fi

  local -A temp_config=()
  local temp_section_order=()
  local -A temp_menu_order=()
  local current_section=""

  while IFS= read -r line || [[ -n $line ]]; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" ]] && continue
    case "$line" in
      \#*|\;*) continue ;;
      \[*\])
        current_section="${line:1:-1}"
        temp_section_order+=("$current_section")
        ;;
      *=*)
        local key="${line%%=*}"
        local value="${line#*=}"
        if [[ -n "$current_section" && -n "$key" ]]; then
          temp_config["$current_section.$key"]="$value"
          [[ "$key" != "type" ]] && temp_menu_order["$current_section"]="${temp_menu_order["$current_section"]:-} $key"
        else
          temp_config["$key"]="$value"
        fi
        ;;
    esac
  done < "$file"

  # Prüfen auf gültige INI
  local lang_code="${temp_config[meta.lang_code]:-}"
  local lang_name="${temp_config[meta.lang]:-}"
  local name="${temp_config[meta.name]:-}"

  if [[ -z "$lang_code" || -z "$lang_name" || -z "$name" || "$name" != "$NAME_KEY" ]]; then
    log_message "WARN" "Invalid INI file skipped: $file"
    return 1
  fi

  # Prüfen, ob gültige Menüsektion existiert
  local valid_menu=false
  for section in "${temp_section_order[@]}"; do
    if [[ "${temp_config[$section.type]}" == "menu" ]]; then
      for k in "${!temp_config[@]}"; do
        if [[ "$k" == "$section."* ]] && [[ "$k" != "$section.type" ]]; then
          valid_menu=true
          break 2
        fi
      done
    fi
  done

  if [[ "$valid_menu" != true ]]; then
    if [[ "$INI_FILE_ERROR" == false ]]; then
      show_error "menu" "INI '$file' does not contain a valid menu, will be skipped"
      INI_FILE_ERROR=true
    fi
    return 1
  fi

  # Konfiguration in globale Arrays übernehmen
  for key in "${!temp_config[@]}"; do
    config["$key"]="${temp_config[$key]}"
  done

  section_order=("${temp_section_order[@]}")
  for section in "${!temp_menu_order[@]}"; do
    menu_order["$section"]="${temp_menu_order[$section]}"
  done

  # In Cache speichern
  config_cache["$cache_key"]=1
  log_message "DEBUG" "Cached config for: $file"
  return 0
}

# -------------------------------
# Find Available Languages
# -------------------------------
find_available_languages() {
  available_languages=()
  language_files=()
  language_names=()
  [[ -z "$NAME_KEY" ]] && show_error "config" "NAME_KEY must be set before calling find_available_languages!" "exit"

  scan_help_dirs

  local valid_dirs=("${INI_FILES[@]}")
  [[ ${#valid_dirs[@]} -eq 0 ]] && show_error "config" "No directories with INI files found!" "exit"

  local temp_current_lang_file=""
  local temp_current_lang_code=""
  local temp_current_lang_name=""

  # Cache zurücksetzen für diese Funktion
  local -A temp_config=()

  for dir in "${valid_dirs[@]}"; do
    shopt -s nullglob
    for file in "$dir"/*.ini; do
      [[ -f "$file" ]] || continue

      # Temporäre Config für jede Datei
      local -A file_config=()
      local file_section_order=()
      local current_section=""

      while IFS= read -r line || [[ -n $line ]]; do
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        [[ -z "$line" ]] && continue
        case "$line" in
          \#*|\;*) continue ;;
          \[*\])
            current_section="${line:1:-1}"
            file_section_order+=("$current_section")
            ;;
          *=*)
            local key="${line%%=*}"
            local value="${line#*=}"
            if [[ -n "$current_section" && -n "$key" ]]; then
              file_config["$current_section.$key"]="$value"
            else
              file_config["$key"]="$value"
            fi
            ;;
        esac
      done < "$file"

      local lang_code="${file_config[meta.lang_code]:-}"
      local lang_name="${file_config[meta.lang]:-}"
      local name="${file_config[meta.name]:-}"

      # Ungültige INIs überspringen
      if [[ -z "$lang_code" || -z "$lang_name" || -z "$name" || "$name" != "$NAME_KEY" ]]; then
        continue
      fi

      # Prüfen, ob gültige Menüsektion existiert
      local valid_menu=false
      for section in "${file_section_order[@]}"; do
        if [[ "${file_config[$section.type]}" == "menu" ]]; then
          for k in "${!file_config[@]}"; do
            if [[ "$k" == "$section."* ]] && [[ "$k" != "$section.type" ]]; then
              valid_menu=true
              break 2
            fi
          done
        fi
      done

      if [[ "$valid_menu" != true ]]; then
        if [[ "$INI_FILE_ERROR" == false ]]; then
          show_error "menu" "INI '$file' does not contain a valid menu, will be skipped"
          INI_FILE_ERROR=true
        fi
        continue
      fi

      # Alle gültigen INIs aufnehmen
      available_languages["$lang_code"]="$lang_name"
      language_files["$lang_code"]="$file"
      language_names["$lang_code"]="$name"

      # Wenn Default-Sprache passt, merken
      if [[ "$lang_code" == "$DEFAULT_LANG" ]]; then
        temp_current_lang_file="$file"
        temp_current_lang_code="$lang_code"
        temp_current_lang_name="$lang_name"
      fi

    done
    shopt -u nullglob
  done

  # Aktuelle Sprache setzen: Default -> Fallback -> erste verfügbare
  if [[ -n "$temp_current_lang_file" ]]; then
    CURRENT_LANG_FILE="$temp_current_lang_file"
    CURRENT_LANG_CODE="$temp_current_lang_code"
    CURRENT_LANG_NAME="$temp_current_lang_name"
  elif [[ -n "${language_files[$DEFAULT_LANG_FALLBACK]}" ]]; then
    CURRENT_LANG_FILE="${language_files[$DEFAULT_LANG_FALLBACK]}"
    CURRENT_LANG_CODE="$DEFAULT_LANG_FALLBACK"
    CURRENT_LANG_NAME="${available_languages[$DEFAULT_LANG_FALLBACK]}"
    show_error "config" "Default Language <$DEFAULT_LANG> not found! Load <$CURRENT_LANG_CODE>."
  else
    for l in "${!language_files[@]}"; do
      CURRENT_LANG_FILE="${language_files[$l]}"
      CURRENT_LANG_CODE="$l"
      CURRENT_LANG_NAME="${available_languages[$l]}"
      show_error "config" "Default Language <$DEFAULT_LANG> & Fallback Language <$DEFAULT_LANG_FALLBACK> not found! Load <$CURRENT_LANG_CODE>"
      break
    done
  fi

  [[ ${#available_languages[@]} -eq 0 ]] && show_error "config" "No valid INI files found!" "exit"
}
# -------------------------------
# Find Best Language File
# -------------------------------
find_best_language_file() {
  [[ -n "$CURRENT_LANG_FILE" ]] && return
  find_available_languages
  local best_lang=""
  if [[ -n "$DEFAULT_LANG" ]] && [[ -n "${language_files[$DEFAULT_LANG]}" ]]; then
    best_lang="$DEFAULT_LANG"
  elif [[ -n "$DEFAULT_LANG_FALLBACK" ]] && [[ -n "${language_files[$DEFAULT_LANG_FALLBACK]}" ]]; then
    best_lang="$DEFAULT_LANG_FALLBACK"
  else
    for l in "${!language_files[@]}"; do best_lang="$l"; break; done
  fi
  [[ -n "$best_lang" ]] && CURRENT_LANG_FILE="${language_files[$best_lang]}" && CURRENT_LANG_CODE="$best_lang" && CURRENT_LANG_NAME="${available_languages[$best_lang]}" && return
  show_error "config" "No language file found!" "exit"
}

# -------------------------------
# Load Help File
# -------------------------------
load_help_file() {
  $CONFIG_LOADED && return
  find_best_language_file || return 1
  [[ -z "$CURRENT_LANG_FILE" ]] && show_error "config" "No language file" "exit"

  local temp_cache_key="${CURRENT_LANG_FILE}_temp"
  [[ -n "${config_cache[$temp_cache_key]}" ]] && { CONFIG_LOADED=true; return 0; }

  # Konfiguration parsen (verwendet jetzt den Cache)
  if ! parse_ini_file "$CURRENT_LANG_FILE"; then
    show_error "config" "Failed to parse language file: $CURRENT_LANG_FILE" "exit"
  fi

  # Hauptmenü finden
  local found_menu=""
  for section in "${section_order[@]}"; do
    [[ "${config[$section.type]}" == "menu" ]] && { found_menu="$section"; break; }
  done
  [[ -z "$found_menu" ]] && found_menu="${section_order[0]}"
  CURRENT_MENU="$found_menu"

  validate_config
  config_cache["$temp_cache_key"]=1
  CONFIG_LOADED=true
}

# -------------------------------
# Setup Config Variables
# -------------------------------
setup_config_variables() {
  load_help_file || return 1
  BACKTITLE="${config[meta.backtitle]:-$DEFAULT_BACKTITLE}"
  LANGUAGE="${config[meta.lang]:-$CURRENT_LANG_NAME}"
  LANGUAGE_CODE="${config[meta.lang_code]:-$CURRENT_LANG_CODE}"
  OPTION_ERROR="${config[Messages.option_error]:-$DEFAULT_OPTION_ERROR}"
  FILE_ERROR="${config[Messages.file_error]:-$DEFAULT_FILE_ERROR}"
  FILE_LABEL="${config[Messages.file_label]:-$DEFAULT_FILE_LABEL}"
  MENU_TEXT="${config[Messages.menu]:-$DEFAULT_MENU_TEXT}"
  BUTTON_LANG="${config[Buttons.language]:-$DEFAULT_BUTTON_LANG}"
  BUTTON_OK="${config[Buttons.ok]:-$DEFAULT_BUTTON_OK}"
  BUTTON_CANCEL="${config[Buttons.cancel]:-$DEFAULT_BUTTON_CANCEL}"
  BUTTON_BACK="${config[Buttons.back]:-$DEFAULT_BUTTON_BACK}"
  BUTTON_BACK_MAIN="${config[Buttons.back_main]:-$DEFAULT_BUTTON_BACK_MAIN}"
  BUTTON_EXIT="${config[Buttons.exit]:-$DEFAULT_BUTTON_EXIT}"
}

# -------------------------------
# Menu Sections
# -------------------------------
find_menu_sections() {
  setup_config_variables || return 1
  menu_sections=()
  for s in "${section_order[@]}"; do
    [[ "${config[$s.type]}" == "menu" ]] && menu_sections+=("$s")
  done
}

is_menu_section() { [[ "${config[$1.type]}" == "menu" ]]; }
is_output_section() { [[ -n "${config[$1.text]}" || -n "${config[$1.file]}" ]]; }

# -------------------------------
# Sprachmenue
# -------------------------------
show_language_menu() {
  find_available_languages
  local menu_items=()
  local default_item=""
  for code in "${!available_languages[@]}"; do
    local key=$(echo "$code" | tr '[:lower:]' '[:upper:]')
    menu_items+=("$key" "${available_languages[$code]}")
    [[ "$code" == "$CURRENT_LANG_CODE" ]] && default_item="$key"
  done

  local choice
  choice=$(whiptail --backtitle "$(build_breadcrumb)" \
             --title "$LANGUAGE" \
             --ok-button "$BUTTON_OK" \
             --cancel-button "$BUTTON_BACK" \
             --default-item "$default_item" \
             --menu "$BUTTON_LANG:" \
             0 $MIN_WIDTH 0 \
             "${menu_items[@]}" 3>&1 1>&2 2>&3)
  local status=$?

  if [[ $status -eq 0 ]] && [[ -n "$choice" ]]; then
    local selected_lower=$(echo "$choice" | tr '[:upper:]' '[:lower:]')
    CURRENT_LANG_FILE="${language_files[$selected_lower]}"
    CURRENT_LANG_CODE="$selected_lower"
    CURRENT_LANG_NAME="${available_languages[$selected_lower]}"
    CONFIG_LOADED=false
    config_cache=()
    CURRENT_MENU=""
    setup_config_variables
    find_menu_sections
  elif [[ $status -eq 1 ]]; then
    return 0
  elif [[ $status -eq 255 ]]; then
    exit 0
  fi
}

# -------------------------------
# Text / File Anzeige
# -------------------------------
show_text() {
  local title="$1"
  local text="$2"
  read -r width height < <(calculate_dimensions "$text")
  whiptail --backtitle "$(build_breadcrumb)" \
           --title "$title" \
           --ok-button "$BUTTON_BACK" \
           --msgbox "$text" "$height" "$width"
}

show_file() {
  local title="$1"
  local file="$2"
  validate_file_path "$file" || { show_file_error "$file"; return 1; }
  read -r width height < <(calculate_dimensions "$file")
  whiptail --backtitle "$(build_breadcrumb)" \
           --title "$title" \
           --ok-button "$BUTTON_BACK" \
           --scrolltext \
           --textbox "$file" "$height" "$width"
}

# -------------------------------
# Hauptmenu mit verbesserter Fehlerbehandlung
# -------------------------------
show_help_menu() {
  while true; do
    setup_config_variables || {
      show_error "config" "Failed to load configuration" "exit"
    }

    local menu_items=()
    local -a ordered_keys

    # Reihenfolge der Menüpunkte ermitteln
    if [[ -n "${menu_order[$CURRENT_MENU]}" ]]; then
      read -ra ordered_keys <<< "${menu_order[$CURRENT_MENU]}"
    else
      for key in "${!config[@]}"; do
        if [[ "$key" == "$CURRENT_MENU."* && "$key" != "$CURRENT_MENU.type" ]]; then
          ordered_keys+=("${key#$CURRENT_MENU.}")
        fi
      done
    fi

    # Menüitems hinzufügen
    for key in "${ordered_keys[@]}"; do
      local full_key="$CURRENT_MENU.$key"
      [[ -n "${config[$full_key]}" ]] && menu_items+=("$key" "${config[$full_key]}")
    done

    # Fallback wenn menu_items leer
    if [[ ${#menu_items[@]} -eq 0 ]]; then
      show_error "menu" "No menu items found for: $CURRENT_MENU"
      # Zurück zum Hauptmenü
      find_menu_sections
      if [[ ${#menu_sections[@]} -gt 0 ]]; then
        CURRENT_MENU="${menu_sections[0]}"
        MENU_HISTORY=()
      else
        show_error "menu" "No valid menu sections found!" "exit"
      fi
      continue
    fi

    # Language-Menü hinzufügen, nur wenn wir im Hauptmenü sind
    if [[ ${#MENU_HISTORY[@]} -eq 0 ]] && [[ ${#available_languages[@]} -gt 1 ]]; then
      local lang_upper=$(echo "$CURRENT_LANG_CODE" | tr '[:lower:]' '[:upper:]')
      local current_button_lang="${config[Buttons.language]:-$DEFAULT_BUTTON_LANG}"
      menu_items+=("$lang_upper" "$current_button_lang")
    fi

    # Cancel/Back-Button
    local cancel_button
    [[ ${#MENU_HISTORY[@]} -eq 0 ]] && cancel_button="$BUTTON_EXIT" || cancel_button="$BUTTON_BACK"

    # Breite/Höhe berechnen
    local max_len=0
    for i in "${menu_items[@]}"; do (( ${#i} > max_len )) && max_len=${#i}; done
    local TERM_WIDTH=$(tput cols)
    local width=$((max_len + PADDING*2))
    (( width < MIN_WIDTH )) && width=$MIN_WIDTH
    (( width > MAX_WIDTH )) && width=$MAX_WIDTH
    (( width > TERM_WIDTH - 10 )) && width=$((TERM_WIDTH - 10))
    local height=${#menu_items[@]}
    (( height < MIN_HEIGHT )) && height=$MIN_HEIGHT
    (( height > MAX_HEIGHT )) && height=$MAX_HEIGHT
    local menu_height=$((height > 0 ? height : 10))

    # Whiptail Menu
    local choice
    choice=$(whiptail --backtitle "$(build_breadcrumb)" \
               --title "${CURRENT_MENU//_/ }" \
               --ok-button "$BUTTON_OK" \
               --cancel-button "$cancel_button" \
               --menu "$MENU_TEXT" \
               "$menu_height" "$width" 0 \
               "${menu_items[@]}" 3>&1 1>&2 2>&3)
    local status=$?

    if [[ $status -eq 0 ]] && [[ -n "$choice" ]]; then
      # Language-Menü aufrufen
      if [[ ${#MENU_HISTORY[@]} -eq 0 ]] && [[ "$choice" == "$(echo "$CURRENT_LANG_CODE" | tr '[:lower:]' '[:upper:]')" ]]; then
        show_language_menu
        continue
      fi

      # Ausgewähltes Menü/Output finden
      local selected_value="${config[${CURRENT_MENU}.${choice}]}"
      local selected_type="${config[${selected_value}.type]}"

      if [[ "$selected_type" == "menu" ]]; then
        MENU_HISTORY+=("$CURRENT_MENU")
        CURRENT_MENU="$selected_value"
      elif [[ "$selected_type" == "output" ]]; then
        local output_title="${selected_value//_/ }"
        if [[ -n "${config[${selected_value}.text]}" ]]; then
          show_text "$output_title" "${config[${selected_value}.text]}"
        elif [[ -n "${config[${selected_value}.file]}" ]]; then
          show_file "$output_title" "${config[${selected_value}.file]}"
        else
          show_option_error
        fi
      else
        show_option_error
      fi

    elif [[ $status -eq 1 ]]; then
      # Zurück
      if [[ ${#MENU_HISTORY[@]} -eq 0 ]]; then
        exit 0
      fi
      CURRENT_MENU="${MENU_HISTORY[-1]}"
      MENU_HISTORY=("${MENU_HISTORY[@]:0:$((${#MENU_HISTORY[@]}-1))}")
    elif [[ $status -eq 255 ]]; then
      exit 0
    fi
  done
}

# -------------------------------
# Start
# -------------------------------
show_help_menu
