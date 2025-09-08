# 📋 Bash Function: Parse Case Flags

[![Back to Main README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/README.md)
[![Version](https://img.shields.io/badge/version-0.0.0_beta.01-blue.svg)](../../README.md)
[![German](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

A Bash function for **parsing, validating, and assigning command-line flags within a case block**.
Supports **single values, arrays, toggle flags**, validates values for numbers, letters, or forbidden characters/values, and keeps **all remaining arguments** after processing.

---

## 🚀 Table of Contents

* [📌 Important Notes](#-important-notes)
* [🛠️ Features](#-features)
* [⚙️ Requirements](#-requirements)
* [📦 Installation](#-installation)
* [📝 Usage](#-usage)

  * [🪄 Single Flag](#-single-flag)
  * [📚 Array & Multiple Values](#-array--multiple-values)
  * [⚡ Toggle Flags](#-toggle-flags)
  * [🔗 Combined Options](#-combined-options)
* [📌 API Reference](#-api-reference)
* [🤖 Generation Note](#-generation-note)
* [👤 Author & Contact](#-author--contact)

---

## 📌 Important Notes

With `--allow` you can explicitly define which characters are permitted in a value.
Any other characters will automatically result in an error.

⚠️ Ranges like `a-z` are **not supported**.
Instead, use `--letters` if you want to allow entire letter ranges.

➖ Passing `-` or `-<value>` is also possible.
However, the minus sign (`-`) must be escaped with a backslash (`\`).
Internally, the `\` is removed and the value is passed on without the backslash.

This is useful, for example, when forwarding parameters internally to other functions.


---

## 🛠️ Features

* 🎯 **Flag Parsing:** Supports single flags, arrays, and toggle options.
* 🔢 **Number Validation:** `--number` ensures only numeric values are allowed.
* 🔤 **Letter Validation:** `--letters` allows only alphabetic characters.
* ❌ **Forbidden Characters & Values:** `--forbid` and `--forbid-full` prevent certain characters or entire values (including wildcards `*`).
* 💾 **Variable Assignment:** Dynamically assigns values to variables via nameref (`declare -n`).
* 🔄 **Remaining Arguments Preservation:** All unprocessed CLI arguments remain in `"$@"`.
* ⚡ **Toggle Flags:** Flags without values set the variable to `true`.
* 🔗 **Combinable Options:** All validation options can be combined freely, e.g., `--array --number --forbid-full "root" "admin*"`.

---

## ⚙️ Requirements

* 🐚 **Bash Version ≥ 4.3** (required for `declare -n`)

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
      parse_case_flags "$1" name_var --letters "$2" -i "$@" || return 1
      shift 2
      ;;
  esac
done
```

**Explanation:**
Parses the `--name` flag and assigns the value `Alice` to the variable `name_var`. Remaining arguments stay intact.

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
* `--forbid-full "0" "999"` → forbids specific values
* Result: `ids_array=(1 2 3)`
* Remaining CLI arguments are preserved for the loop

---

## 📌 API Reference

| Description      | Argument / Alias        | Optional | Multiple | Type                           |
| ---------------- | ----------------------- | -------- | -------- | ------------------------------ |
| Flag Name        | `<flag>`                | ❌        | ❌        | String                         |
| Target Variable  | `<target_variable>`     | ❌        | ❌        | String                         |
| Array            | `--array`               | ✅        | ❌        | Flag                           |
| Number           | `--number`              | ✅        | ❌        | Flag                           |
| Letters          | `--letters`             | ✅        | ❌        | Flag                           |
| Toggle           | `--toggle`              | ✅        | ❌        | Flag                           |
| Forbidden Chars  | `--forbid <chars>`      | ✅        | ❌        | String                         |
| Forbidden Values | `--forbid-full <value>` | ✅        | ✅        | String                         |
| End Parsing      | `-i "$@"`               | ❌        | ❌        | Signal for remaining arguments |

**Output:**

* Single value or array assigned to target variable
* Toggle set to `true` if flag is used
* Validation messages on error
* Remaining CLI arguments preserved for the loop

---

## 🤖 Generation Note

This document was **AI-assisted** and manually reviewed.
Scripts, comments, and documentation were finalized and validated.

---

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)
* 📄 [MIT License](LICENSE)
