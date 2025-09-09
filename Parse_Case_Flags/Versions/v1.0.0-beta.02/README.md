# 📋 Bash Function: Parse Case Flags

[![Back to Main README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/README.md)
[![Version](https://img.shields.io/badge/version-1.0.0_beta.02-blue.svg)](./Versions/v1.0.0-beta.02/README.md)
[![Deutsch](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

A Bash function for **parsing, validating, and assigning command-line flags inside a case block**.
Supports **single values, arrays, and toggle flags**, validates values for numbers, letters, or forbidden characters/strings, and preserves **all remaining CLI arguments**.

---

## 🚀 Table of Contents

* [⚠️ Migration Notes](#-migration-notes)
* [🛠️ Features](#-features)
* [⚙️ Requirements](#%EF%B8%8F-requirements)
* [📦 Installation](#-installation)
* [📝 Usage](#-usage)
  * [🪄 Single Flag](#-single-flag)
  * [📚 Array & Multiple Values](#-array--multiple-values)
  * [⚡ Toggle Flags](#-toggle-flags)
  * [🔗 Combined Options](#-combined-options)
  * [🛡️ Input Validation (Allow / Forbid / Forbid-Full)](#-input-validation-allow--forbid--forbid-full)
    * [✅ Allow Flag](#-allow-flag)
    * [⛔ Forbid Flag](#-forbid-flag)
    * [🚫 Forbid-Full Flag](#-forbid-full-flag)
    * [📊 Comparison](#-comparison)
    * [🧩 Full Example with All Flags](#-full-example-with-all-flags)
* [📌 API Reference](#-api-reference)
* [🗂️ Changelog](#-changelog)
* [🤖 Generation Note](#-generation-note)
* [👤 Author & Contact](#-author--contact)

---

## ⚠️ Migration Notes

Version 1.0.0-beta.01 is **not backward-compatible** with 0.0.0-beta.02.
**New required options:** `-n|--name` and `-r|--return|-o|--output`.

### 🔄 Example (Old → New)

```bash
# Old (0.0.0-beta.02)
parse_case_flags --letters Alice

# New (1.0.0-beta.01)
parse_case_flags --name "username" --return user_var --letters -i "$@"
```

> **Explanation:**
> You must now explicitly provide the **flag name for error messages** (`-n|--name`) and the **target variable** (`-r|--return|-o|--output`) to store the value.

---

## 🛠️ Features

* 🎯 **Flag Parsing:** Single values, arrays, and toggle options
* 🔢 **Number Validation:** `--number` ensures only numeric values are allowed
* 🔤 **Letter Validation:** `--letters` allows only alphabetic characters
* ❌ **Forbidden Characters & Values:** `--forbid` and `--forbid-full` prevent specific characters or entire strings (supports wildcards `*`)
* 💾 **Variable Assignment:** Dynamically assign to any variable via Nameref (`declare -n`)
* 🔄 **Preserve Remaining Arguments:** All unprocessed CLI arguments remain available
* ⚡ **Toggle Flags:** Flags without a value can be set to `true`
* 🧩 **Array Validation:** Every element in an array is validated
* 📢 **Verbose Output:** When enabled (`-v|--verbose`), invalid values are displayed immediately

---

## ⚙️ Requirements

* 🐚 **Bash ≥ 4.3** (for `declare -n` Nameref)

---

## 📦 Installation

```bash
#!/usr/bin/env bash
source "/path/to/parse_case_flags.sh"
```

---

## 📝 Usage

### 🪄 Single Flag

```bash
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      parse_case_flags --name "username" --return user_var --letters -i "$2" || return 1
      shift 2
      ;;
  esac
done
```

**Explanation:**
Parses the flag and assigns the value to `user_var`. Remaining arguments remain untouched.

---

### 📚 Array & Multiple Values

```bash
parse_case_flags --name "tags" --return tags_array --array Dev Ops QA -i "$@" || return 1
```

**Explanation:**

* `--array` → collects multiple values in an array
* Result: `tags_array=("Dev" "Ops" "QA")`

---

### ⚡ Toggle Flags

```bash
parse_case_flags --name "verbose_flag" --return verbose_flag --toggle -i "$@" || return 1
```

**Explanation:**

* Flag without value → sets `verbose_flag=true`.

---

### 🔗 Combined Options

```bash
parse_case_flags --name "ids" --return ids_array --array --number --forbid-full "0" "999" 1 2 3 -i "$@" || return 1
```

**Explanation:**

* `--array` → collects multiple values
* `--number` → only numbers allowed
* `--forbid-full "0" "999"` → forbids certain full values
* Result: `ids_array=(1 2 3)`

---

## 🛡️ Input Validation (Allow / Forbid / Forbid-Full)

### ✅ Allow Flag

```bash
parse_case_flags --name "myvar" --return myvar_array --array --allow "azAZ09._" -i "$@" || return 1
```

**Explanation:** Only letters, numbers, periods, and underscores are allowed.

---

### ⛔ Forbid Flag

```bash
parse_case_flags --name "myvar" --return myvar_array --array --forbid "!@#" -i "$@" || return 1
```

**Explanation:** Characters `!`, `@`, and `#` are forbidden.

---

### 🚫 Forbid-Full Flag

```bash
forbidden_values=("root" "admin" "error_file")
parse_case_flags --name "myvar" --return myvar_array --array --forbid-full "${forbidden_values[@]}" -i "$@" || return 1
```

**Explanation:** Strings `root`, `admin`, and `error_file` are forbidden.

---

### 📊 Comparison

| Flag                   | Purpose                        | Example Error                  |
| ---------------------- | ------------------------------ | ------------------------------ |
| `--allow` / `-a`       | Allow only specific characters | `bad@file` → `@` not allowed   |
| `--forbid` / `-f`      | Forbid specific characters     | `bad@file` → `@` forbidden     |
| `--forbid-full` / `-F` | Forbid entire values           | `error_file` → value forbidden |

**Notes:**

* For `--allow` / `-a` and `--forbid` / `-f`, validation is **per character**; failing one character triggers an error.
* For `--forbid-full` / `-F`, the **entire string** must match a forbidden value to trigger an error.
* `--forbid-full` can be used multiple times or passed as an array.

---

### 🧩 Full Example with All Flags

```bash
#!/usr/bin/env bash
source ./parse_case_flags.sh

validate_inputs() {
  parse_case_flags --name "inputs" --return inputs --array \
    --allow "azAZ09._" \
    --forbid "!@#" \
    --forbid-full "root" "admin" "error_file" -i "$@" || return 1

  echo "Valid inputs: ${inputs[*]}"
}

validate_inputs "hello_world" "safe.file" "bad@file" "admin"
```

**Explanation:**

* `hello_world` ✅ allowed
* `safe.file` ✅ allowed
* `bad@file` ❌ contains forbidden character
* `admin` ❌ entire value forbidden

---

## 📌 API Reference

| Description          | Argument / Alias                      | Optional | Multiple | Type                       |
| -------------------- | ------------------------------------- | -------- | -------- | -------------------------- |
| Flag Name            | `--name` (`-n`)                       | ❌        | ❌        | String                     |
| Target Variable      | `--return` / `--output` (`-r` / `-o`) | ❌        | ❌        | String                     |
| Array                | `--array` (`-y`)                      | ✅        | ❌        | Flag                       |
| Numbers              | `--number` (`-c`)                     | ✅        | ❌        | Flag                       |
| Letters              | `--letters` (`-l`)                    | ✅        | ❌        | Flag                       |
| Toggle               | `--toggle` (`-t`)                     | ✅        | ❌        | Flag                       |
| Forbidden Characters | `--forbid` (`-f`)                     | ✅        | ❌        | String                     |
| Allowed Characters   | `--allow` (`-a`)                      | ✅        | ❌        | String                     |
| Forbidden Values     | `--forbid-full` (`-F`)                | ✅        | ✅        | String / Array             |
| Dropping Array       | `--dropping` (`-d`)                   | ✅        | ❌        | Array                      |
| Deduplicate Array    | `--deduplicate` / `--dedub` (`-D`)    | ✅        | ❌        | Array (only for `--array`) |
| End Parsing          | `--input` (`-i`)                      | ❌        | ❌        | Remaining arguments        |

**Usage Notes:**

* `--name` (`-n`) – Name of


the flag for error messages or validations. **Required since 1.0.0-beta.01**

* `--return` (`-r` / `-o` / `--output`) – Target variable for storing the value(s). **Required since 1.0.0-beta.01**
* `--array` (`-y`) – Collect multiple values in an array
* `--number` (`-c`) – Only numeric values allowed
* `--letters` (`-l`) – Only alphabetic values allowed
* `--toggle` (`-t`) – Flag without value; sets target variable to `true`
* `--forbid` (`-f`) – Forbidden single characters
* `--allow` (`-a`) – Allowed single characters
* `--forbid-full` (`-F`) – Forbidden full values (strings); can be used multiple times or passed as an array
* `--dropping` (`-d`) – Stores invalid values in an array
* `--deduplicate` / `--dedub` (`-D`) – Removes duplicates from arrays; optional separate array
* `--input` (`-i`) – Marks end of option parsing; remaining CLI arguments passed to the function

---

## 🗂️ Changelog

* ⚡ **Required Options:** `-n|--name` and `-r|--return|-o|--output` must now be provided.
* 🧩 **Array Validation:** Every element of an array is validated (numbers, letters, Allow/Forbid/Forbid-Full).
* 💾 **Dropping:** Invalid values can optionally be stored in an array (`-d|--dropping`).
* ♻️ **Deduplicate:** Duplicate values in arrays can optionally be removed and stored separately (`-D|--dedub|--deduplicate`).
* 🛠️ **Code Refactoring:** Simplified argument processing, cleaner Nameref logic.
* ✅ **Validation Improved:** Number and letter checks, Allow/Forbid/Forbid-Full consistent for single values and arrays.
* ⚡ **Verbose:** Optional `-v|--verbose` shows detailed errors for invalid values.

---

## 🤖 Generation Note

This document was created with AI assistance and manually reviewed. Scripts, comments, and documentation were finalized and verified.

---

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)
* 📄 [MIT License](LICENSE)
