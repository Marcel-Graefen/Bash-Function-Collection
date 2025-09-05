# 📂 Bash Functions Collection

[![German](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Welcome to the **Bash Functions Collection**!
This repository contains a collection of useful Bash functions that are modular, documented, and can be directly integrated into your own scripts.

---

## 📌 Quick Overview

This repository provides modular Bash functions that can be directly included in scripts:

* [⚙️ Normalize List](#%EF%B8%8F-normalize-list) – Splits input strings by spaces, commas, pipes, or custom delimiters and returns a clean array. [🔗 Full Documentation](Normalize_List/README.md)
* [📋 Display Table](#-display-table) – Displays formatted tables in the terminal, automatically calculates column widths, and centers headers. Supports multiple rows and custom separators. [🔗 Full Documentation](Display_Table/README.md)
* [✅ Check Requirements](#-check-requirements) – Checks Bash version, required functions, programs, alternative program groups, and optionally root privileges. [🔗 Full Documentation](Check_Requirements/README.md)
* [📂 Resolve Paths](#-resolve-paths) – Normalizes input paths and converts them to absolute paths. [🔗 Full Documentation](Resolve_Paths/README.md)
* [📋 Classify Paths](#-classify-paths) – Classifies paths by **existence** and **permissions**, including wildcards (`*`, `**`), and stores results in named arrays. [🔗 Full Documentation](Classify_Paths/README.md)
* [📋 Log Call Chain](#-log-call-chain) – Logs **nested function and script calls**, generates ASCII trees, supports multiple log files, details, error messages, and suppressions. [🔗 Full Documentation](Log_Call_Chain/README.md)
* [📋 Parse Case Flags](#-parse-case-flags) – Parses, validates, and assigns command-line flags within a case block. [🔗 Full Documentation](Parse_Case_Flags/README.md)
* [🤖 Generation Note](#-generation-note)
* [👤 Author & Contact](#-author--contact)

---

## ⚙️ Normalize List

### A flexible Bash function to normalize input strings into arrays.

It splits strings by spaces, commas, pipes, or custom delimiters and returns a clean array.

* 🟢 **Flexible Input:** Accepts one or more strings simultaneously.
* 🔹 **Custom Delimiters:** Regex-like, e.g., space, comma, pipe, or custom characters.
* 🟣 **Array Output:** Populates a Bash array via Nameref (`--out|--output`).
* 🔒 **Robust Error Handling:** Missing parameters are detected and reported.
* ⚡ **Easy Integration:** Can be directly included in scripts, no external dependencies.
* 💡 **Return Value:** 0 on success, 2 on error.

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

### A flexible Bash function to display formatted tables in the terminal.

It automatically calculates column widths, centers headers, and formats each row neatly.

* 🟢 **Flexible Rows & Columns:** Each row can contain multiple columns.
* 🔹 **Automatic Column Widths:** Adjusts column width to longest content.
* 🟣 **Header Centering:** Optional table header is centered.
* 🔒 **Robust Error Checking:** Checks for missing functions.
* ⚡ **Easy Integration:** Can be directly included in Bash scripts.
* 💡 **Return Value:** 0 on success, 2 if required functions are missing.

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

* 🟢 **Check Bash Version:** Optional for major/minor versions.
* ⚙️ **Check Functions:** Functions to check via `--funcs/-f`.
* 🟣 **Check Programs:** Programs via `--programs/-p` or alternative groups `--programs-alternative/-a`.
* 🔒 **Root Privileges:** Optional via `--root/-r` or `--sudo/-s`.
* ⚡ **Flexible Error Handling:** With `--exit/-x`, decides whether the script exits on error.
* 🔍 **Full Verification:** All requirements are checked first; return after completion.
* 💡 **Return Values:** 0 on success, 2 if one or more errors.

**Short example:**

```bash
check_requirements --major 4 --funcs "normalize_list" --programs "awk" --programs-alternative "git svn" --root
```

[🔗 Full Documentation](Check_Requirements/README.md)

---

## 📂 Resolve Paths

### Normalizes input paths and converts them to absolute paths.

* 🗂️ **Normalize Input:** Multiple `-i/--input`, `-d/--dir`, `-f/--file`.
* 🔹 **Absolute Paths:** Normalization via `realpath -m`.
* ✨ **Wildcard Expansion:** Supports `*` and `**` (Globstar).
* 🟣 **Existence Check:** Separates existing and missing paths.
* 💡 **Return Values:** 0 on success, 2 on error.

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

* 🗂️ **Normalize Input:** Multiple `-i/--input`, `-d/--dir`, `-f/--file`.
* 🔹 **Absolute Paths:** Normalization via `realpath -m`.
* ✨ **Wildcard Expansion:** `*` and `**` (Globstar), dotfiles included.
* 🔒 **Permission Checks:** r/w/x, combinations (rw, rx, wx, rwx), negations (`-` / `not`).
* ⚡ **Flexible Separators:** Default `|`. Special characters, spaces, or no separator allowed. Invalid values → warning.
* 🟣 **Existence & Classification:** `file`, `dir`, `missing`. Permission keys: `file.{mask}`, `dir.{mask}`, `{mask}`, `{mask,not}`.
* ♻️ **Duplicate Removal:** Removes duplicate paths; existing/missing separated.
* ⚠️ **Logging & Warnings:** Invalid masks or separators are reported.
* 💡 **Return Values:** 0 on success, 2 on error.

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

### A Bash function for **fully logging nested function and script calls**.

Generates an **ASCII tree** of the call chain, including shortened paths, error logs, and optional details. Supports multiple log files and directories, as well as suppression of specific functions or scripts.

* 📋 **Hierarchical Logging:** Function and script calls displayed in a tree format.
* ✨ **Shortened Paths:** Shows only first folder + ... + script name.
* 💬 **Message & Details:** `-m/--message` for a short description, `-D/--details` for detailed error messages.
* 🗂️ **Flexible Log Output:** Supports multiple log files and directories.
* ❌ **Suppressions:** Certain functions or scripts can be excluded from the call chain.
* ⚡ **Error Logging:** Logs directories that do not exist or are not writable.
* 📝 **Legend:** Full paths of scripts at the end; other log files listed if more than one exists.

**Short example:**

```bash
log_call_chain -s INFO -m "Starting process" -d "/tmp" -f "process.log"
```

**Detailed example:**

```bash
log_call_chain -s ERROR -m "Failed task" -D "Detailed error description with stack trace" -d "/tmp/logs" -f "error.log"
```

**Suppressing functions:**

```bash
log_call_chain -s WARNING -m "Partial run" -x "func_to_skip" -d "/tmp/logs" -f "partial.log"
```

[🔗 Full Documentation](Log_Call_Chain/README.md)

---

## 📋 Parse Case Flags

### A Bash function for **parsing, validating, and assigning command-line flags within a case block**.

Supports **single values, arrays, toggle flags**, validates values for numbers, letters, or forbidden characters/values, and keeps **all remaining arguments** after processing.

* 🎯 **Flag Parsing:** Single flags, arrays, and toggle options supported.
* 🔢 **Number Validation:** `--number` allows numeric values only.
* 🔤 **Letter Validation:** `--letters` allows alphabetic characters only.
* ❌ **Forbidden Characters & Values:** `--forbid` and `--forbid-full` prevent specific


characters or whole values (wildcards `*` supported).

* 💾 **Variable Assignment:** Dynamic assignment via Nameref (`declare -n`).
* 🔄 **Keep Remaining Arguments:** All unprocessed CLI arguments remain in `"$@"`.
* ⚡ **Toggle Flags:** Flags without values set the variable to `true`.
* 🔗 **Combinable Options:** All validation options can be combined, e.g., `--array --number --forbid-full "root" "admin*"`.

**Short Example:**

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

**Array Example:**

```bash
parse_case_flags --tags tags_array --array Dev Ops QA -i "$@" || return 1
```

**Toggle Example:**

```bash
parse_case_flags --verbose verbose_flag --toggle -i "$@" || return 1
```

**Combined Options Example:**

```bash
parse_case_flags --ids ids_array --array --number --forbid-full "0" "999" 1 2 3 -i "$@" || return 1
```

[🔗 Full Documentation](Parse_Case_Flags/README.md)

---

## 🤖 Generation Note

This project was developed with the help of Artificial Intelligence (AI). Scripts, comments, and documentation were finalized and verified manually.

---

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)
* 📄 [MIT License](LICENSE)
