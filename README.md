# 📂 Bash Functions Collection

[![Deutsch](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Welcome to the **Bash Functions Collection**!
This repository contains a set of useful Bash functions that are modular, documented, and can be directly integrated into your own scripts.

---

## 📌 Quick Overview

This repository provides modular Bash functions that can be directly included in scripts:

* [⚙️ Normalize List](#%EF%B8%8F-normalize-list) – Splits input strings by spaces, commas, pipes, or custom delimiters and returns a clean array. [🔗 Full Documentation](Normalize_List/README.md)
* [📋 Display Table](#-display-table) – Displays formatted tables in the terminal, automatically calculates column widths, and centers headers. Supports multiple rows and custom separators. [🔗 Full Documentation](Display_Table/README.md)
* [✅ Check Requirements](#✅-check-requirements) – Checks Bash version, required functions, programs, alternative program groups, and optional root privileges. [🔗 Full Documentation](Check_Requirements/README.md)
* [📂 Resolve Paths](#📂-resolve-paths) – Normalizes input paths and converts them to absolute paths. [🔗 Full Documentation](Resolve_Paths/README.md)
* [📋 Classify Paths](#📋-classify-paths) – Classifies paths by **existence** and **permissions** including wildcards (`*`, `**`) and stores results in named arrays. [🔗 Full Documentation](Classify_Paths/README.md)
* [🤖 Generation Note](#🤖-generation-note)
* [👤 Author & Contact](#👤-author--contact)

---

## ⚙️ Normalize List

### A flexible Bash function to normalize input strings into arrays. It splits strings by spaces, commas, pipes, or custom delimiters and returns a clean array.

* 🟢 **Flexible Input:** Accepts one or multiple strings at once.
* 🔹 **Custom Delimiters:** Regex-like, e.g., space, comma, pipe, or custom characters.
* 🟣 **Array Output:** Populates a Bash array using nameref (`--out|--output`).
* 🔒 **Robust Error Handling:** Detects and reports missing parameters.
* ⚡ **Easy Integration:** Can be embedded directly in scripts, no external dependencies.
* 💡 **Return Value:** 0 on success, 2 on error.

**Short Example:**

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

### A flexible Bash function to display formatted tables in the terminal. It automatically calculates column widths, centers the header, and formats each row neatly.

* 🟢 **Flexible Rows & Columns:** Each row can contain multiple columns.
* 🔹 **Automatic Column Widths:** Adjusts column width to longest content.
* 🟣 **Header Centering:** Optional table header is centered.
* 🔒 **Robust Error Checking:** Checks for missing functions.
* ⚡ **Easy Integration:** Can be embedded directly in Bash scripts.
* 💡 **Return Value:** 0 on success, 2 if required functions are missing.

**Short Example:**

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

* 🟢 **Check Bash Version:** Optional Major/Minor.
* ⚙️ **Check Functions:** Functions to verify via `--funcs/-f`.
* 🟣 **Check Programs:** Programs via `--programs/-p` or alternative groups via `--programs-alternative/-a`.
* 🔒 **Check Root Privileges:** Optional via `--root/-r` or `--sudo/-s`.
* ⚡ **Flexible Error Handling:** With `--exit/-x` the script can exit immediately or return after errors.
* 🔍 **Complete Check:** All requirements are checked first; results are returned after completion.
* 💡 **Return Values:** 0 on success, 2 on one or more errors.

**Short Example:**

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

**Short Example:**

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

**Short Example:**

```bash
declare -A Hallo

classify_paths -i "/tmp/file1 /tmp/file2 /tmp/nonexistent" -o Hallo -p "r w x rwx"

echo "All files: ${Hallo[all]}"
echo "Existing files: ${Hallo[file]}"
echo "Missing files: ${Hallo[missing]}"
```

[🔗 Full Documentation](Classify_Paths/README.md)

---

## 🤖 Generation Note

This project was developed with the help of Artificial Intelligence (AI). Scripts, comments, and documentation were finalized and verified manually.

---

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)
* 📄 [MIT License](LICENSE)
