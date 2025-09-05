Hier ist ein Beispiel, das **alles zusammenführt**:

```bash
write_log() {
    local LOG_TYPE=""
    local LOG_MESSAGE=""
    local LOG_DETAILS=""
    local LOG_DIR=""
    local LOG_FILE=""
    local ENABLE_CALLCHAIN=false
    local SHOW_TERMINAL="${SHOW_LOG_IN_TERMINAL:-true}"
    local TEMPLATE=""

    # --------- Parse parameters ---------
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s|--status) LOG_TYPE="$2"; shift 2;;
            -m|--message|--msg) LOG_MESSAGE="$2"; shift 2;;
            -D|--details) LOG_DETAILS="$2"; shift 2;;
            -l|--log) ENABLE_CALLCHAIN=true; shift;;
            -d|--dir) LOG_DIR="$2"; shift 2;;
            -f|--file) LOG_FILE="$2"; shift 2;;
            -t|--template) TEMPLATE="$2"; shift 2;;
            *) echo "❌ [ERROR] Unknown parameter: $1"; return 1;;
        esac
    done

    # --------- Validate required parameters ---------
    [[ -z "$LOG_TYPE" || -z "$LOG_MESSAGE" ]] && {
        echo "❌ [ERROR] Missing required parameters -s and -m"; return 1
    }

    # --------- Resolve log file ---------
    if [[ -n "$LOG_DIR" ]]; then
        mkdir -p "$LOG_DIR" 2>/dev/null || {
            echo "❌ [ERROR] Cannot create log directory: $LOG_DIR"; return 2
        }
    fi

    [[ -z "$LOG_FILE" ]] && LOG_FILE="${LOG_DIR:-/tmp}/log_callchain_$(date +%s).log"
    [[ -n "$LOG_DIR" && -n "$LOG_FILE" ]] && LOG_FILE="${LOG_DIR}/${LOG_FILE}"

    # --------- Apply template if provided ---------
    if [[ -n "$TEMPLATE" ]]; then
        TEMPLATE="${TEMPLATE,,}"
        [[ "$TEMPLATE" =~ _log_template$ ]] || TEMPLATE="${TEMPLATE}_log_template"
        if declare -f "$TEMPLATE" >/dev/null 2>&1; then
            LOG_MESSAGE="$("$TEMPLATE" "$LOG_MESSAGE" "$LOG_DETAILS")"
        else
            echo "❌ [ERROR] Unknown template function: '$TEMPLATE'"; return 2
        fi
    fi

    # --------- Call chain logging ---------
    local CHAIN="[$(basename "$0")]"
    if $ENABLE_CALLCHAIN && declare -f log_call_chain >/dev/null 2>&1; then
        log_call_chain -s "$LOG_TYPE" -m "$LOG_MESSAGE" -D "$LOG_DETAILS" -d "$LOG_DIR" -f "$LOG_FILE" -x "log_to_console"
        CHAIN=""
    fi

    # --------- Terminal output ---------
    if [[ "$LOG_TYPE" =~ ^INFO$ ]]; then
        [[ "$SHOW_TERMINAL" == "true" ]] && log_to_console "💡" "$LOG_MESSAGE"
    elif [[ "$LOG_TYPE" =~ ^WARNING$ ]]; then
        [[ "$SHOW_TERMINAL" == "true" ]] && {
            echo -e "⚠️  [WARNING]$CHAIN $LOG_MESSAGE"
            [[ -n "$LOG_FILE" ]] && echo -e "   ↳ See detailed log here ($LOG_FILE)"
        }
    elif [[ "$LOG_TYPE" =~ ^ERROR$ ]]; then
        [[ "$SHOW_TERMINAL" == "true" ]] && {
            echo -e "❌ [ERROR]$CHAIN $LOG_MESSAGE"
            [[ -n "$LOG_FILE" ]] && echo -e "   ↳ See detailed log here ($LOG_FILE)"
        }
    else
        [[ "$SHOW_TERMINAL" == "true" ]] && echo -e "[$LOG_TYPE]$CHAIN $LOG_MESSAGE"
    fi

    # --------- Write to logfile ---------
    {
        echo "[$(date +"%Y-%m-%d %H:%M:%S")] [$LOG_TYPE] $LOG_MESSAGE"
        [[ -n "$LOG_DETAILS" ]] && echo -e "\t$LOG_DETAILS"
    } >> "$LOG_FILE"
}
```

---

### Beispielaufrufe:

```bash
# INFO mit Terminalausgabe und Call-Chain
write_log -s INFO -m "Starting process" -l -d "/tmp" -f "process.log"

# WARNING mit Details, Call-Chain und Template
write_log -s WARNING -m "Partial run completed" -D "Some files missing" -t "blog" -l -d "/tmp" -f "process.log"

# ERROR mit Details
write_log -s ERROR -m "Failed to open file" -D "Permission denied" -l -d "/tmp" -f "process.log"
```

---

### Features dieser Version:

1. **Terminalausgabe über `log_to_console`** für INFO, WARNING, ERROR.
2. **Optionaler Call-Chain-Log** (`-l|--log`) über `log_call_chain`.
3. **Templates** bleiben nutzbar (`-t|--template`).
4. **Details** werden in der Datei gespeichert (`-D|--details`), aber nicht direkt im Terminal.
5. Log-Datei lässt sich frei wählen (`-d|--dir` und `-f|--file`).

---

Wenn du willst, kann ich noch **eine Variante bauen, bei der INFO-Logs auch einen Link zum Logfile anzeigen**, ähnlich wie bei WARNING/ERROR, ohne die Ausgabe zu überladen.

Willst du, dass ich das gleich einbaue?
