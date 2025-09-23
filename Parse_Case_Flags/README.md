# 📋 Bash Function: Parse Case Flags

[![German](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![Back to Main README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/README.de.md)
[![Version](https://img.shields.io/badge/version-1.0.0_beta.04-blue.svg)](./Versions/v1.1.0-beta.01/README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-≥4.3-green.svg)]()

`parse_case_flags` is a Bash function for **parsing, validating, and assigning command-line flags within a case block**.
It supports **single values, arrays, and toggle flags**, validates values for numbers, letters, allowed/forbidden characters/values, and preserves **all unprocessed arguments**.

---

## 🚀 Table of Contents

* [⚠️ Migration Notes](#-migration-notes)
* [🛠️ Features](#-features)
* [⚙️ Requirements](#-requirements)
* [📦 Installation](#-installation)
* [📝 Usage](#-usage)
  * [💡 Single Value](#-single-value)
  * [📦 Array & Multiple Values](#-array--multiple-values)
  * [⚡ Toggle Flags](#-toggle-flags)
  * [🔗 Combined Options](#-combined-options)
  * [🛡️ Input Validation (Allow / Forbid / Full)](#-input-validation-allow--forbid--full)
  * [💎 Masked Leading Hyphens](#-masked-leading-hyphens)
  * [🚩 Flag Detection in Case Statements](#-flag-detection-in-case-statements)
* [📌 API Reference](#-api-reference)
* [🗂️ Changelog](#-changelog)
* [🤖 Generation Note](#-generation-note)

---

## ⚠️ Migration Notes

In version **1.0.0-beta.04**, **flag detection** for case statements was improved:

```bash
# Old (beta.03)
parse_case_flags --name "directory" --return dirs --array -i "$@"

# New (beta.04)
parse_case_flags --name "directory" --return tmpdir --array -i "$@"
directories+=("${tmpdir[@]}")
shift "${#tmpdir[@]}"
shift 1
```

> The new approach uses **temporary variables** + `+=` to correctly collect **multiple identical flags**.

---

## 🛠️ Features

* 🎯 **Flag Parsing**: Single values, arrays, toggle
* 🔢 **Number validation**: `--number`
* 🔤 **Letter validation**: `--letters`
* ✅ **Allowed characters & values**: `--allow` / `--allow-full`
* ❌ **Forbidden characters & values**: `--forbid` / `--forbid-full`
* 💾 **Variable assignment** via nameref (`declare -n`)
* 💾 **Dropping array**: optionally store invalid values (`--dropping`)
* 💾 **Deduplicate array**: remove duplicates optionally (`--deduplicate`)
* 🔄 **Unprocessed arguments remain**
* ⚡ **Toggle flags**: sets target variable to `true`, single value only
* 📢 **Verbose**: detailed error messages (`--verbose` / `-v`)
* 💡 **Masked leading hyphens**: `\-value` → passed correctly
* 🛑 **None-Zero (`--none-zero` / `-nz`)**: requires at least one value (0 is allowed)
* 🚩 **Flag detection**: optional detection in array mode (`--no-recognize-flags`)
* ⚠️ **Shift rules for case**: flags with values `shift 2`, toggle flags `shift 1`

---

## ⚙️ Requirements

* 🐚 Bash ≥ 4.3 (for nameref `declare -n`)

---

## 📦 Installation

```bash
#!/usr/bin/env bash
source "/path/to/parse_case_flags.sh"
```

---

## 📝 Usage

### 💡 Single Value

```bash
-v|--value)
  parse_case_flags --name "result" --return output --verbose -i "$2" || return 1
  shift 2
;;
```

* `$2` is passed as a single value
* `--verbose` optional for error messages
* `shift 2` for flag + value

---

### 📦 Array & Multiple Values (multiple identical flags)

```bash
directories=()
files=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--dir|--directory)
      parse_case_flags --name "directories" --return tmpdir --array -i "$@" || return 1
      directories+=("${tmpdir[@]}")
      shift "${#tmpdir[@]}"
      shift 1
      ;;
    -f|--file)
      parse_case_flags --name "files" --return tmpfile --array -i "$@" || return 1
      files+=("${tmpfile[@]}")
      shift "${#tmpdie[@]}"
      shift 1
      ;;
  esac
done

echo "Directories: ${directories[*]}"
echo "Files: ${files[*]}"
```

* **tmpdir / tmpfile** → only needed for multiple identical flags
* `+=` → adds values to the final array
* `shift 2` → remove flag + value

#### Test Call:

```bash
create_folder -d "/etc" -d "/home" -f "file1.txt" -f "file2.txt"
```

#### Expected Output:

```
Directories: /etc /home
Files: file1.txt file2.txt
```

---

### ⚡ Toggle Flags

```bash
-F|--force)
  parse_case_flags -n "force" --toggle || return 1
  shift 1
;;
```

* Sets target variable to `true`
* Single value only
* `shift 1` because no value follows

---

### 🔗 Combined Options

```bash
-i|--ids)
  parse_case_flags --name "ids" --return ids_array --array --number --forbid-full "0" "999" --deduplicate --dropping invalid_ids --verbose -i "$@" || return 1
  shift 1
;;
```

* Demonstrates combination of array, number validation, full forbid, deduplication, and dropping

---

### 🛡️ Input Validation (Allow / Forbid / Full)

```bash
parse_case_flags --name "inputs" --return inputs --array \
  --allow "a-zA-Z0-9._" \
  --forbid "!@#" \
  --allow-full "user*" \
  --forbid-full "root" "admin" \
  --dropping invalid_inputs --verbose -i "$@" || return 1

echo "Valid inputs: ${inputs[*]}"
echo "Dropped invalid inputs: ${invalid_inputs[*]}"
```

---

### 💎 Masked Leading Hyphens

```bash
parse_case_flags --name "options" --return opts_array --array -i "\-example" "\-safe" --verbose || return 1
```

* `\-example` → passed correctly as `-example`

---

## 🚩 Flag Detection in Case Statements

* **Multiple identical flags** → use temporary variable + `+=`
* **Sequential processing** → stops at next flag
* **Shift**: flag + value `shift 2`, toggle `shift 1`

---

## 📌 API Reference

| Description       | Argument / Alias                       | Optional | Multiple | Type           |
| ----------------- | -------------------------------------- | -------- | -------- | -------------- |
| Flag Name         | `--name` (`-n`)                        | ❌        | ❌        | String         |
| Target Variable   | `--return` / `--output` (`-r` / `-o`)  | ❌        | ❌        | String         |
| Array             | `--array` (`-y`)                       | ✅        | ❌        | Flag           |
| Number            | `--number` (`-c`)                      | ✅        | ❌        | Flag           |
| Letters           | `--letters` (`-l`)                     | ✅        | ❌        | Flag           |
| Toggle            | `--toggle` (`-t`)                      | ✅        | ❌        | Flag           |
| Forbidden chars   | `--forbid` (`-f`)                      | ✅        | ❌        | String         |
| Allowed chars     | `--allow` (`-a`)                       | ✅        | ❌        | String         |
| Forbidden values  | `--forbid-full` (`-F`)                 | ✅        | ✅        | String / Array |
| Allowed values    | `--allow-full` (`-A`)                  | ✅        | ✅        | String / Array |
| Dropping array    | `--dropping` (`-d`)                    | ✅        | ❌        | String / Array |
| Deduplicate array | `--deduplicate` (`-D`)                 | ✅        | ❌        | Flag           |
| Input values      | `--input` (`-i`)                       | ❌        | ✅        | String / Array |
| Verbose           | `--verbose` (`-v`)                     | ✅        | ❌        | Flag           |
| Must have value   | `--none-zero` (`-nz`)                  | ✅        | ❌        | Flag           |
| No flag detection | `--no-recognize-flags` (`-nrf`, `-NF`) | ✅        | ❌        | Flag           |

> ⚠️ Masked leading hyphens (`\-`) are automatically removed

---

## 🗂️ Changelog

**v1.0.0-beta.04**

* New flag detection for case statements
* Temporary variables + `+=` for multiple identical flags
* Shift 2 / 1 rules documented
* Improved case integration

**v1.0.0-beta.03**

* `--name` and `--return` mandatory
* Toggle flags limited to single value
* Masked leading hyphens added
* Deduplication and dropping supported
* Allow/Forbid/Full validation refined

**v1.0.0-beta.02**

* Single values, arrays, toggle
* Number and letter validation
* Allowed and forbidden characters

---

## 🤖 Generation Note

This document was generated with AI assistance and manually reviewed.
Scripts, comments, and documentation have been verified and adjusted.
