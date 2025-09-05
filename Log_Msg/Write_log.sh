#!/bin/bash

write_to_file() {

  #-------------------- Konfiguration --------------------
  local PROTECTED_DIRS=("/etc" "/bin" "/usr" "/sbin" "/lib" "/lib64")  # erweiterbar
  local dirs=()
  local files=()
  local message=""
  local fallback_dir=""
  local fallback_file=""
  local file_prefix="old_"
  local file_mode="append"   # append | overwrite | prefix
  local default_dir="/tmp"
  local default_file="output.txt"

    #-------------------- Parameter parsen --------------------
  while [[ $# -gt 0 ]]; do
      case "$1" in
          -d|--dir) shift; dirs+=("$1") ;;
          -f|--file) shift; files+=("$1") ;;
          -m|--message|--msg) shift; message="$1" ;;
          --fallback-dir) shift; fallback_dir="$1" ;;
          --fallback-file) shift; fallback_file="$1" ;;
          --file-prefix) shift; file_prefix="$1" ;;
          --file-mode) shift; file_mode="$1" ;;
          *) echo "❌ Unknown parameter: $1"; return 1 ;;
      esac
      shift
  done

    #-------------------- Verzeichnisse prüfen / erstellen --------------------
    local valid_dirs=()
    [[ ${#dirs[@]} -eq 0 ]] && dirs=("$default_dir")

    for dir in "${dirs[@]}"; do
        # Schutz kritischer Pfade
        for pd in "${PROTECTED_DIRS[@]}"; do
            if [[ "$dir" == "$pd"* ]]; then
                echo "❌ Protected directory: $dir"; return 1
            fi
        done

        # Existenz prüfen
        if [[ ! -d "$dir" ]]; then
            if ! mkdir -p "$dir" 2>/dev/null; then
                if [[ -n "$fallback_dir" ]]; then
                    dir="$fallback_dir"
                    mkdir -p "$dir" 2>/dev/null || { echo "❌ Cannot create fallback dir: $dir"; return 1; }
                else
                    echo "❌ Cannot create dir: $dir"; return 1
                fi
            fi
        fi

        # Schreibrechte prüfen
        if [[ ! -w "$dir" ]]; then
            if [[ -n "$fallback_dir" ]]; then
                dir="$fallback_dir"
                [[ ! -d "$dir" ]] && mkdir -p "$dir" 2>/dev/null || { echo "❌ Cannot create fallback dir: $dir"; return 1; }
            else
                echo "❌ Dir not writable: $dir"; return 1
            fi
        fi
        valid_dirs+=("$dir")
    done


    #-------------------- Dateien prüfen / erstellen --------------------
    [[ ${#files[@]} -eq 0 ]] && files=("$default_file")
    local resolved_files=()

    for file in "${files[@]}"; do
        for dir in "${valid_dirs[@]}"; do
            local path="$dir/$file"

            if [[ -f "$path" ]]; then
                case "$file_mode" in
                    prefix)
                        local new_name="$dir/$file_prefix$file"
                        path="$new_name"
                        touch "$path" 2>/dev/null || { echo "❌ Cannot create prefixed file: $path"; return 1; }
                        ;;
                    overwrite)
                        : # Datei existiert, wird überschrieben
                        ;;
                    append)
                        : # Datei existiert, append
                        ;;
                    *)
                        echo "❌ Unknown file_mode: $file_mode"; return 1 ;;
                esac
            else
                touch "$path" 2>/dev/null || {
                    if [[ -n "$fallback_file" ]]; then
                        path="$dir/$fallback_file"
                        touch "$path" 2>/dev/null || { echo "❌ Cannot create fallback file: $path"; return 1; }
                    else
                        echo "❌ Cannot create file: $path"; return 1
                    fi
                }
            fi
            resolved_files+=("$path")
        done
    done


    #-------------------- Nachricht in Dateien schreiben --------------------
    for file_path in "${resolved_files[@]}"; do
        case "$file_mode" in
            overwrite) echo -e "$message" > "$file_path" ;;
            append)    echo -e "$message" >> "$file_path" ;;
            prefix)    echo -e "$message" >> "$file_path" ;;
        esac
    done
}
