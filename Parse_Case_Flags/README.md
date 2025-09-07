# 📋 Bash Function: `parse_case_flags`

[![Back to Main README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/README.md)
[![Version](https://img.shields.io/badge/version-0.0.0_beta.03-blue.svg)](#)
[![German](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

A Bash function for **parsing, validating, and assigning command-line flags within a case block**.
Supports **single values, arrays, and toggle flags**, validates values for numbers, letters, or forbidden characters/values, and keeps **all remaining arguments** after processing.

---

## ✨ New Features

* 🔹 **New `--allow` Option**
  Allows specifying which characters are **permitted** in a value. Any characters not in the allow list will trigger an error.

---

## 🚀 Table of Contents

* [📌 Important Notes](#-important-notes)
* [🛠️ Features & Functions](#-features--functions)
* [⚙️ Requirements](#%EF%B8%8F-requirements)
* [📦 Installation](#-installation)
* [📝 Usage](#-usage)

  * [🪄 Simple Flag](#-simple-flag)
  * [📚 Array & Multiple Values](#-array--multiple-values)
  * [⚡ Toggle Flags](#-toggle-flags)
  * [🔗 Combined Options](#-combined-options)
  * [🛡️ Input Validation (Allow / Forbid / Forbid-Full)](#-input-validation-allow--forbid--forbid-full)

    * [✅ Allow Flag](#-allow-flag)
    * [⛔ Forbid Flag](#-forbid-flag)
    * [🚫 Forbid-Full Flag](#-forbid-full-flag)
    * [📊 Comparison](#-comparison)
    * [🧩 Complete Example with All Flags](#-complete-example-with-all-flags)
* [📌 API Reference](#-api-reference)
* [🗂️ Changelog](#-changelog)
* [🤖 Generation Note](#-generation-note)
* [👤 Author & Contact](#-author--contact)

---

## 📌 Important Notes

* ⚠️ All **error or validation messages** are printed directly via `echo` to **stderr**—no external logging functions or tools are used.
* ⚠️ The function is intended to be used **within a while/case structure**. [More 💡Info](#-usage)

---

## 🛠️ Features & Functions

* 🎯 **Flag Parsing:** Supports single flags, arrays, and toggle options.
* 🔢 **Number Validation:** `--number` ensures only numeric values are allowed.
* 🔤 **Letter Validation:** `--letters` allows only alphabetic characters.
* ❌ **Forbidden Characters & Values:** `--forbid` and `--forbid-full` prevent certain characters or whole values (wildcards `*` supported).
* 💾 **Variable Assignment:** Dynamic assignment to any variable using Nameref (`declare -n`).
* 🔄 **Preserve Remaining Arguments:** Any CLI arguments not processed remain in `"$@"`.
* ⚡ **Toggle Flags:** Flags without a value are set to `true`.
* 🔗 **Combinable Options:** All validation options can be combined, e.g., `--array --number --forbid-full "root" "admin*"`.

---

## ⚙️ Requirements

* 🐚 **Bash Version ≥ 4.3** (for `declare -n`)

---

## 📦 Installation

```bash
#!/usr/bin/env bash

source "/path/to/parse_case_flags.sh"
```

---

## 📝 Usage

### 🪄 Simple Flag

```bash
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      parse_case_flags "$1" name_var --letters "$2" -i "$@" || return 1
      shift 2
      ;;
  esac
done
```

**Explanation:**
Parses the flag `--name` and assigns the value `Alice` to the variable `name_var`. Remaining arguments are preserved.

---

### 📚 Array & Multiple Values

```bash
parse_case_flags --tags tags_array --array Dev Ops QA -i "$@" || return 1
```

**Explanation:**

* `--array` → collects multiple values
* Result: `tags_array=("Dev" "Ops" "QA")`

---

### ⚡ Toggle Flags

```bash
parse_case_flags --verbose verbose_flag --toggle -i "$@" || return 1
```

**Explanation:**

* Flag without value → sets `verbose_flag` to `true`.

---

### 🔗 Combined Options

```bash
parse_case_flags --ids ids_array --array --number --forbid-full "0" "999" 1 2 3 -i "$@" || return 1
```

**Explanation:**

* `--array` → collects multiple values
* `--number` → allows only numbers
* `--forbid-full "0" "999"` → forbids certain values
* Result: `ids_array=(1 2 3)`
* Remaining CLI arguments stay for the loop

---

## 🛡️ Input Validation (Allow / Forbid / Forbid-Full)

### ✅ Allow Flag

```bash
parse_case_flags --name myvar --array --allow "a-zA-Z0-9._" -i "$@" || return 1
```

**Explanation:**
With `--allow`, you can specify exactly which characters are allowed in a value. All other characters cause an error.
In the example, only letters, numbers, dots, and underscores are permitted.

---

### ❌ Forbid Flag

```bash
parse_case_flags --name myvar --array --forbid "!@#" -i "$@" || return 1
```

**Explanation:**
`--forbid` lets you specify **individual forbidden characters**.
If these characters appear in the value, an error is thrown.
Example: `!`, `@`, and `#` are forbidden.

---

### 🚫 Forbid-Full Flag

```bash
forbidden_values=("root" "admin" "error_file")
parse_case_flags --name myvar --array --forbid-full "${forbidden_values[@]}" -i "$@" || return 1
```

**Explanation:**
`--forbid-full` forbids **specific full values**.
In the example, `"root"`, `"admin"`, and `"error_file"` are prohibited—if a parameter matches exactly, the function exits with an error.

---

### 📊 Comparison

| Flag            | Purpose                       | Example Error                  |
| --------------- | ----------------------------- | ------------------------------ |
| `--allow`       | Allow only certain characters | `bad@file` → `@` not allowed   |
| `--forbid`      | Forbid specific characters    | `bad@file` → `@` forbidden     |
| `--forbid-full` | Forbid full values            | `error_file` → value forbidden |

---

### 🧩 Complete Example with All Flags

```bash
#!/usr/bin/env bash
source ./parse_case_flags.sh

validate_inputs() {
  local inputs=()

  # Forbidden full values
  local forbidden_values=("root" "admin" "error_file")

  parse_case_flags -i "$@" \
    --name inputs --array \
    --allow "a-zA-Z0-9._" \        # Only letters, numbers, . and _ allowed
    --forbid "!@#" \               # Forbidden characters ! @ #
    --forbid-full "${forbidden_values[@]}" || return 1  # Forbidden full values

  echo "Valid inputs: ${inputs[*]}"
}

# Example call
validate_inputs "hello_world" "safe.file" "bad@file" "admin"
```

**Explanation:**

* `hello_world` ✅ allowed
* `safe.file` ✅ allowed
* `bad@file` ❌ error because `@` is forbidden (`--forbid`)
* `admin` ❌ error because full value is forbidden (`--forbid-full`)

---

## 📌 API Reference

| Description      | Argument / Alias        | Optional | Multiple | Type                      |
| ---------------- | ----------------------- | -------- | -------- | ------------------------- |
| Flag Name        | `<flag>`                | ❌        | ❌        | String                    |
| Target Variable  | `<target_variable>`     | ❌        | ❌        | String                    |
| Array            | `--array`               | ✅        | ❌        | Flag                      |
| Number           | `--number`              | ✅        | ❌        | Flag                      |
| Letters          | `--letters`             | ✅        | ❌        | Flag                      |
| Toggle           | `--toggle`              | ✅        | ❌        | Flag                      |
| Forbidden Chars  | `--forbid <chars>`      | ✅        | ❌        | String                    |
| Allowed Chars    | `--allow <chars>`       | ✅        | ❌        | String                    |
| Forbidden Values | `--forbid-full <value>` | ✅        | ✅        | String                    |
| End Parsing      | `-i "$@"`               | ❌        | ❌        | Signal for remaining args |

**Output:**

* Single value or array in the target variable
* Toggle set to `true` if flag present
* Validation errors on invalid input
* Remaining CLI


arguments preserved for the loop

---

## 🗂️ Changelog

* Added `--allow` to explicitly define allowed characters.

---

## 🤖 Generation Note

This document was generated with AI support and manually reviewed afterward.
Scripts, comments, and documentation were finalized and verified.

---

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)
* 📄 [MIT License](LICENSE)
