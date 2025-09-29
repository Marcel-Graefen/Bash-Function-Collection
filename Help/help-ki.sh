#!/bin/bash

# === Konfiguration ===
HELP_BASE_DIR="${HELP_BASE_DIR:-/home/marcel/Git_Public/Bash-Function-Collection/Help}"
HELP_LANGUAGE="${HELP_LANGUAGE:-auto}"
HELP_FORMAT="${HELP_FORMAT:-text}"
DEBUG_HELP="${DEBUG_HELP:-false}"

# === System Language Detection ===
__get_system_language() {
    local preferred_lang="$1"

    # Explizite Sprache verwenden falls angegeben
    if [[ -n "$preferred_lang" && "$preferred_lang" != "auto" ]]; then
        echo "$preferred_lang"
        return 0
    fi

    # Auto-Detektion aus System-Variablen
    local system_lang="en"

    # Priority order: LC_ALL, LC_MESSAGES, LANG
    for lang_var in LC_ALL LC_MESSAGES LANG; do
        if [[ -n "${!lang_var}" ]]; then
            system_lang="${!lang_var}"
            break
        fi
    done

    # Sprachcode extrahieren (de_DE.UTF-8 → de)
    system_lang="${system_lang%%.*}"    # Remove .UTF-8
    system_lang="${system_lang%%_*}"    # Remove _DE

    # Validate language code
    case "$system_lang" in
        de|en|fr|es|it|pt|ru|zh|ja|ko)
            echo "$system_lang"
            ;;
        *)
            echo "en"
            ;;
    esac
}

# === Hilfsfunktion: Suche in einem Directory ===
__find_file_in_dir() {
    local dir="$1"
    local language="$2"

    # Prüfe ob Directory existiert
    if [[ ! -d "$dir" ]]; then
        echo "NOT_FOUND"
        return 1
    fi

    # Debug-Ausgabe
    if [[ "$DEBUG_HELP" == "true" ]]; then
        echo "🔍 Searching in: $dir for language: $language" >&2
    fi

    # 1. PRIORITÄT: Angeforderte Sprache
    if [[ -f "$dir/$language.md" ]]; then
        echo "$dir/$language.md"
        return 0
    fi
    if [[ -f "$dir/$language.txt" ]]; then
        echo "$dir/$language.txt"
        return 0
    fi

    # 2. FALLBACK: Englisch
    if [[ "$language" != "en" ]]; then
        if [[ -f "$dir/en.md" ]]; then
            echo "$dir/en.md"
            return 0
        fi
        if [[ -f "$dir/en.txt" ]]; then
            echo "$dir/en.txt"
            return 0
        fi
    fi

    # 3. FALLBACK: Erste verfügbare Sprache im Directory
    local first_file=$(find "$dir" -maxdepth 1 -type f \( -name "*.md" -o -name "*.txt" \) | head -1)
    if [[ -n "$first_file" ]]; then
        echo "$first_file"
        return 0
    fi

    # 4. Nichts gefunden
    echo "NOT_FOUND"
    return 1
}

# === Vereinfachte Help-File Suche ===
__find_help_file() {
    local function_name="$1"
    local language="$2"

    if [[ "$DEBUG_HELP" == "true" ]]; then
        echo "🎯 Looking for help: function=$function_name, language=$language" >&2
    fi

    # 1. VERSUCH: Funktion-spezifische Hilfe
    local func_file="$(__find_file_in_dir "$HELP_BASE_DIR/functions/$function_name" "$language")"
    if [[ "$func_file" != "NOT_FOUND" ]]; then
        if [[ "$DEBUG_HELP" == "true" ]]; then
            echo "✅ Found function-specific help: $func_file" >&2
        fi
        echo "$func_file"
        return 0
    fi

    # 2. FALLBACK: Default-Hilfe
    local default_file="$(__find_file_in_dir "$HELP_BASE_DIR/functions/default" "$language")"
    if [[ "$default_file" != "NOT_FOUND" ]]; then
        if [[ "$DEBUG_HELP" == "true" ]]; then
            echo "🔧 Using default help: $default_file" >&2
        fi
        echo "$default_file"
        return 0
    fi

    # 3. FINAL: Nichts gefunden
    if [[ "$DEBUG_HELP" == "true" ]]; then
        echo "❌ No help file found for: $function_name" >&2
    fi
    echo "NOT_FOUND"
    return 1
}

