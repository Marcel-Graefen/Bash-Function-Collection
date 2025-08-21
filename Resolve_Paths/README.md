# 📋 Bash Function: Resolve Paths

[![Back to Main README](https://img.shields.io/badge/Main-README-blue?style=flat&logo=github)](../README.md)
[![Version](https://img.shields.io/badge/version-3.0.0-blue.svg)](#)
[![German](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

A Bash function to normalize and resolve file paths, automatically expand wildcards (*, ?), classify paths by existence and individual or combined permissions (r/w/x, rw, rx, wx, rwx), and optionally map the results into named arrays.

---

## 🚀 Table of Contents

* [📌 Important Notes](#📌-important-notes)
* [🛠️ Functions & Features](#🛠️-functions--features)
* [⚙️ Requirements](#⚙️-requirements)
* [📦 Installation](#📦-installation)
* [📝 Usage](#📝-usage)
  * <details>
    <summary>▶️ Examples</summary>

      * [🗂️ Normalize and Resolve Paths](#🗂️-normalize-and-resolve-paths)
      * [⚙️ Custom Separators](#⚙️-custom-separators)
      * [🔍 Classify Paths](#🔍-classify-paths)
      * [📝 Output to Named Arrays](#📝-output-to-named-arrays)
      * [✨ Use Wildcards](#✨-use-wildcards)
      * [🔄 Combine Multiple Inputs](#🔄-combine-multiple-inputs)
      * [🔑 Check Writable Only](#🔑-check-writable-only)
      * [📛 Identify Missing Files](#📛-identify-missing-files)
      * [▶️ Check Executable Scripts](#▶️-check-executable-scripts)
      * [🔒 Check All Permissions](#🔒-check-all-permissions)

    </details>
* [📌 API Reference](#📌-api-reference)
* [🗂️ Changelog](#🗂️-changelog)
* [👤 Author & Contact](#👤-author--contact)
* [🤖 Generation Note](#🤖-generation-note)
* [📜 License](#📜-license)

---

## 🛠️ Functions & Features

* 🗂️ **Normalize Inputs:** Automatically splits one or multiple paths by spaces or custom separators.
* 🔹 **Absolute Paths:** Converts relative paths to absolute paths (`realpath`).
* ✨ **Automatic Wildcard Expansion:** Paths containing `*` or `?` are automatically resolved.
* 🟣 **Existence Check:** Separates existing from missing paths.
* 🔒 **Permission Check:** Checks readability (`r`), writability (`w`), executability (`x`) and combinations (`rw`, `rx`, `wx`, `rwx`).
* ⚡ **Flexible Output:** Results can be written into one or more named arrays.
* 💡 **Return Codes:** `0` for success, `2` for errors (e.g., missing input, unknown option).

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
````

---

## 📝 Usage

### 🗂️ Normalize and Resolve Paths

Normalizes input paths, splits them, and converts them to absolute paths.

```bash
declare -a all_paths

# Example: single input with multiple paths
resolve_paths -i "file1.txt file2.txt,/tmp/file3" -o-all all_paths

# Check output
printf "%s\n" "${all_paths[@]}"
```

**Explanation:** All paths are made absolute and stored separately in the `all_paths` array.

---

### ⚙️ Custom Separators

```bash
declare -a all_paths

# Example: comma, semicolon, or pipe as separators
resolve_paths \
  -i "file1.txt,file2.txt;/tmp/file3|/var/log/syslog" \
  -s ",;|" \
  -o-all all_paths

printf "%s\n" "${all_paths[@]}"
```

**Explanation:** Separators can be freely specified; multiple separators can be used simultaneously.

> By default, the `normalize_list` function splits paths by spaces (` `), comma (`,`), and pipe (`|`), so `-s|--separator` is usually not required.

---

### 🔍 Classify Paths

```bash
declare -a exist missing r not_r w not_w x not_x rw not_rw rx not_rx wx not_wx rwx not_rwx

# Example: check existence and permissions
resolve_paths \
  -i "file1.txt file2.txt /tmp/file3" \
  -o-exist exist -o-missing missing \
  -o-r r -o-not-r not_r \
  -o-w w -o-not-w not_w \
  -o-x x -o-not-x not_x \
  -o-rw rw -o-not-rw not_rw \
  -o-rx rx -o-not-rx not_rx \
  -o-wx wx -o-not-wx not_wx \
  -o-rwx rwx -o-not-rwx not_rwx
```

**Explanation:** Separates existing/missing paths and checks readable, writable, executable paths and all combinations (`rw`, `rx`, `wx`, `rwx`).

---

### 📝 Output to Named Arrays

```bash
declare -a ALL EXIST MISSING RW NOT_RW

# Example: map results to custom arrays
resolve_paths \
  -i "file1.txt,file2.txt,/tmp/file3" \
  -o-all ALL \
  -o-exist EXIST \
  -o-missing MISSING \
  -o-rw RW \
  -o-not-rw NOT_RW

echo "ALL:     ${ALL[*]}"
echo "EXIST:   ${EXIST[*]}"
echo "MISSING: ${MISSING[*]}"
echo "RW:      ${RW[*]}"
echo "NOT_RW:  ${NOT_RW[*]}"
```

**Explanation:** Any internal arrays can be mapped to your own named arrays.

---

### ✨ Use Wildcards

```bash
declare -a ALL EXIST RX NOT_RX

# Example: all .sh files in current directory
resolve_paths \
  -i "./*.sh" \
  -o-all ALL \
  -o-exist EXIST \
  -o-rx RX \
  -o-not-rx NOT_RX

echo "ALL:    ${ALL[*]}"
echo "EXIST:  ${EXIST[*]}"
echo "RX:     ${RX[*]}"
echo "NOT_RX: ${NOT_RX[*]}"
```

**Explanation:** Wildcards `*` and `?` are automatically resolved; permission combinations can be checked directly.

---

### 🔄 Combine Multiple Inputs

```bash
declare -a ALL

# Multiple -i parameters
resolve_paths -i "file1.txt file2.txt" -i "/tmp/file3 /var/log/syslog" -o-all ALL
echo "${ALL[*]}"
```

**Explanation:** Multiple input arrays are normalized together and written into a single array.

---

### 🔑 Check Writable Only

```bash
declare -a W WRITEABLE_NOT

resolve_paths -i "/tmp/*" -o-w W -o-not-w WRITEABLE_NOT
echo "Writable: ${W[*]}"
echo "Not writable: ${WRITEABLE_NOT[*]}"
```

**Explanation:** Only checks write permissions; other permissions are ignored.

---

### 📛 Identify Missing Files

```bash
declare -a MISSING

resolve_paths -i "file1.txt file2.txt /nonexistent/file" -o-missing MISSING
echo "Missing files: ${MISSING[*]}"
```

**Explanation:** Quickly determine which paths need to be created.

---

### ▶️ Check Executable Scripts

```bash
declare -a RX RX_NOT

resolve_paths -i "/usr/bin/*" -o-rx RX -o-not-rx RX_NOT
echo "Executable: ${RX[*]}"
echo "Not executable: ${RX_NOT[*]}"
```

**Explanation:** Filter for readable + executable (e.g., scripts).

---

### 🔒 Check All Permissions

```bash
declare -a ALL RWX NOT_RWX

resolve_paths -i "./*" -o-rwx RWX -o-not-rwx NOT_RWX
echo "All rwx: ${RWX[*]}"
echo "Not rwx: ${NOT_RWX[*]}"
```

**Explanation:** Checks in one step which files have **full read/write/execute rights**.

---

## 📌 API Reference

| Description                                  | Argument / Alias                            | Optional  | Multiple   | Type       |
| -------------------------------------------- | ------------------------------------------- | ---------- | --------- | ---------- |
| 🟢📂 Input Paths                             | `-i` / `--input`                           | ❌        | ✅        | String     |
| 🔹📂 Separators                              | `-s` / `--separator`                       | ✅        | ❌        | String     |
| 🟣📂 All normalized paths                    | `-o-all`                                   | ✅        | ❌        | Array-Name |
| 🟣✅ Existing paths                          | `-o-exist`                                 | ✅        | ❌        | Array-Name |
| 🟣❌ Missing paths                           | `-o-missing`                               | ✅        | ❌        | Array-Name |
| 🔒👀 Readable                                | `-o-r`                                     | ✅        | ❌        | Array-Name |
| 🔒🚫 Not readable                            | `-o-not-r`                                 | ✅        | ❌        | Array-Name |
| 🔒✍️ Writable                                | `-o-w`                                     | ✅        | ❌        | Array-Name |
| 🔒🚫 Not writable                            | `-o-not-w`                                 | ✅        | ❌        | Array-Name |
| 🔒▶️ Executable                              | `-o-x`                                     | ✅        | ❌        | Array-Name |
| 🔒🚫 Not executable                          | `-o-not-x`                                 | ✅        | ❌        | Array-Name |
| 🔒⚡ Combined permissions (rw)               | `-o-rw` / `-o-wr`                          | ✅        | ❌        | Array-Name |
| 🔒❌ Negated combined permissions (rw)       | `-o-not-rw` / `-o-not-wr`                  | ✅        | ❌        | Array-Name |
| 🔒⚡ Combined permissions (rx)               | `-o-rx` / `-o-xr`                          | ✅        | ❌        | Array-Name |
| 🔒❌ Negated combined permissions (rx)       | `-o-not-rx` / `-o-not-xr`                  | ✅        | ❌        | Array-Name |
| 🔒⚡ Combined permissions (wx)               | `-o-wx` / `-o-xw`                          | ✅        | ❌        | Array-Name |
| 🔒❌ Negated combined permissions (wx)       | `-o-not-wx` / `-o-not-xw`                  | ✅        | ❌        | Array-Name |
| 1️⃣🔒⚡💡 Combined permissions (rwx)         | `-o-rwx` / `-o-rxw` / `-o-wrx`             | ✅        | ❌        | Array-Name |
| 2️⃣🔒⚡💡 Combined permissions (rwx)         | `-o-wxr` / `-o-xrw` / `-o-xwr`             | ✅        | ❌        | Array-Name |
| 1️⃣🔒❌💡 Negated combined permissions (rwx) | `-o-not-rwx` / `-o-not-rxw` / `-o-not-wrx` | ✅        | ❌        | Array-Name |
| 2️⃣🔒⚡💡 Negated combined permissions (rwx) | `-o-not-wxr` / `-o-not-xrw` / `-o-not-xwr` | ✅        | ❌        | Array-Name |

**Return codes:**

* `0` on success
* `2` on error

---

## 🗂️ Changelog

**Version 3.0.0 – Improvements over 2.0.0**

* 🆕 **Permission checking extended:** Now checks `r`, `w`, `x` and all combinations (`rw`, `rx`, `wx`, `rwx`) with negations
* ⚡ **Classification optimized:** Only requested permissions are checked
* 🟢 **API extended:** New options `-o-r`, `-o-w`, `-o-x`, `-o-rw`, `-o-rx`, `-o-wx`, `-o-rwx` and their `-o-not-*` variants
* 📝 **Documentation updated:** README adapted to new options

### Differences from Version 2.0.0

| Feature / Change                                 | 3.0.0 | 2.0.0 |
| ------------------------------------------------ | ----- | ----- |
| 🔒 Permission check (r/w/x)                      | ✅   | ❌    |
| 🔒 Combined permissions rw/rx/wx/rwx             | ✅   | ❌    |
| ⚡ Classification only for requested permissions | ✅   | ❌    |
| 📝 API reference updated                         | ✅   | ❌    |

---

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)

---

## 🤖 Generation Note

This project was developed with the assistance of Artificial Intelligence (AI). The AI helped generate the script, comments, and documentation (README.md). The final result was reviewed and adjusted by me.

---

## 📜 License

[MIT License](LICENSE)
