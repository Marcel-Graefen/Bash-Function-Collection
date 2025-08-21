# 📋 Bash Function: resolve\_paths

[![Back to Main README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](../../../README.md)
[![Version](https://img.shields.io/badge/version-1.0.0_beta.02-blue.svg)](#)
[![Language](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

A Bash function for normalizing and resolving file paths, automatic wildcard expansion (`*?`), classification by existence, readability and writability, and optional mapping of results into named arrays.

---

## 🚀 Table of Contents

* [📌 Important Notes](#-important-notes)
* [🛠️ Features](#-features)
* [⚙️ Requirements](#-requirements)
* [📦 Installation](#-installation)
* [📝 Usage](#-usage)

  * [1️⃣ Normalize and resolve paths](#1️⃣-normalize-and-resolve-paths)
  * [2️⃣ Custom separators](#2️⃣-custom-separators)
  * [3️⃣ Classify paths](#3️⃣-classify-paths)
  * [4️⃣ Output to named arrays](#4️⃣-output-to-named-arrays)
  * [5️⃣ Use wildcards](#5️⃣-use-wildcards)
* [📌 API Reference](#-api-reference)
* [🗂️ Changelog](#-changelog)
* [👤 Author & Contact](#-author--contact)
* [🤖 Generation Notice](#-generation-notice)
* [📜 License](#-license)

---

## 🛠️ Features

* 🟢 **Input normalization:** Supports multiple paths and custom separators.
* 🔹 **Absolute paths:** Converts relative paths to absolute paths (`realpath`).
* 🟣 **Automatic wildcard expansion:** Paths containing `*` or `?` are expanded automatically.
* 🟣 **Existence check:** Separates existing from missing paths.
* 🔒 **Check readability/writability:** Separates readable/writable and non-readable/non-writable paths.
* ⚡ **Flexible output:** Results can be mapped into one or multiple named arrays.
* 💡 **Return values:** `0` on success, `2` on error (e.g., missing input, unknown option).

---

## ⚙️ Requirements

* 🐚 **Bash** version 4.0 or higher
* `normalize_list` function available
* `realpath` command available

---

## 📦 Installation

```bash
#!/usr/bin/env bash

source "/path/to/resolve_paths.sh"
```

---

## 📝 Usage

### 1️⃣ Normalize and resolve paths

Normalizes input paths, splits them correctly, and converts them to absolute paths.

```bash
declare -a all_paths

# Example 1: All paths in one input
resolve_paths -i "file1.txt file2.txt,/tmp/file3" -o-all all_paths

# Example 2: Multiple inputs
resolve_paths -i "file1.txt file2.txt" -i "/tmp/file3" -o-all all_paths

# Check output
printf "%s\n" "${all_paths[@]}"
```

**Explanation:**

* Separators such as whitespace, comma, or pipe are recognized automatically.
* All paths are converted to absolute paths.
* The result is stored in the `all_paths` array.

---

### 2️⃣ Custom separators

With `-s` / `--separator` you can define your own characters as separators.
In this example, comma, semicolon and pipe are used:

Default separators are `whitespace, pipe | and comma ,`.

> When using these default separators, there is **no need** to specify `-s | --separator`!

```bash
declare -a all_paths

resolve_paths \
  -i "file1.txt,file2.txt;/tmp/file3|/var/log/syslog" \
  -s ";" \
  -o-all all_paths

# Check output
printf "%s\n" "${all_paths[@]}"
```

**Sample output:**

```
file1.txt
file2.txt
/tmp/file3
/var/log/syslog
```

**Explanation:**

* The input contains paths separated by comma `,`, semicolon `;`, or pipe `|`.
* `-s ",;|"` splits the input at all specified characters.
* The result is stored in the `all_paths` array.

---

### 3️⃣ Classify paths

Classifies the resolved paths by existence, readability, and writability:

```bash
declare -a exist missing readable not_readable writable not_writable

resolve_paths \
  -i "file1.txt file2.txt /tmp/file3" \
  -o-exist exist \
  -o-missing missing \
  -o-read readable \
  -o-not-read not_readable \
  -o-write writable \
  -o-not-write not_writable
```

---

### 4️⃣ Output to named arrays

Any combination of internal arrays can be written to custom named arrays:

```bash
declare -a ALL EXIST MISSING READABLE NOT_READABLE

resolve_paths \
  -i "file1.txt,file2.txt,/tmp/file3" \
  -o-all ALL \
  -o-exist EXIST \
  -o-missing MISSING \
  -o-read READABLE \
  -o-not-read NOT_READABLE

echo "ALL:        ${ALL[*]}"
echo "EXIST:      ${EXIST[*]}"
echo "MISSING:    ${MISSING[*]}"
echo "READABLE:   ${READABLE[*]}"
echo "NOT_READ:   ${NOT_READABLE[*]}"
```

**Output:**

```
ALL:        /home/user/project/test.sh /home/user/project/build.sh /home/user/project/old.sh
EXIST:      /home/user/project/test.sh /home/user/project/build.sh
MISSING:    /home/user/project/old.sh
READABLE:   /home/user/project/test.sh /home/user/project/build.sh
NOT_READ:   /home/user/project/old.sh
```

---

### 5️⃣ Use wildcards

Input may contain **wildcard characters**:

* `*` matches **any number of characters**
* `?` matches **exactly one character**

This allows resolving, for example, all `.sh` files in a directory:

```bash
declare -a ALL EXIST

resolve_paths \
  -i "./*.sh" \
  -o-all ALL \
  -o-exist EXIST

echo "ALL:        ${ALL[*]}"
echo "EXIST:      ${EXIST[*]}"
```

**Output:**

```
ALL:        /home/user/project/test.sh /home/user/project/build.sh /home/user/project/old.sh
EXIST:      /home/user/project/test.sh /home/user/project/build.sh
```

---

## 📌 API Reference

| Description                    | Argument / Option    | Optional | Multiple allowed | Type                         |
| ------------------------------ | -------------------- | -------- | ---------------- | ---------------------------- |
| 🟢 Input paths                 | `--input` / `-i`     | ❌        | ✅                | String (space/comma/pipe/-s) |
| 🔹 Separator                   | `--separator` / `-s` | ✅        | ❌                | String (characters)          |
| 🟣 Output all normalized paths | `-o-all VAR`         | ✅        | ❌                | Array name                   |
| 🟣 Output existing paths       | `-o-exist VAR`       | ✅        | ❌                | Array name                   |
| 🟣 Output missing paths        | `-o-missing VAR`     | ✅        | ❌                | Array name                   |
| 🟣 Output readable paths       | `-o-read VAR`        | ✅        | ❌                | Array name                   |
| 🟣 Output non-readable paths   | `-o-not-read VAR`    | ✅        | ❌                | Array name                   |
| 🟣 Output writable paths       | `-o-write VAR`       | ✅        | ❌                | Array name                   |
| 🟣 Output non-writable paths   | `-o-not-write VAR`   | ✅        | ❌                | Array name                   |

**Return values:**

* `0` on success
* `2` on error

---

## 🗂️ Changelog

**Version 1.0.0-Beta.02  – Improvements over 1.0.0-Beta.01**

* ❌ **Consistent error output:** All error messages now use the same icon format `❌ ERROR: ...`
* ⚡ **Compact argument parsing:** `case` blocks rewritten in a more compact form with direct parameter checking
* 🟢 **Optimized separator handling:** Input is split using `IFS + read -r -a`
* 🟣 **Wildcard expansion:** Automatic expansion of `*` and `?` paths
* ⚡ **-o-all mapping before deduplication:** Array is written before removing duplicates
* 💡 **Defined return values 0/2:** Success returns `0`, errors always return `2`
* 📝 **Improved readability & structure:** Clearer comments and compact function layout, helper function `check_value` introduced

### Differences compared to Beta.01

| Feature / Change                      | 02 | 01 |
| ------------------------------------- | -- | -- |
| ❌ Consistent error output with icon  |✅ |❌  |
| ⚡ Compact argument parsing           | ✅|❌  |
| 🟢 Optimized separator handling       | ✅|❌  |
| 🟣 Automatic wildcard expansion       | ✅|❌  |
| ⚡ -o-all mapping before deduplication| ✅|❌  |

---

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)

---

## 🤖 Generation Notice

This project was developed with the help of an Artificial Intelligence (AI).
The AI assisted in creating the script, comments, and documentation (README.md).
The final result was reviewed and adapted by me.

---

## 📜 License

[MIT License](LICENSE)
