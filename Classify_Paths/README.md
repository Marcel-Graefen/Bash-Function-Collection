# 📋 Bash Function: Classify Paths

[![Back to Main README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](../README.de.md)
[![Version](https://img.shields.io/badge/version-0.0.1_beta.02-blue.svg)](#)
[![German](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

A Bash function for classifying file paths based on **existence** and **permissions** (r/w/x, rw, rx, wx, rwx), including **wildcard expansion** (`*`, `**`), duplicate removal, and optional mapping of results into named arrays.

---

## ✨ New Features – `classify_paths()`

* 🔑 **Flexible Permission Check:** Partial masks (`r`, `w`, `x`, `rw`, `rx`, `wx`, `rwx`) + negation (`-` / `not`), unspecified rights are ignored. All perm-keys including `not` initialized.
* ⚡ **Separator Option:** Supports `| ! $ & ' ( ) * ; < > ? [ ] ^ { } ~` + space / no separator (`false/off/no/not`). Invalid values → warning + default `|`.
* ✨ **Wildcard Expansion:** `*` and `**` expanded, dotfiles handled correctly, missing paths go into `missing`.
* 🗂️ **Handles Paths with Spaces:** Separators correctly inserted, arrays easily splittable.
* 🔄 **Duplicate Detection:** Duplicate paths reliably removed; existing vs. missing paths separated.
* ⚠️ **Logging & Warnings:** Warnings for invalid masks, separators, or leading `/**/`.
* 📝 **Output Keys Fully Initialized:** All types (`file`, `dir`) + masks (`mask`, `mask,not`) prepared.
* 🔄 **Backward Compatible:** Old calls still work; new features optional.

---

## 🚀 Table of Contents

* [📌 Important Notes](#📌-important-notes)
* [🛠️ Functions & Features](#🛠️-functions--features)
* [⚙️ Requirements](#⚙️-requirements)
* [📦 Installation](#📦-installation)
* [📝 Usage](#📝-usage)

  * <details>
    <summary>▶️ Examples</summary>

    * [🔍 Classify Paths](#🔍-classify-paths)
    * [✨ Using Wildcards](#✨-using-wildcards)
    * [🔑 Check Permissions](#🔑-check-permissions)
      * [🛡️ Permission Logic](#🛡️-permission-logic)
    * [📛 Missing Files](#📛-missing-files)
    * [📝 Output](#📝-output)
      * [📊 All Available Output Options](#📊-all-available-output-options)

    </details>
* [📌 API Reference](#📌-api-reference)
* [🗂️ Changelog](#🗂️-changelog)
* [🤖 Generation Note](#🤖-generation-note)
* [👤 Author & Contact](#👤-author--contact)

---

## 🛠️ Functions & Features

* 🗂️ **Normalize Inputs:** Supports multiple `-i`/`--input`, `-d`/`--dir`, and `-f`/`--file` parameters.
* ✨ **Wildcard Expansion:** `*` and `**` automatically resolved.
* 🔹 **Absolute Paths:** Paths normalized via `realpath -m`.
* 🟣 **Existence Check:** Separates existing paths from missing.
* 🔒 **Permission Check:** Checks read (`r`), write (`w`), and execute (`x`) rights and combinations (`rw`, `rx`, `wx`, `rwx`) including negations.
* ⚡ **Flexible Output:** Results stored in named arrays.
* ❌ **Input Protection:** Leading `/**/` rejected.
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

**Explanation:**
Separates paths by **existence** and **type**. Filters additionally by permissions if masks (`-p`) are given.

---

### ✨ Using Wildcards

```bash
declare -A Hello

classify_paths -i "/tmp/**/*.sh" -o Hello -p "rx"
echo "Executable scripts: ${Hello[rx]}"
echo "Not executable: ${Hello[not-rx]}"
```

**Explanation:**
Supports `*` and `**`. Useful to get all files of a type in subdirectories and check permissions.

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

**Explanation:**
Checks each specified mask on files and separates negative variants (`not-r`, `not-rw`, etc.).

---

### 🛡️ Permission Logic

* `xrw` → **All rights** checked
* `rw` → **Only `r` and `w`** checked, others ignored
* `r-x` →

  * `r` → **must be set**
  * `w` → **must not be set** (negated: `-(w)`)
  * `x` → **can be set**, optional

**Legend:**

| Symbol          | Meaning                                  |
| --------------- | ---------------------------------------- |
| `r`             | Read permission                          |
| `w`             | Write permission                         |
| `x`             | Execute permission                       |
| `-`             | Negation: permission must **not** be set |
| (not specified) | Ignored                                  |

---

### 📛 Missing Files

```bash
declare -A Hello

classify_paths -i "/tmp/file1 /tmp/file2 /nonexistent/file" -o Hello
echo "Missing files: ${Hello[missing]}"
```

**Explanation:**
Detects all paths that do not exist.

---

### 📝 Output

#### Output Notes

Output is returned as a string. By default entries are separated by `|`. You can change or disable the separator via the corresponding argument. See [Separator Configuration](#-separator-configuration).

---

### 📊 All Available Output Options

| Icon | Output-Key        | Description                                                                       |
| ---- | ----------------- | --------------------------------------------------------------------------------- |
| 🔍   | `all`             | All inputs after realpath & wildcard resolution (including missing paths)         |
| 📄   | `file`            | Only found files                                                                  |
| 📁   | `dir`             | Only found directories                                                            |
| ❌   | `missing`         | Inputs not found                                                                  |
| 🔑   | `file.{Mask}`     | Files that meet the specified permission (`r`, `w`, `x`, `rw`, `rx`, `wx`, `rwx`) |
| ⚠️   | `file.{Mask,not}` | Files that do **not** meet the specified permission                               |
| 🔑   | `dir.{Mask}`      | Directories that meet the specified permission                                    |
| ⚠️   | `dir.{Mask,not}`  | Directories that do **not** meet the specified permission                         |
| 🔑   | `{Mask}`          | All entries (files + directories) with the specified permission                   |
| ⚠️   | `{Mask,not}`      | All entries that do **not** meet the specified permission                         |

---

### 🔄 Output Usage Example

```bash
declare -A Hello

# Check all files by permissions
classify_paths -i "/tmp/file*" -o Hello -p "rwx"

# Access array
IFS='|' read -r -a FileArray <<< "${Hello[file]}"
for f in "${FileArray[@]}"; do
    echo "File: $f"
done

# Access files that do not meet permissions
IFS='|' read -r -a NotRWXArray <<< "${Hello[rwx,not]}"
for f in "${NotRWXArray[@]}"; do
    echo "Not-RWX: $f"
done
```

\* **Mask**: A permission combination; see [🛡️ Permission Logic](#🛡️-permission-logic) for details.

---

### 📌 API Reference

| Description       | Argument / Alias                                    | Optional | Multiple | Type                      |
| ----------------- | --------------------------------------------------- | -------- | -------- | ------------------------- |
| Input paths       | `-i` / `--input` / `-d` / `--dir` / `-f` / `--file` | ❌        | ✅        | String                 |
| All paths         | `-o` / `--output`                                   | ❌        | ❌        | Associative Array Name |
| Check permissions | `-p` / `--perm`                                     | ✅        | ✅        | String                 |
| Separator         | `-s` / `--seperator`                                | ✅        | ❌        | String                 |

---

## 🗂️ Changelog

| 🔹 Feature / Change                              | ✨ Description of Feature                                                                   | v0.0.1-Beta.01 | v0.0.1-Beta.02  |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------- | --------------- | --------------- |
| 🗂️ Input Paths (`-i/--input`, `-d/--dir`, `-f`) | Multiple inputs supported; spaces in paths                                                  | ✅              | ✅              |
| 📤 Output Array (`-o/--output`)                  | Named associative array                                                                    | ✅              | ✅              |
| 🔑 Permissions (`-p/--perm`)                     | Partial masks, combinations (`r`, `w`, `x`, `rw`, `rx`, `wx`, `rwx`), negation (`-`/`not`) | ✅              | ✅              |
| 🧩 Separator (`-s/--seperator`)                  | Flexible: special characters, space, or none (`false/off/no/not`); invalid → warning       | ❌              | ✅              |

---

## 🤖 Generation Note

This project was documented with AI assistance. Scripts, comments, and documentation were reviewed and finalized by me.

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)
* 📄 [MIT License](LICENSE)
