# 📋 Bash Function: resolve\_paths

[![Back to Main README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/README.md)
[![Version](https://img.shields.io/badge/version-1.0.0_beta.01-blue.svg)](#)
[![German](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

A Bash function to normalize and resolve file paths, classify them by existence, readability, and writability, and optionally map results to named arrays.

---

## 🚀 Table of Contents

* [📌 Important Notes](#-important-notes)
* [🛠️ Features](#-features)
* [⚙️ Requirements](#-requirements)
* [📦 Installation](#-installation)
* [📝 Usage](#-usage)

  * [1️⃣ Normalize and resolve paths](#1️⃣-normalize-and-resolve-paths)
  * [2️⃣ Custom separators](#2️⃣-custom-separators)
  * [3️⃣ Output to named arrays](#3️⃣-output-to-named-arrays)
  * [4️⃣ Classify paths](#4️⃣-classify-paths)
* [📌 API Reference](#-api-reference)
* [👤 Author & Contact](#-author--contact)
* [🤖 Generation Note](#-generation-note)
* [📜 License](#-license)

---

## 🛠️ Features

* 🟢 **Normalize inputs:** Supports multiple paths and custom separators.
* 🔹 **Absolute paths:** Converts relative paths to absolute paths using `realpath`.
* 🟣 **Existence check:** Separates existing from missing paths.
* 🔒 **Read/write check:** Separates readable/writable and non-readable/non-writable paths.
* ⚡ **Flexible output:** Results can be written to one or more named arrays.
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

* Separators like space, comma, or pipe are detected automatically.
* All paths are converted to absolute paths.
* Results are written to the `all_paths` array.

---

### 2️⃣ Custom separators

With `-s` / `--separator`, you can specify custom characters as input separators.
In this example, comma, semicolon, and pipe are used as separators:

> Default separators are `space`, `pipe |`, and `comma ,`.

```bash
declare -a all_paths

resolve_paths \
  -i "file1.txt,file2.txt;/tmp/file3|/var/log/syslog" \
  -s ",;|" \
  -o-all all_paths

# Check output
printf "%s\n" "${all_paths[@]}"
```

**Example output:**

```
file1.txt
file2.txt
/tmp/file3
/var/log/syslog
```

**Explanation:**

* Input contains paths separated by comma `,`, semicolon `;`, or pipe `|`.
* `-s ",;|"` splits input on all specified characters.
* Results are stored in the `all_paths` array.

---

### 3️⃣ Classify paths

Classifies resolved paths by existence, readability, and writability:

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

Any combination of internal arrays can be mapped to your own named arrays:

```bash
declare -a all_files existing_files

resolve_paths \
  -i "file1.txt,file2.txt,/tmp/file3" \
  -o-all all_files \
  -o-exist existing_files
```

---

## 📌 API Reference

| Description                    | Argument / Option    | Multiple Allowed | Type                           |
| ------------------------------ | -------------------- | ---------------- | ------------------------------ |
| 🟢 Input paths                 | `--input` / `-i`     | ✅                | String (space/comma-separated) |
| 🔹 Separators                  | `--separator` / `-s` | ❌                | String (characters)            |
| 🟣 Output all normalized paths | `-o-all VAR`         | ❌                | Array name                     |
| 🟣 Output existing paths       | `-o-exist VAR`       | ❌                | Array name                     |
| 🟣 Output missing paths        | `-o-missing VAR`     | ❌                | Array name                     |
| 🟣 Output readable paths       | `-o-read VAR`        | ❌                | Array name                     |
| 🟣 Output non-readable paths   | `-o-not-read VAR`    | ❌                | Array name                     |
| 🟣 Output writable paths       | `-o-write VAR`       | ❌                | Array name                     |
| 🟣 Output non-writable paths   | `-o-not-write VAR`   | ❌                | Array name                     |

**Return values:**

* `0` on success
* `2` on error

---

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)

---

## 🤖 Generation Note

This project was developed with the help of artificial intelligence (AI). The AI assisted in generating the script, comments, and documentation (README.md). The final result was reviewed and adapted by me.

---

## 📜 License

[MIT License](LICENSE)
