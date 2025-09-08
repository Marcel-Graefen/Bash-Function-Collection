# 📂 Bash Functions Collection

[![German](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Welcome to the **Bash Functions Collection**!
This repository contains a collection of useful Bash functions that are modular, documented, and can be directly integrated into your scripts.

---

## 📌 Quick Summary

This repository contains modular Bash functions that can be directly sourced into scripts:

* [⚙️ Normalize List](#-normalize-list) – Splits input strings by spaces, commas, pipes, or custom delimiters and returns a clean array. [🔗 Full Documentation](Normalize_List/README.md)
* [📋 Display Table](#-display-table) – Displays formatted tables in the terminal, automatically calculates column widths, centers headers, and supports multiple lines. [🔗 Full Documentation](Display_Table/README.md)
* [✅ Check Requirements](#-check-requirements) – Checks Bash version, required functions, programs, alternative program groups, and optional root privileges. [🔗 Full Documentation](Check_Requirements/README.md)
* [📂 Resolve Paths](#-resolve-paths) – Normalizes input paths and converts them to absolute paths. [🔗 Full Documentation](Resolve_Paths/README.md)
* [📋 Classify Paths](#-classify-paths) – Classifies paths by **existence** and **permissions**, supports wildcards (`*`, `**`), and stores results in named arrays. [🔗 Full Documentation](Classify_Paths/README.md)
* [📋 Log Call Chain](#-log-call-chain) – Logs **nested function and script calls**, generates ASCII trees, supports multiple log files, details, errors, and exclusions. [🔗 Full Documentation](Log_Call_Chain/README.md)
* [📋 Parse Case Flags](#-parse-case-flags) – Parses, validates, and assigns command-line flags within a case block. [🔗 Full Documentation](Parse_Case_Flags/README.md)
* [📂 Format Message Line](#-format-message-line) – Formats messages into decorative lines with brackets, fill characters, padding, and minimum length. [🔗 Full Documentation](Format_Message_Line/README.md)
* [🤖 Generation Note](#-generation-note)
* [👤 Author & Contact](#-author--contact)

---

## ⚙️ Normalize List

### A flexible Bash function to normalize input strings into arrays. It splits strings by spaces, commas, pipes, or custom delimiters and returns a clean array.

* 🟢 **Flexible input:** Accepts one or multiple strings.
* 🔹 **Custom delimiters:** Regex-like, e.g., space, comma, pipe, or custom characters.
* 🟣 **Array output:** Populates a Bash array via Nameref (`--out|--output`).
* 🔒 **Robust error handling:** Detects missing parameters.
* ⚡ **Easy integration:** Can be sourced directly, no external dependencies.
* 💡 **Return codes:** 0 on success, 2 on error.

**Short example:**

```bash
declare -a my_array

normalize_list -i "apple orange,banana|kiwi" --out my_array

printf "%s\n" "${my_array[@]}"
```

**Output:**

```
apple
orange
banana
kiwi
```

[🔗 Full Documentation](Normalize_List/README.md)

---

## 📋 Display Table

### A flexible Bash function for displaying formatted tables in the terminal. Automatically calculates column widths, centers the header, and outputs each row neatly.

* 🟢 **Flexible rows & columns:** Each row can contain multiple columns.
* 🔹 **Automatic column width:** Adjusts to the longest content.
* 🟣 **Header centering:** Optional table header is centered.
* 🔒 **Robust error checking:** Checks for missing functions.
* ⚡ **Easy integration:** Can be sourced directly.
* 💡 **Return codes:** 0 on success, 2 if required functions are missing.

**Short example:**

```bash
display_table -H "My Table" \
  -v "Value1,Value2,Value3" \
  -v "A,B,C"
```

**Output:**

```
+--------+--------+--------+
|       My Table          |
+--------+--------+--------+
| Value1 | Value2 | Value3 |
+--------+--------+--------+
| A      | B      | C      |
+--------+--------+--------+
```

[🔗 Full Documentation](Display_Table/README.md)

---

## ✅ Check Requirements

### A Bash function to check script requirements: Bash version, functions, programs, and optionally root privileges.

* 🟢 **Check Bash version:** Optionally major/minor.
* ⚙️ **Check functions:** Via `--funcs/-f`.
* 🟣 **Check programs:** Via `--programs/-p` or alternative groups `--programs-alternative/-a`.
* 🔒 **Root check:** Optional via `--root/-r` or `--sudo/-s`.
* ⚡ **Flexible error handling:** `--exit/-x` determines whether to exit immediately on failure.
* 🔍 **Complete check:** All requirements are evaluated first; return code after completion.
* 💡 **Return codes:** 0 on success, 2 if one or more checks fail.

**Short example:**

```bash
check_requirements --major 4 --funcs "normalize_list" --programs "awk" --programs-alternative "git svn" --root
```

[🔗 Full Documentation](Check_Requirements/README.md)

---

## 📂 Resolve Paths

### Normalizes input paths and converts them to absolute paths.

* 🗂️ **Normalize inputs:** Multiple `-i/--input`, `-d/--dir`, `-f/--file`.
* 🔹 **Absolute paths:** Normalization via `realpath -m`.
* ✨ **Wildcard support:** `*` and `**` (Globstar).
* 🟣 **Existence check:** Separates existing from missing paths.
* 💡 **Return codes:** 0 on success, 2 on error.

**Short example:**

```bash
declare -a all exist

resolve_paths -i "file1.txt,file2.txt,/tmp/file3" --out-all all --out-exist exist

printf "All: %s\nExist: %s\n" "${all[*]}" "${exist[*]}"
```

[🔗 Full Documentation](Resolve_Paths/README.md)

---

## 📋 Classify Paths

### Classifies paths by **existence** and **permissions** (r/w/x, rw, rx, wx, rwx) and stores results in named arrays. Supports wildcards (`*`, `**`) and flexible separators.

* 🗂️ **Normalize inputs:** Multiple `-i/--input`, `-d/--dir`, `-f/--file`.
* 🔹 **Absolute paths:** `realpath -m`.
* ✨ **Wildcard support:** `*` and `**`, dotfiles included.
* 🔒 **Permission check:** r/w/x, combinations (rw, rx, wx, rwx), negations (`-` / `not`).
* ⚡ **Flexible separators:** Default `|`. Special characters, spaces, or no separator allowed. Invalid values → warning.
* 🟣 **Existence & classification:** `file`, `dir`, `missing`. Permission keys: `file.{mask}`, `dir.{mask}`, `{mask}`, `{mask,not}`.
* ♻️ **Duplicate detection:** Removes duplicate paths; existing/missing separated.
* ⚠️ **Logging & warnings:** Invalid masks or separators are reported.
* 💡 **Return codes:** 0 on success, 2 on error.

**Short example:**

```bash
declare -A Hallo

classify_paths -i "/tmp/file1 /tmp/file2 /tmp/nonexistent" -o Hallo -p "r w x rwx"

echo "All files: ${Hallo[all]}"
echo "Existing files: ${Hallo[file]}"
echo "Missing files: ${Hallo[missing]}"
```

[🔗 Full Documentation](Classify_Paths/README.md)

---

## 📋 Log Call Chain

### Logs **nested function and script calls** in Bash.

Generates an **ASCII tree** of the call chain, including truncated paths, error logs, optional details, multiple log files, and directories.

* 📋 **Hierarchical logging:** Function and script calls in tree structure.
* ✨ **Truncated paths:** Shows first folder + … + script name.
* 💬 **Messages & details:** `-m/--message` short description, `-D/--details` detailed error info.
* 🗂️ **Flexible log output:** Multiple log files and directories supported.
* ❌ **Exclusions:** Skip certain functions or scripts.
* ⚡ **Error logging:** Reports non-existing or unwritable directories.
* 📝 **Legend:** Full paths at the end; other log files listed if multiple.

**Short example:**

```bash
log_call_chain -s INFO -m "Starting process" -d "/tmp" -f "process.log"
```

**Detailed example:**

```bash
log_call_chain -s ERROR -m "Failed task" -D "Detailed error description with stack trace" -d "/tmp/logs" -f "error.log"
```

**Suppress functions:**

```bash
log_call_chain -s WARNING -m "Partial run" -x "func_to_skip" -d "/tmp/logs" -f "partial.log"
```

[🔗 Full Documentation](Log_Call_Chain/README.md)

---

## 📋 Parse Case Flags

### Parses, validates, and assigns command-line flags within a case block.

Supports **single values, arrays, toggle flags**, checks for numbers, letters, forbidden characters/values, and preserves **all remaining CLI arguments**.

* 🎯 **Flag Parsing:** Single flags, arrays, toggle options.
* 🔢 **Number validation:** `--number` allows only numeric values.
* 🔤 **Letters validation:** `--letters` allows only alphabetic characters.
* ❌ **Forbidden characters & values:** `--forbid` and `--forbid-full` prevent specific chars or whole values (wildcards `*` supported).
* 💾 **Variable assignment:** Via Nameref (`declare -n`).
* 🔄 **Preserves remaining args:** `$@` keeps unprocessed arguments.
* ⚡ **Toggle flags:** Flags without value set variable to `true`.
* 🔗 **Combinable options:** e.g., `--array --number --forbid-full "root" "admin*"`.

**Short example:**

```bash
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      parse_case_flags "$1" name_var --letters "$2" -i "$@" || return 1
      shift 2
      ;;
  esac
done
```

**Array example:**

```bash
parse_case_flags --tags tags_array --array Dev Ops QA -i "$@" || return 1
```

**Toggle example:**

```bash
parse_case_flags --verbose verbose_flag --toggle -i "$@" || return 1
```

**Combined options example:**

```bash
parse_case_flags --ids ids_array --array --number --forbid-full "0" "999" 1 2 3 -i "$@" || return 1
```

[🔗 Full Documentation](Parse_Case_Flags/README.md)

---

## 📂 Format Message Line

### Formats messages into decorative lines with brackets, fill characters, padding, and minimum length.

Supports **different brackets, fill characters, inner & outer padding**, and minimum line length.
Output is sent via `echo` by default or saved to a variable (`-r|--result`).

* 🎯 **Flexible text formatting** – Decorative lines for messages, headers, or status indicators.
* 🔢 **Minimum length** – Lines are automatically expanded to the defined length.
* ↔️ **Inner & outer padding** – Adjustable spacing between brackets, text, and fill characters.
* 🔤 **Various brackets** – Supports `[]`, `()`, `{}`, `<>`.
* 💾 **Output via echo or variable** – Default `echo`, or use `-r|--result`.
* ⚡ **Combinable parameters** – All options can be combined for complex layouts.

**Short example:**

```bash
format_message_line -m "Hello World"
```

Output via `echo`:

```
=================[Hello World]=================
```


[🔗 Full Documentation](Format_Message_Line/README.md)

---

## 🤖 Generation Note

This project was created with the help of Artificial Intelligence (AI).
Scripts, comments, and documentation were manually checked and finalized.

---

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)
* 📄 [MIT License](LICENSE)
