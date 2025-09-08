# 📋 Bash Function: Parse Case Flags

[![Back to Main README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/README.md)
[![Version](https://img.shields.io/badge/version-0.0.0_beta.02-blue.svg)](Old_Versions/v1.0.0-beta.01/README.md#)
[![Language](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

A Bash function for **parsing, validating, and assigning command-line flags inside a case block**.
Supports **single values, arrays, toggle flags**, validates numbers, letters, forbidden characters/values, and keeps **all remaining arguments** intact after processing.

---

## ✨ New Features

ℹ️ **Info – Allow Flags**

With `--allow` you can explicitly define which characters are permitted in a value.
Any other characters will automatically result in an error.

⚠️ Ranges like `a-z` are **not supported**.
Instead, use `--letters` to allow full letter ranges.

➖ Passing `-` or `-<value>` is also possible.
The minus sign (`-`) must be escaped with a backslash (`\`).
Internally the `\` is removed, and the value is passed without the backslash.

This is useful for forwarding parameters internally to other functions.

---

## 🚀 Table of Contents

* [📌 Important Notes](Old_Versions/v1.0.0-beta.01/README.md#-important-notes)
* [🛠️ Features](Old_Versions/v1.0.0-beta.01/README.md#-features)
* [⚙️ Requirements](Old_Versions/v1.0.0-beta.01/README.md#️-requirements)
* [📦 Installation](Old_Versions/v1.0.0-beta.01/README.md#-installation)
* [📝 Usage](Old_Versions/v1.0.0-beta.01/README.md#-usage)
  * [🪄 Simple Flag](Old_Versions/v1.0.0-beta.01/README.md#-simple-flag)
  * [📚 Array & Multiple Values](Old_Versions/v1.0.0-beta.01/README.md#-array--multiple-values)
  * [⚡ Toggle Flags](Old_Versions/v1.0.0-beta.01/README.md#-toggle-flags)
  * [🔗 Combined Options](Old_Versions/v1.0.0-beta.01/README.md#-combined-options)
  * [🛡️ Input Validation (Allow / Forbid / Forbid-Full)](Old_Versions/v1.0.0-beta.01/README.md#️-input-validation-allow--forbid--forbid-full)
    * [✅ Allow Flag](Old_Versions/v1.0.0-beta.01/README.md#-allow-flag)
    * [⛔ Forbid Flag](Old_Versions/v1.0.0-beta.01/README.md#-forbid-flag)
    * [🚫 Forbid-Full Flag](Old_Versions/v1.0.0-beta.01/README.md#-forbid-full-flag)
    * [📊 Comparison](Old_Versions/v1.0.0-beta.01/README.md#-comparison)
    * [🧩 Complete Example with All Flags](Old_Versions/v1.0.0-beta.01/README.md#-complete-example-with-all-flags)
* [📌 API Reference](Old_Versions/v1.0.0-beta.01/README.md#-api-reference)
* [🗂️ Changelog](Old_Versions/v1.0.0-beta.01/README.md#-changelog)
* [🤖 Generation Note](Old_Versions/v1.0.0-beta.01/README.md#-generation-note)
* [👤 Author & Contact](Old_Versions/v1.0.0-beta.01/README.md#-author--contact)

---

## 📌 Important Notes

* ⚠️ All **error and validation messages** are printed directly using `echo` to **stderr** – no external logging tools are required.
* ⚠️ The function is designed for usage **inside a while/case structure**. [More 💡 info](Old_Versions/v1.0.0-beta.01/README.md#-usage)

---

## 🛠️ Features

* 🎯 **Flag parsing:** Supports single values, arrays, and toggle flags.
* 🔢 **Number validation:** `--number` ensures only numeric values are allowed.
* 🔤 **Letter validation:** `--letters` allows only alphabetic characters.
* ❌ **Forbidden characters & values:** `--forbid` and `--forbid-full` block specific characters or whole values (including wildcards `*`).
* 💾 **Variable assignment:** Dynamic assignment to any variable via Nameref (`declare -n`).
* 🔄 **Preserves remaining arguments:** All unprocessed CLI arguments remain in `"$@"`.
* ⚡ **Toggle flags:** Flags without values can be set to `true`.
* 🔗 **Combinable options:** All validation options can be freely combined, e.g. `--array --number --forbid-full "root" "admin*"`.

---

## ⚙️ Requirements

* 🐚 **Bash version ≥ 4.3** (for `declare -n`)

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

* `--array` → collects multiple values into an array
* Result: `tags_array=("Dev" "Ops" "QA")`

---

### ⚡ Toggle Flags

```bash
parse_case_flags --verbose verbose_flag --toggle -i "$@" || return 1
```

**Explanation:**

* A flag without a value → sets the variable `verbose_flag` to `true`.

---

### 🔗 Combined Options

```bash
parse_case_flags --ids ids_array --array --number --forbid-full "0" "999" 1 2 3 -i "$@" || return 1
```

**Explanation:**

* `--array` → collects multiple values
* `--number` → only numbers allowed
* `--forbid-full "0" "999"` → forbids specific values
* Result: `ids_array=(1 2 3)`
* Remaining CLI arguments are preserved for the loop

---

## 🛡️ Input Validation (Allow / Forbid / Forbid-Full)

### ✅ Allow Flag

```bash
parse_case_flags --name myvar --array --allow "azAZ09._" -i "$@" || return 1
```

**Explanation:**
With `--allow` you can explicitly define which characters are permitted.
Any other characters will result in an error.
In this example, only letters, numbers, dots, and underscores are allowed.

> ⚠️ **Note:** Ranges like `a-z` are **not supported**.
>
> Use `--letters` for full letter ranges,
>
> or `--number` for numbers.

---

### ❌ Forbid Flag

```bash
parse_case_flags --name myvar --array --forbid "!@#" -i "$@" || return 1
```

**Explanation:**
With `--forbid` you can specify individual **forbidden characters**.
If any of these appear in a value, an error is raised.
In this example, the characters `!`, `@`, and `#` are forbidden.

---

### ⛔ Forbid-Full Flag

```bash
forbidden_values=("root" "admin" "error_file")
parse_case_flags --name myvar --array --forbid-full "${forbidden_values[@]}" -i "$@" || return 1
```

**Explanation:**
With `--forbid-full` you can block **entire values**.
In this example, the strings `root`, `admin`, and `error_file` are not allowed – if a parameter matches exactly, the function fails with an error.

---

### 📊 Comparison

| Flag            | Purpose                   | Example Error                |
| --------------- | ------------------------- | ---------------------------- |
| `--allow`       | Allow only specific chars | `bad@file` → `@` not allowed |
| `--forbid`      | Forbid certain characters | `bad@file` → `@` forbidden   |
| `--forbid-full` | Forbid entire values      | `error_file` → value blocked |

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
    --allow "azAZ09._" \
    --forbid "!@#" \               # forbid chars ! @ #
    --forbid-full "${forbidden_values[@]}" || return 1  # forbid whole values

  echo "Valid inputs: ${inputs[*]}"
}

# Example call
validate_inputs "hello_world" "safe.file" "bad@file" "admin"
```

**Example explained:**

* `hello_world` ✅ allowed
* `safe.file` ✅ allowed
* `bad@file` ❌ error, because `@` is forbidden (`--forbid`)
* `admin` ❌ error, because full value is forbidden (`--forbid-full`)

---

## 📌 API Reference

| Description      | Argument / Alias        | Optional | Multiple | Type                      |
| ---------------- | ----------------------- | -------- | -------- | ------------------------- |
| Flag Name        | `<flag>`                | ❌        | ❌        | String                    |
| Target Variable  | `<target_variable>`     | ❌        | ❌        | String                    |
| Array            | `--array`               | ✅        | ❌        | Flag                      |
| Numbers          | `--number`              | ✅        | ❌        | Flag                      |
| Letters          | `--letters`             | ✅        | ❌        | Flag                      |
| Toggle           | `--toggle`              | ✅        | ❌        | Flag                      |
| Forbidden Chars  | `--forbid <chars>`      | ✅        | ❌        | String                    |
| Allowed Chars    | `--allow <chars>`       | ✅        | ❌        | String                    |
| Forbidden Values | `--forbid-full <value>` | ✅        | ✅        | String                    |
| End Parsing      | `-i "$@"`               | ❌        | ❌        | Signal for remaining args |

**Output:**

* Single value or array in the target variable
* Toggle set to `true` if flag provided
* Validation messages in case of errors
* Remaining CLI arguments preserved for further parsing

---

## 🗂️ Changelog

### Version 0.0.0-Beta.02 – Improvements over 0.0.1-Beta.01

🆕 **Allow/Forbidden chars validation:**

* New function `check_chars()` for allow/forbid character lists
* Automatic reduction of bracket pairs `()`, `[]`, `{}` to opening brackets
* Correct validation of all special characters, no regex issues anymore

⚡ **Performance & robustness:**

* Character-by-character validation replaces problematic regex classes
* Stable for all inputs, including special char/bracket combinations

✨ **Argument improvements:**

* New parameter `--allow` for allowed characters
* Improved handling of escaped inputs (`\-`) for `forbid_full` and values

🧹 **Code refactoring:**

* Validation moved into reusable function
* Removed duplicate regex logic
* Unified error messages with allowed/forbidden character display

---

## 🤖 Generation Note

This document was generated with AI assistance and manually verified.
Scripts, comments, and documentation were reviewed and adjusted.

---

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)
* 📄 [MIT License](Old_Versions/v1.0.0-beta.01/LICENSE)