# === Display-Hilfe Funktion ===
__display_help() {
    local help_file="$1"
    local format="$2"

    if [[ ! -f "$help_file" ]]; then
        echo "❌ Help file not found: $help_file" >&2
        return 1
    fi

    if [[ "$DEBUG_HELP" == "true" ]]; then
        echo "📄 Displaying help from: $help_file in format: $format" >&2
    fi

    case "$format" in
        "markdown")
            cat "$help_file"
            ;;
        "html")
            if command -v pandoc >/dev/null; then
                pandoc -f markdown -t html "$help_file"
            else
                echo "⚠️ pandoc not installed, showing raw markdown:" >&2
                cat "$help_file"
            fi
            ;;
        "json")
            if command -v jq >/dev/null; then
                jq -n --arg content "$(cat "$help_file")" \
                       --arg file "$(basename "$help_file")" \
                       --arg path "$help_file" \
                       '{file: $file, path: $path, content: $content}'
            else
                echo "{\"file\": \"$(basename "$help_file")\", \"content\": \"$(cat "$help_file" | sed 's/"/\\"/g')\"}"
            fi
            ;;
        "raw")
            cat "$help_file"
            ;;
        *)
            # Plain text mit einfachem Markdown-Filter
            sed -E 's/^#+ //g; s/\*\*([^*]+)\*\*/\1/g; s/\*([^*]+)\*/\1/g; s/`([^`]+)`/\1/g; s/\[([^]]+)\]\([^)]+\)/\1/g' "$help_file"
            ;;
    esac
}

# === Haupt-Help-Funktion ===
__help() {
    local function_name="$1"
    local requested_lang="${2:-auto}"
    local format="${3:-$HELP_FORMAT}"

    # Validierung
    if [[ -z "$function_name" ]]; then
        echo "❌ Function name required" >&2
        echo "Usage: __help <function_name> [language] [format]" >&2
        return 1
    fi

    # Sprache erkennen
    local language="$(__get_system_language "$requested_lang")"

    if [[ "$DEBUG_HELP" == "true" ]]; then
        echo "🌍 Detected language: $language" >&2
    fi

    # Help-File finden
    local help_file="$(__find_help_file "$function_name" "$language")"

    if [[ "$help_file" == "NOT_FOUND" ]]; then
        echo "❌ No help available for function: '$function_name'" >&2

        # Zeige verfügbare Funktionen
        if [[ -d "$HELP_BASE_DIR/functions" ]]; then
            local available_funcs=$(ls "$HELP_BASE_DIR/functions/" 2>/dev/null | tr '\n' ' ')
            if [[ -n "$available_funcs" ]]; then
                echo "💡 Available functions: $available_funcs" >&2
            fi
        fi

        return 1
    fi

    # Help anzeigen
    __display_help "$help_file" "$format"
}

# === Test-Funktion ===
__help_test() {
    echo "=== 🧪 HELP SYSTEM TEST ==="

    # Test language detection
    echo "🌍 Language Detection:"
    echo "  System: $(__get_system_language)"
    echo "  German: $(__get_system_language "de")"
    echo "  French: $(__get_system_language "fr")"

    # Test file finding
    echo ""
    echo "🔍 File Finding:"
    local test_file="$(__find_help_file "parse_case_flags" "de")"
    echo "  parse_case_flags de: $test_file"

    # Test help display
    echo ""
    echo "📄 Help Display:"
    if [[ -f "$test_file" ]]; then
        __help "parse_case_flags" "de" "text"
    else
        echo "  Test file not found, trying default..."
        __help "test_function" "en" "text"
    fi
}

# === Debug-Funktion ===
__help_debug() {
    local function_name="$1"
    echo "=== 🐛 HELP DEBUG ==="
    DEBUG_HELP=true __help "$function_name" "${2:-auto}" "${3:-text}"
}

# === Verfügbare Funktionen auflisten ===
__help_list() {
    echo "=== 📚 AVAILABLE HELP FUNCTIONS ==="

    if [[ ! -d "$HELP_BASE_DIR/functions" ]]; then
        echo "❌ Help directory not found: $HELP_BASE_DIR/functions"
        return 1
    fi

    for func_dir in "$HELP_BASE_DIR/functions"/*; do
        if [[ -d "$func_dir" ]]; then
            local func_name=$(basename "$func_dir")
            local lang_files=$(find "$func_dir" -name "*.md" -o -name "*.txt" | xargs -I {} basename {} | tr '\n' ' ')
            echo "📁 $func_name: $lang_files"
        fi
    done
}

# === Auto-completion Setup (optional) ===
__help_completion() {
    local current="${COMP_WORDS[COMP_CWORD]}"
    if [[ "$COMP_CWORD" -eq 1 ]]; then
        # Vervollständige Funktionsnamen
        if [[ -d "$HELP_BASE_DIR/functions" ]]; then
            COMPREPLY=($(compgen -W "$(ls "$HELP_BASE_DIR/functions/")" -- "$current"))
        fi
    elif [[ "$COMP_CWORD" -eq 2 ]]; then
        # Vervollständige Sprachen
        COMPREPLY=($(compgen -W "auto de en fr es it pt ru zh ja ko" -- "$current"))
    elif [[ "$COMP_CWORD" -eq 3 ]]; then
        # Vervollständige Formate
        COMPREPLY=($(compgen -W "text markdown html json raw" -- "$current"))
    fi
}

# Auto-completion registrieren (falls gewünscht)
if command -v complete >/dev/null; then
    complete -F __help_completion __help
    complete -F __help_completion __help_debug
fi


__help "parse_case_flag"
