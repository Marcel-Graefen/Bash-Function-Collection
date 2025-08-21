# 📂 Bash Functions Collection

[![Deutsch](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Welcome to the **Bash Functions Collection**!
This repository contains a set of useful Bash functions, which are modular, documented, and can be directly integrated into your own scripts.

---

## 📌 Short Summary

This repository provides modular Bash functions that can be directly included in scripts.

* [⚙️ Normalize List](#%EF%B8%8F-normalize-list) – Splits input strings based on spaces, commas, pipes, or custom separators and returns a clean array. [🔗 Full documentation](Normalize%20List/README.md)
* [📋 Display Table](#-display-table) – Displays formatted tables in the terminal, automatically calculating column widths and centering the header. Supports multiple rows and custom separators. [🔗 Full documentation](Display%20Table/README.md)
* [✅ Check Requirements](#-check-requirements) – Checks Bash version, required functions, programs, alternative program groups, and optionally root privileges. [🔗 Full documentation](Check%20Requirements/README.md)
* [📂 Resolve Paths](#-resolve-paths) – Normalizes input paths, converts them to absolute paths, and classifies them by existence, readability, and writability. [🔗 Full documentation](Resolve%20Paths/README.md)
* [👤 Author & Contact](#-author--contact)
* [🤖 Generation Note](#-generation-note)
* [📜 License](#-license)

---

## ⚙️ Normalize List

### A flexible Bash function to normalize input strings into arrays. It splits strings by spaces, commas, pipes, or custom separators and returns a clean array.

* 🟢 **Flexible Input:** Accepts one or more strings at a time.
* 🔹 **Custom Separators:** Regex-like, e.g., space, comma, pipe, or user-defined characters.
* 🟣 **Array Output:** Populates a Bash array via nameref (`-o|--output`).
* 🔒 **Robust Error Handling:** Detects and reports missing parameters.
* ⚡ **Easy Integration:** Can be directly embedded in scripts with no external dependencies.
* 💡 **Return Value:** 0 on success, 2 on errors.

**Quick Example:**

```bash
declare -a my_array

normalize_list -i "apple orange,banana|kiwi" -o my_array

# Check output
printf "%s\n" "${my_array[@]}"
```

**Output:**

```
apple
orange
banana
kiwi
```

[🔗 Full documentation and more options available here](Normalize%20List/README.md)

---

## 📋 Display Table

### A flexible Bash function to display formatted tables in the terminal. Automatically calculates column widths, centers the header, and prints each row neatly.

* 🟢 **Flexible Rows & Columns:** Each row can contain multiple columns.
* 🔹 **Automatic Column Widths:** Adjusts column widths to the longest content.
* 🟣 **Header Centering:** Optional table header is centered.
* 🔒 **Robust Error Checking:** Detects missing functions.
* ⚡ **Easy Integration:** Can be directly embedded in Bash scripts.
* 💡 **Return Value:** 0 on success, 2 if required functions are missing.

**Quick Example:**

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

[🔗 Full documentation and more options available here](Display%20Table/README.md)

---

## ✅ Check Requirements

### A Bash function to check script requirements such as Bash version, required functions, and programs. Optionally checks for root privileges and alternative program groups.

* 🟢 **Check Bash Version:** Optional major/minor version requirement.
* ⚙️ **Check Functions:** Use `--funcs/-f` to specify required functions.
* 🟣 **Check Programs:** Via `--programs/-p` or groups `--programs-alternative/-a`.
* 🔒 **Check Root Privileges:** Optional via `--root/-r` or `--sudo/-s`.
* ⚡ **Flexible Error Handling:** `--exit/-x` controls immediate exit on first error or returns a code.
* 🔍 **Comprehensive Check:** All specified requirements are verified first; return or exit occurs after all checks.
* 💡 **Return Values:** 0 on success, 2 on one or more errors.

**Quick Example:**

```bash
# Checks Bash ≥ 4, normalize_list function, awk program, at least one of git or svn, and root privileges
check_requirements --major 4 --funcs "normalize_list" --programs "awk" --programs-alternative "git svn" --root
```

[🔗 Full documentation and more options available here](Check%20Requirements/README.md)

---

## 📂 Resolve Paths

### A Bash function to normalize and resolve file paths, automatically expand wildcards (*, ?), classify paths by existence and individual or combined permissions (r/w/x, rw, rx, wx, rwx), and optionally map the results into named arrays.

* 🗂️ **Normalize inputs:** Automatically split paths by spaces or custom characters.
* 🔹 **Absolute paths:** Converts relative paths to absolute paths (`realpath`).
* ✨ **Automatic wildcard expansion:** Supports `*` and `**` (Globstar).
* 🟣 **Existence check:** Separates existing from missing paths.
* 🔒 **Permission check:** Checks readability (`r`), writeability (`w`), executability (`x`) and combinations (`rw`, `rx`, `wx`, `rwx`) including negations.
* ⚡ **Flexible output:** Results can be written into named arrays.
* ❌ **Input protection:** Leading `/ **/` paths are rejected.
* ❌ **Separator check:** Separators cannot contain `/`, `*`, or `.`.
* 💡 **Return values:** `0` for success, `2` for error.

**Quick Example:**

```bash
declare -a all exist

resolve_paths -i "file1.txt,file2.txt,/tmp/file3" -o-all all -o-exist exist

printf "All: %s\nExist: %s\n" "${all[*]}" "${exist[*]}"
```

**Output:**

```
All: file1.txt file2.txt /tmp/file3
Exist: /tmp/file3
```

[🔗 Full documentation and more options available here](Resolve%20Paths/README.md)

---

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)

---

## 🤖 Generation Note

This project was developed with the help of Artificial Intelligence (AI).
The AI assisted in creating the script, comments, and documentation (README.md).
The final result was reviewed and adapted by me.

---

## 📜 License

[MIT License](LICENSE)
