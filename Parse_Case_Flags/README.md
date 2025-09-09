# 📋 Bash Function: Parse Case Flags

[![German](https://img.shields.io/badge/Langugae-German-blue)](./README.de.md)
[![Back to Main README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.0_beta.03-blue.svg)](./Versions/v1.0.0-beta.03/README.md)

`parse_case_flags` is a Bash function for **parsing, validating, and assigning command-line flags within a case block**.
It supports **single values, arrays, and toggle flags**, validates numbers, letters, allowed/forbidden characters or values, and preserves **all remaining unprocessed arguments**.

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
  * [💎 Masked Leading Dashes](#-masked-leading-dashes)
* [📌 API Reference](#-api-reference)
* [🗂️ Changelog](#-changelog)
* [🤖 Generation Note](#-generation-note)

---

## ⚠️ Migration Notes

In version **1.0.0-beta.03**, `--name` (`-n`) and `--return` (`-r` / `-o`) are **mandatory**.
Without these parameters, the function cannot provide proper error messages or return values.

```bash
# Old (beta.02)
parse_case_flags --letters Alice

# New (beta.03)
parse_case_flags --name "username" --return user_var --letters -i "$@"
```

> `--name` is used for error messages, `--return` specifies the target variable.

---

## 🛠️ Features

* 🎯 **Flag Parsing**: Single values, arrays, toggle
* 🔢 **Number Validation**: `--number`
* 🔤 **Letter Validation**: `--letters`
* ✅ **Allowed Characters & Values**: `--allow` / `--allow-full`
* ❌ **Forbidden Characters & Values**: `--forbid` / `--forbid-full`
* 💾 **Variable Assignment**: via Nameref (`declare -n`)
* 💾 **Dropping Array**: invalid values can be stored (`--dropping`)
* 💾 **Deduplicate Array**: removes duplicates optionally (`--deduplicate`)
* 🔄 **Remaining Arguments Preserved**
* ⚡ **Toggle Flags**: sets target variable to `true` (single value only)
* 📢 **Verbose Mode**: detailed errors (`--verbose`)
* 💡 **Masked Leading Dashes**: `\-value` is passed correctly

---

## ⚙️ Requirements

* 🐚 Bash ≥ 4.3 (for Nameref support via `declare -n`)

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
* `--verbose` is optional to show errors

---

### 📦 Array & Multiple Values

```bash
-a|--array)
  parse_case_flags --name "tags" --return output --array --deduplicate --dropping invalid_tags --verbose -i "$@" || return 1
  shift $#
;;
```

* `$@` passes all remaining arguments
* `--deduplicate` removes duplicate entries
* `--dropping` stores invalid values in `invalid_tags`
* `shift $#` removes all processed arguments

---

### ⚡ Toggle Flags

```bash
-t|--toggle)
  parse_case_flags --name "enabled_flag" --return output --toggle --verbose || return 1
  shift
;;
```

* Sets the target variable to `true` automatically
* Only single values supported

---

### 🔗 Combined Options

```bash
-i|--ids)
  parse_case_flags --name "ids" --return ids_array --array --number --forbid-full "0" "999" --deduplicate --dropping invalid_ids --verbose -i "$@" || return 1
  shift $#
;;
```

* Demonstrates combining array, number validation, forbidden full-values, deduplication, and dropping

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

* Character validation (`--allow` / `--forbid`)
* Full value validation (`--allow-full` / `--forbid-full`)
* Wildcards supported in `allow-full` / `forbid-full`

---

### 💎 Masked Leading Dashes

```bash
parse_case_flags --name "options" --return opts_array --array -i "\-example" "\-safe" --verbose || return 1
```

* `\-example` is correctly passed as `-example`

---

## 📌 API Reference

| Description       | Argument / Alias                      | Optional | Multiple | Type           |
| ----------------- | ------------------------------------- | -------- | -------- | -------------- |
| Flag Name         | `--name` (`-n`)                       | ❌      | ❌       | String         |
| Target Variable   | `--return` / `--output` (`-r` / `-o`) | ❌      | ❌       | String         |
| Array             | `--array` (`-y`)                      | ✅      | ❌       | Flag           |
| Number            | `--number` (`-c`)                     | ✅      | ❌       | Flag           |
| Letters           | `--letters` (`-l`)                    | ✅      | ❌       | Flag           |
| Toggle            | `--toggle` (`-t`)                     | ✅      | ❌       | Flag           |
| Forbidden Chars   | `--forbid` (`-f`)                     | ✅      | ❌       | String         |
| Allowed Chars     | `--allow` (`-a`)                      | ✅      | ❌       | String         |
| Forbidden Values  | `--forbid-full` (`-F`)                | ✅      | ✅       | String / Array |
| Allowed Values    | `--allow-full` (`-A`)                 | ✅      | ✅       | String / Array |
| Dropping Array    | `--dropping` (`-d`)                   | ✅      | ❌       | String / Array |
| Deduplicate Array | `--deduplicate` (`-D`)                | ✅      | ❌       | Flag           |
| Input Values      | `--input` (`-i`)                      | ❌      | ✅       | String / Array |
| Terminal Output   |  `--verbose` (`-v`)                   | ✅        | ❌     | Flag           |

> ⚠️ Masked leading dashes (`\-`) are automatically unescaped.

---

## 🗂️ Changelog

**v1.0.0-beta.03**

* `--name` and `--return` are mandatory
* Toggle flags restricted to single values
* Masked leading dashes (`\`) support added
* Case-block examples updated for single, array, toggle, combined
* Deduplication and dropping support
* Allow/Forbid/Full validation clarified

**v1.0.0-beta.02**

* Single values, arrays, toggle
* Validation for numbers and letters
* Allowed and forbidden characters

---

## 🤖 Generation Note

This document was created with AI assistance and manually reviewed. Scripts, comments, and documentation were finalized and verified.
