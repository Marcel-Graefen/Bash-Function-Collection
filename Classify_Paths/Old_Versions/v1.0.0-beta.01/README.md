# 📋 Bash Function: Classify Paths

[![Back to Main README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/README.md)
[![Version](https://img.shields.io/badge/version-0.0.1_beta.01-blue.svg)](#)
[![German](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

A Bash function to **classify filesystem paths** based on **existence** and **permissions** (r/w/x, rw, rx, wx, rwx), including **wildcard expansion** (`*`, `**`), duplicate detection, and optional mapping of results into named arrays.

---

## 🚀 Table of Contents

* [📌 Important Notes](#-important-notes)
* [🛠️ Features](#-features)
* [⚙️ Requirements](#%EF%B8%8F-requirements)
* [📦 Installation](#-installation)
* [📝 Usage](#-usage)

  * [🔍 Classify Paths](#-classify-paths)
  * [✨ Using Wildcards](#-using-wildcards)
  * [🔑 Check Permissions](#-check-permissions)
  * [📛 Detect Missing Files](#-detect-missing-files)
* [📌 API Reference](#-api-reference)
* [🗂️ Changelog](#-changelog)
* [👤 Author & Contact](#-author--contact)
* [🤖 Generation Note](#-generation-note)
* [📜 License](#-license)

---

## 🛠️ Features

* 🗂️ **Normalize Inputs:** Supports multiple `-i`/`--input`, `-d`/`--dir`, and `-f`/`--file` parameters.
* ✨ **Wildcard Expansion:** Automatically resolves `*` and `**`.
* 🔹 **Absolute Paths:** Normalizes paths using `realpath -m`.
* 🟣 **Existence Check:** Separates existing from missing paths.
* 🔒 **Permission Check:** Checks read (`r`), write (`w`), and execute (`x`) permissions, including combinations (`rw`, `rx`, `wx`, `rwx`) and negations.
* ⚡ **Flexible Output:** Results can be written to named associative arrays.
* ❌ **Input Safety:** Leading `/**/` is rejected.
* ❌ **Separator Validation:** `/`, `*`, or `.` are not allowed as separators.
* 💡 **Return Values:** `0` on success, `1` on error.

---

## ⚙️ Requirements

* 🐚 **Bash** version 4.3 or higher
* `normalize_list` function available
* `realpath` command available

---

## 📦 Installation

```bash
#!/usr/bin/env bash

source "/path/to/classify_paths.sh"
```

---

## 📝 Usage

### 🔍 Classify Paths

```bash
declare -A Hello

classify_paths -i "/tmp/file1 /tmp/file2" -o Hello -p "r w x rwx"
echo "All files: ${Hello[all]}"
echo "Existing files: ${Hello[file]}"
echo "Directories: ${Hello[dir]}"
echo "Missing: ${Hello[missing]}"
```

**Explanation:** Separates paths by existence and type. Filters additionally by permissions if masks (`-p`) are provided.

---

### ✨ Using Wildcards

```bash
declare -A Hello

classify_paths -i "/tmp/**/*.sh" -o Hello -p "rx"
echo "Executable scripts: ${Hello[rx]}"
echo "Not executable: ${Hello[not-rx]}"
```

**Explanation:** Supports `*` and `**`. Useful for collecting all files of a type in subdirectories and checking their permissions.

---

### 🔑 Check Permissions

```bash
declare -A Hello

classify_paths -i "/tmp/file*" -o Hello -p "r w x rw rx wx rwx"
echo "Readable: ${Hello[r]}"
echo "Writable: ${Hello[w]}"
echo "Executable: ${Hello[x]}"
echo "RWX files: ${Hello[rwx]}"
```

**Explanation:** Checks each specified mask against the files and separates negative variants (`not-r`, `not-rw`, etc.).

---

### 📛 Detect Missing Files

```bash
declare -A Hello

classify_paths -i "/tmp/file1 /tmp/file2 /nonexistent/file" -o Hello
echo "Missing files: ${Hello[missing]}"
```

**Explanation:** Detects all paths that do not exist.

---

## 📌 API Reference

| Description      | Argument / Alias                                    | Optional | Multiple | Type                   |
| ---------------- | --------------------------------------------------- | -------- | -------- | ---------------------- |
| Input paths      | `-i` / `--input` / `-d` / `--dir` / `-f` / `--file` | ❌        | ✅        | String                 |
| Output array     | `-o` / `--output`                                   | ❌        | ❌        | Associative Array Name |
| Permission masks | `-p` / `--perm`                                     | ✅        | ✅        | String                 |

**Output Keys in Array:**

* `all` – all paths
* `file` – existing files
* `dir` – existing directories
* `missing` – missing paths
* `r, w, x, rw, rx, wx, rwx` – paths matching permissions
* `not-r, not-w, not-x, not-rw, not-rx, not-wx, not-rwx` – paths **not** matching permissions

---

## 🗂️ Changelog

**Version 1.0.0-Beta.01**

* 🆕 Initial release of `classify_paths`
* 🔹 Classifies paths by existence, type, and permissions
* ✨ Wildcard expansion (`*`, `**`) implemented
* 💡 Supports multiple inputs and multiple permission masks

---

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)

---

## 🤖 Generation Note

This project was documented with AI assistance. Scripts, comments, and documentation were reviewed and finalized by me.

---

## 📜 License

[MIT License](LICENSE)
