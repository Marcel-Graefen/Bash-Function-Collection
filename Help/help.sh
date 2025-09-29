#!/usr/bin/env bash

# ========================================================================================
# Bash Global Help System
#
#
# @author      : Marcel Gräfen
# @version     : 0.0.1-beta.01
# @date        : 2025-09-28
#
# @requires    : Bash 4.3+
#
# @see         : https://github.com/Marcel-Graefen/Bash-Function-Collection/
#
# @copyright   : Copyright (c) 2025 Marcel Gräfen
# @license     : MIT License
# ========================================================================================



# __Help() {



# }




# === System Language Detection ===
get_system_language() {

    local lang="$1"

    local default_lang="en"


    if [ -z "$lang" ]; then
        # Versuche verschiedene System-Variablen
        for env_var in LANG LC_ALL LC_MESSAGES LANGUAGE; do
            if [ -n "${!env_var}" ]; then
                lang="${!env_var}"
                break
            fi
        done

        # Ultimate Fallback
        if [ -z "$lang" ]; then
            echo "Error: No system language configured!" >&2
            lang=$default_lang
        fi
    fi

    # Normalisierung und Prüfung wie gehabt
    lang_code=$(echo "$lang" | cut -d'_' -f1 | cut -d'.' -f1 | tr '[:upper:]' '[:lower:]')

    if [[ "$lang_code" =~ ^[a-z]{2}$ ]]; then
        echo "$lang_code"
    else
        echo "$default_lang"
    fi
}

# # Testen
# echo "1. Systemsprache: $(get_system_language)"
# echo "2. Deutsch: $(get_system_language "de")"
# echo "3. Locale: $(get_system_language "fr_FR.UTF-8")"
# echo "4. Großschreibung: $(get_system_language "ES")"
# echo "5. Ungültig: $(get_system_language "xyz")"





show_help() {
    echo "Starting interactive help..."

    while true; do
        echo ""
        echo "=== MAIN HELP ==="
        echo "1) Show basic usage"
        echo "2) Show options"
        echo "3) Show examples"
        echo "q) Quit help"
        echo ""
        read -p "Choose option: " choice

        case "$choice" in
            1)
                clear
                echo "=== BASIC USAGE ==="
                echo "Just run: ./script.sh"
                echo "Or use: ./script.sh --help"
                ;;
            2)
                clear
                echo "=== OPTIONS ==="
                echo "--help    Show this menu"
                echo "--version Show version"
                ;;
            3)
                clear
                echo "=== EXAMPLES ==="
                echo "./script.sh --help"
                echo "./script.sh --version"
                ;;
            q)
                echo "Exiting help..."
                break
                ;;
            *)
                echo "Invalid option!"
                ;;
        esac
    done
}





Submenu() {

  while true; do

      if CHOICE=$(whiptail --backtitle "${BACKTITLE}" --nocancel --default-item "1" --title "Menu" --menu "Choose an option:" \
      14 50 3 \
      "1" "Create User" \
      "2" "Back" \
       3>&1 1>&2 2>&3); then

      case $CHOICE in
      1)
        whiptail --textbox "Hallo.txt" 14 58  3>&1 1>&2 2>&3
        ;;
      2)
        break
        ;;
      3)
        exit 0
        ;;
      esac

    else

      # User Push ESC
      echo "Abourt by User!"
      exit 0

    fi

  done

}




HELP() {

BACKTITLE="HEKP for -> Bash User Management Script"

      menu_keys=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31" "32" "33" "34" "35" "36" "37" "38" "39" "40" "41" "42" "43" "44" "45" "46" "47" "48" "49" "50")
      menu_values=("Create User" "Remove User" "Remove SSH Public Key" "Change User Password" "Exit")

      # Auf gleiche Länge prüfen und kürzen
      min_length=$(( ${#menu_keys[@]} < ${#menu_values[@]} ? ${#menu_keys[@]} : ${#menu_values[@]} ))

      # Arrays auf gleiche Länge kürzen
      menu_keys=("${menu_keys[@]:0:$min_length}")
      menu_values=("${menu_values[@]:0:$min_length}")

      menu_options=()
      for i in "${!menu_keys[@]}"; do
          menu_options+=("${menu_keys[$i]}")
          menu_options+=("${menu_values[$i]}")
      done


      # Anzahl aller vorhandenen Keys
      total_keys=${#menu_keys[@]}

      # Exit als nächste Zahl hinzufügen
      exit_key=$((total_keys + 1))

      menu_options+=("$exit_key")   # KEY = nächste Zahl
      menu_options+=("Exit")        # VALUE = "Exit"


  while true; do

      # Whiptail mit dynamischen Werten
      if CHOICE=$(whiptail --backtitle "${BACKTITLE}" --nocancel --default-item "1" --title "Menu" --menu "Choose an option:" \
      0 50 0 \
      "${menu_options[@]}" \
      3>&1 1>&2 2>&3); then

      case $CHOICE in
      1)
        whiptail --textbox "Hallo.txt" 14 58  3>&1 1>&2 2>&3
        ;;
      2)
        Submenu
        ;;
      3)
        get_user_name

        if [ "$User_Name_Input" != "" ]; then
          set_ssh_pub_key
        fi

        ;;
      4)
        get_user_name

        if [ "$User_Name_Input" != "" ]; then
          remove_ssh_pub_key
        fi

        ;;
      5)
        get_user_name
        if [ "$User_Name_Input" != "" ]; then
          set_user_password
        fi

        if [ "$User_PASSWORD" != "" ]; then
          # echo -e "$User_PASSWORD" | passwd -q $User_Name_Input
          echo ${User_Name_Input}:${User_PASSWORD} | chpasswd
            User_PASSWORD="" #Clear Password
          whiptail --backtitle "${BACKTITLE}" --msgbox "Password für ${User_Name_Input} wurde Erneuert" 8 58  3>&1 1>&2 2>&3
        fi

        ;;
      *)
        # User Push Close Button
        echo "Bye Bye"
        exit 0
        ;;
      esac

    else

      # User Push ESC
      echo "Abourt by User!"
      exit 0

    fi

  done

}

HELP



1). Main Menü
    - Wo her weiß es welche Keys und Values es anzeigen soll?
    - Wie kann ich das Menü dynamisch erweitern?

