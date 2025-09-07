# 📋 Bash Function: Resolve Paths

[![Back to Main README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/README.md)
[![Version](https://img.shields.io/badge/version-1.0.0_beta.04-blue.svg)](#)
[![English](https://img.shields.io/badge/Language-English-blue)](./README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

A Bash function for normalizing and resolving file paths, automatic wildcard expansion (`*`, `?`, `**`) with **Globstar support**, classification by existence and permissions (r/w/x, rw, rx, wx, rwx), and optional mapping of results into named arrays.

---

## 🚀 Table of Contents

* [📌 Notes](#-notes)
* [🛠️ Functions & Features](#-functions--features)
* [⚙️ Requirements](#%EF%B8%8F-requirements)
* [📦 Installation](#-installation)
* [📝 Usage](#-usage)

  * <details>
    <summary>▶️ Examples</summary>

    * [🗂️ Normalize and resolve paths](#-normalize-and-resolve-paths)
    * [⚙️ Custom separators](#%EF%B8%8F-custom-separators)
    * [🔍 Classify paths](#-classify-paths)
    * [📝 Output to named arrays](#-output-to-named-arrays)
    * [✨ Use wildcards](#-use-wildcards)
    * [🔄 Combine multiple inputs](#-combine-multiple-inputs)
    * [🔑 Check write-only permission](#-check-write-only-permission)
    * [📛 Detect missing files](#-detect-missing-files)
    * [▶️ Check executable scripts](#-check-executable-scripts)
    * [🔒 Check all permissions](#-check-all-permissions)

    </details>
* [📌 API Reference](#-api-reference)
* [🗂️ Changelog](#-changelog)
* [👤 Author & Contact](#-author--contact)
* [🤖 Generation Note](#-generation-note)
* [📜 License](#-license)

---

## 🛠️ Functions & Features

* 🗂️ **Normalize inputs:** Automatically split paths by spaces or custom characters.
* 🔹 **Absolute paths:** Converts relative paths to absolute paths (`realpath`).
* ✨ **Automatic wildcard expansion:** Supports `*` and `**` (Globstar).
* 🟣 **Existence check:** Separates existing from missing paths.
* 🔒 **Permission check:** Checks readability (`r`), writeability (`w`), executability (`x`) and combinations (`rw`, `rx`, `wx`, `rwx`) including negations.
* ⚡ **Flexible output:** Results can be written into named arrays.
* ❌ **Input protection:** Leading `/ **/` paths are rejected.
* ❌ **Separator check:** Separators cannot contain `/`, `*`, or `.`.
* 💡 **Return values:** `0` for success, `2` for error.

---

## ⚙️ Requirements

* 🐚 **Bash** version 4.3 or higher
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

### 🗂️ Normalize and resolve paths

```bash
declare -a all_paths

resolve_paths -i "file1.txt file2.txt,/tmp/file3" --out-all all_paths
printf "%s\n" "${all_paths[@]}"
```

**Explanation:** Resolves all paths to absolute, normalizes multiple inputs, and writes results into `all_paths` array. Useful to process different paths consistently.

---

### ⚙️ Custom separators

```bash
declare -a all_paths

resolve_paths \
  -i "file1.txt,file2.txt;/tmp/file3|/var/log/syslog" \
  -s ",;|" \
  --out-all all_paths

printf "%s\n" "${all_paths[@]}"
```

**Explanation:** Custom separators can be defined; multiple separators can be used at once.

> By default, `normalize_list` splits paths by space (` `), comma (`,`), and pipe (`|`). Using `-s|--separator` is usually not required.
> Forbidden separators: dot (`.`), slash (`/`), asterisk (`*`).

---

### 🔍 Classify paths

```bash
declare -a exist missing r not_r w not_w x not_x rw not_rw rx not_rx wx not_wx rwx not_rwx

resolve_paths \
  -i "file1.txt file2.txt /tmp/file3" \
  --out-exist exist --out-missing missing \
  --out-r r --out-not-r not_r \
  --out-w w --out-not-w not_w \
  --out-x x --out-not-x not_x \
  --out-rw rw --out-not-rw not_rw \
  --out-rx rx --out-not-rx not_rx \
  --out-wx wx --out-not-wx not_wx \
  --out-rwx rwx --out-not-rwx not_rwx
```

**Explanation:** Separates paths by existence and permissions. Check which files are readable, writable, executable, or not.

---

### 📝 Output to named arrays

```bash
declare -a ALL EXIST MISSING RW NOT_RW

resolve_paths \
  -i "file1.txt,file2.txt,/tmp/file3" \
  --out-all ALL \
  --out-exist EXIST \
  --out-missing MISSING \
  --out-rw RW \
  --out-not-rw NOT_RW

echo "ALL:     ${ALL[*]}"
echo "EXIST:   ${EXIST[*]}"
echo "MISSING: ${MISSING[*]}"
echo "RW:      ${RW[*]}"
echo "NOT_RW:  ${NOT_RW[*]}"
```

**Explanation:** Results are written into any named arrays for further processing or filtering.

---

### ✨ Use wildcards

```bash
declare -a ALL EXIST RX NOT_RX

resolve_paths \
  -i "./**/*.sh" \
  --out-all ALL \
  --out-exist EXIST \
  --out-rx RX \
  --out-not-rx NOT_RX

echo "ALL:    ${ALL[*]}"
echo "EXIST:  ${EXIST[*]}"
echo "RX:     ${RX[*]}"
echo "NOT_RX: ${NOT_RX[*]}"
```

**Explanation:** Supports `*` and `**`. Useful to collect all files of a type recursively and check permissions.

---

### 🔄 Combine multiple inputs

```bash
declare -a ALL

resolve_paths -i "file1.txt file2.txt" -i "/tmp/file3 /var/log/syslog" --out-all ALL
echo "${ALL[*]}"
```

**Explanation:** Multiple `-i` inputs can be merged, normalized, and written into a single array.

---

### 🔑 Check write-only permission

```bash
declare -a W WRITEABLE_NOT

resolve_paths -i "/tmp/*" --out-w W --out-not-w WRITEABLE_NOT
echo "Writable: ${W[*]}"
echo "Not writable: ${WRITEABLE_NOT[*]}"
```

**Explanation:** Useful when only write permission matters. Other permissions are ignored.

---

### 📛 Detect missing files

```bash
declare -a MISSING

resolve_paths -i "file1.txt file2.txt /nonexistent/file" --out-missing MISSING
echo "Missing files: ${MISSING[*]}"
```

**Explanation:** Quickly identify missing paths that need creation or checks before file operations.

---

### ▶️ Check executable scripts

```bash
declare -a RX RX_NOT

resolve_paths -i "/usr/bin/*" --out-rx RX --out-not-rx RX_NOT
echo "Executable: ${RX[*]}"
echo "Not executable: ${RX_NOT[*]}"
```

**Explanation:** Filters combined permissions (readable + executable). Useful to identify scripts or executables.

---

### 🔒 Check all permissions

```bash
declare -a ALL RWX NOT_RWX

resolve_paths -i "./*" --out-rwx RWX --out-not-rwx NOT_RWX
echo "All rwx: ${RWX[*]}"
echo "Not rwx: ${NOT_RWX[*]}"
```

**Explanation:** Checks which files have full permissions and which do not. Helpful for consistent access control.

---

## 📌 API Reference

| Description                                  | Argument / Alias                                    | Optional | Multiple | Type       |
| -------------------------------------------- | --------------------------------------------------- | -------- | -------- | ---------- |
| 🟢📂 Input paths                             | `-i` / `--input` / `-d` / `--dir` / `-f` / `--file` | ❌        | ✅        | String     |
| 🔹📂 Separators                              | `-s` / `--separator`                                | ✅        | ❌        | String     |
| 🟣📂 All normalized paths                    | `--out-all`                                         | ✅        | ❌        | Array-Name |
| 🟣✅ Existing paths                           | `--out-exist`                                       | ✅        | ❌        | Array-Name |
| 🟣❌ Missing paths                            | `--out-missing`                                     | ✅        | ❌        | Array-Name |
| 🔒👀 Readable                                | `--out-r`                                           | ✅        | ❌        | Array-Name |
| 🔒🚫 Not readable                            | `--out-not-r`                                       | ✅        | ❌        | Array-Name |
| 🔒✍️ Writable                                | `--out-w`                                           | ✅        | ❌        | Array-Name |
| 🔒🚫 Not writable                            | `--out-not-w`                                       | ✅        | ❌        | Array-Name |
| 🔒▶️ Executable                              | `--out-x`                                           | ✅        | ❌        | Array-Name |
| 🔒🚫 Not executable                          | `--out-not-x`                                       | ✅        | ❌        | Array-Name |
| 🔒⚡ Combined permissions (rw)                | `--out-rw` / `--out-wr`                             | ✅        | ❌        | Array-Name |
| 🔒❌ Negation combined permissions (rw)       | `--out-not-rw` / `--out-not-wr`                     | ✅        | ❌        | Array-Name |
| 🔒⚡ Combined permissions (rx)                | `--out-rx` / `--out-xr`                             | ✅        | ❌        | Array-Name |
| 🔒❌ Negation combined permissions (rx)       | `--out-not-rx` / `--out-not-xr`                     | ✅        | ❌        | Array-Name |
| 🔒⚡ Combined permissions (wx)                | `--out-wx` / `--out-xw`                             | ✅        | ❌        | Array-Name |
| 🔒❌ Negation combined permissions (wx)       | `--out-not-wx` / `--out-not-xw`                     | ✅        | ❌        | Array-Name |
| 1️⃣🔒⚡💡 Combined permissions (rwx)          | `--out-rwx` / `--out-rxw` / `--out-wrx`             | ✅        | ❌        | Array-Name |
| 2️⃣🔒⚡💡 Combined permissions (rwx)          | `--out-wxr` / `--out-xrw` / `--out-xwr`             | ✅        | ❌        | Array-Name |
| 1️⃣🔒❌💡 Negation combined permissions (rwx) | `--out-not-rwx` / `--out-not-rxw` / `--out-not-wrx` | ✅        | ❌        | Array-Name |
| 2️⃣🔒⚡💡 Negation combined permissions (rwx) | `--out-not-wxr` / `--out-not-xrw` / `--out-not-xwr` | ✅        | ❌        | Array-Name |

**Return values:**

* `0` on success
* `2` on error

---

## 🗂️ Changelog

**Version 1.0.0-Beta.04 – Improvements over 1.0.0-Beta.03**

* 🆕 **Globstar support:** `**` wildcards supported
* ❌ **Input security:** Leading `/ **/` forbidden (may take too long)
* ❌ **Separator check:** `/`, `.` or `*` not allowed
* 📂 **Input paths:** New aliases added: `-d` / `--dir` / `-f` / `--file`
* ⚠️ **Argument change:** All output arguments use `--out-` prefix instead of `-o-`

---

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)

---

## 🤖 Generation Note

This project was developed with AI assistance. Scripts, comments, and documentation were finalized and reviewed manually.

---

## 📜 License

[MIT License](LICENSE)
