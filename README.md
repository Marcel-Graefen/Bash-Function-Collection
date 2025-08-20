# 📂 Bash Functions Collection

[![Deutsch](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Welcome to the **Bash Functions Collection**!
This repository contains a collection of useful Bash functions that are modular, documented, and can be integrated directly into your scripts.

---

## 📌 Quick Overview

This repository provides modular Bash functions that can be included directly in scripts.

* [⚙️ Normalize List](#%EF%B8%8F-normalize-list) – Splits input strings based on spaces, commas, pipes, or custom separators and returns a clean array. [Full documentation](Normalize%20List/README.md)
* [📋 Display Table](#-display-table) – Displays formatted tables in the terminal, automatically calculates column widths, and centers the header. Supports multiple rows and custom separators. [Full documentation](Display%20Table/README.de.md)
* [✅ Check Requirements](#-check-requirements) – Checks Bash version, required functions, programs, alternative program groups, and optionally root privileges. [Full documentation](Check%20Requirements/README.md)
* [👤 Author & Contact](#-author--contact)
* [🤖 Generation Note](#-generation-note)
* [📜 License](#-license)

---

## ⚙️ Normalize List

### A flexible Bash function to normalize input strings into arrays. It splits strings by spaces, commas, pipes, or custom separators and returns a clean array.

* 🟢 **Flexible Input:** Accepts one or multiple strings at once.
* 🔹 **Custom Separators:** Regex-like, e.g., space, comma, pipe, or custom characters.
* 🟣 **Array Output:** Populates a Bash array via nameref (`-o|--output`).
* 🔒 **Robust Error Handling:** Detects and reports missing parameters.
* ⚡ **Easy Integration:** Can be embedded directly into scripts; no external dependencies.
* 💡 **Return Value:** 0 on success, 2 on error.

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

For full documentation and additional options see [Full documentation](Normalize%20List/README.de.md).

---

## 📋 Display Table

### A flexible Bash function to display formatted tables in the terminal. It calculates column widths automatically, centers the header, and outputs each row neatly.

* 🟢 **Flexible Rows & Columns:** Each row can contain multiple columns.
* 🔹 **Automatic Column Widths:** Adjusts column widths to longest content.
* 🟣 **Header Centering:** Optional table header is centered.
* 🔒 **Robust Error Checking:** Checks for missing functions.
* ⚡ **Easy Integration:** Can be embedded directly into Bash scripts.
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

For full documentation see [Full documentation](Display%20Table/README.de.md).

---

## ✅ Check Requirements

### A Bash function to verify script requirements, such as Bash version, required functions, and programs. Root privileges can be checked optionally, and alternative programs can be grouped.

* 🟢 **Check Bash Version:** Optional major/minor version specification.
* 🄵 **Check Functions:** Specify functions to check with `--funcs/-f`.
* 🟣 **Check Programs:** Via `--programs/-p` or groups `--programs-alternative/-a`.
* 🔒 **Check Root Privileges:** Optional via `--root/-r` or `--sudo/-s`.
* ⚡ **Flexible Error Handling:** `--exit/-x` allows controlling whether the script exits immediately on error or just returns.
* 🔍 **Complete Check:** All specified requirements are evaluated first; return or exit occurs only after all checks.
* 💡 **Return Values:** 0 on success, 2 on one or more errors.

**Quick Example:**

```bash
# Check Bash ≥ 4, function normalize_list, program awk, at least one of git or svn, and root privileges
check_requirements --major 4 --funcs "normalize_list" --programs "awk" --programs-alternative "git svn" --root
```

For full documentation see [Full documentation](Check%20Requirements/README.md).

---

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)

---

## 🤖 Generation Note

This project was created with the help of artificial intelligence (AI).
The AI assisted in creating the scripts, comments, and documentation (README.md).
The final result was reviewed and adjusted by me.

---

## 📜 License

[MIT License](LICENSE)
