# 📋 Bash Function: Parse Case Flags

[![German](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![Back to Main README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/README.md)
[![Version](https://img.shields.io/badge/version-1.0.0_beta.04-blue.svg)](./Versions/README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-≥4.3-green.svg)]()

`parse_case_flags` is a Bash function for **parsing, validating and assigning command-line flags inside a `case` block**.
It supports **single values, arrays and toggle flags**, validates values for numbers, letters, allowed/forbidden characters/values, and automatically returns **remaining parameters**.

---

## 🚀 Table of Contents

* [🆕 New in Version 1.0.0-beta.04](#-new-in-version-100-beta04)
* [🛠️ Features](#-features)
* [⚙️ Requirements](#-requirements)
* [📦 Installation](#-installation)
* [📝 Usage](#-usage)

  * [💡 Single Value](#-single-value)
  * [📦 Array & Multiple Values](#-array--multiple-values)
  * [⚡ Toggle Flags](#-toggle-flags)
  * [🔗 Combined Options](#-combined-options)
  * [🛡️ Input Validation (Allow / Forbid / Full)](#-input-validation-allow--forbid--full)

    * [Character-based Validation](#character-based-validation---allow---forbid)
    * [Value-based Validation](#value-based-validation---allow-full---forbid-full)
    * [Comparison Table](#comparison-table)
    * [Combined Usage](#combined-usage)
  * [💎 Masked Leading Dashes](#-masked-leading-dashes)
  * [🔄 Automatic Parameter Forwarding](#-automatic-parameter-forwarding)
* [📌 API Reference](#-api-reference)
* [🗂️ Changelog](#-changelog)
* [🤖 Generation Note](#-generation-note)

---

## 🆕 New in Version 1.0.0-beta.04

### 🔄 Automatic Parameter Forwarding

New option `--rest-params` (`-R`) automatically returns **unprocessed parameters**:

```bash
-d|--directory)
  local rest_params
  parse_case_flags --name "directory" --return dir --array --rest-params rest_params -i "$@" || return 1
  set -- "${rest_params[@]}"
  ;;
```

**Advantages:**

* ✅ **No manual shifting** required
* ✅ **Automatic forwarding** to the next case
* ✅ **Works for single and array values alike**
* ✅ **Simpler code structure**

### 🎯 Simplified Case Logic

**Before (complex):**

```bash
-d|--directory)
  parse_case_flags --name "directory" --return tmpdir --array -i "$@" || return 1
  directories+=("${tmpdir[@]}")
  shift "${#tmpdir[@]}"
  shift 1
  ;;
```

**After (simple):**

```bash
-d|--directory)
  local rest_params
  parse_case_flags --name "directory" --return directories --array --rest-params rest_params -i "$@" || return 1
  set -- "${rest_params[@]}"
  ;;
```

### 🔧 Other Improvements

* **Input Deduplication**: `--dedub-input` (`-DI`) for external deduplication values
* **Improved Error Handling**: consistent return codes
* **Performance Optimizations**: more efficient parameter processing

---

## 🛠️ Features

* 🎯 **Flag Parsing**: single values, arrays, toggle flags
* 🔢 **Number Validation**: `--number`
* 🔤 **Letter Validation**: `--letters`
* ✅ **Allowed Characters & Values**: `--allow` / `--allow-full`
* ❌ **Forbidden Characters & Values**: `--forbid` / `--forbid-full`
* 💾 **Variable Assignment**: via nameref (`declare -n`)
* 💾 **Dropping Array**: optionally store invalid values (`--dropping`)
* 💾 **Array Deduplication**: optionally remove duplicates (`--deduplicate`)
* 🔄 **Automatic Parameter Forwarding**: `--rest-params`
* ⚡ **Toggle Flags**: target variable is set to `true` (single values only)
* 📢 **Verbose**: detailed error messages (`--verbose` / `-v`)
* 💡 **Masked Leading Dashes**: `\-value` → correctly passed on
* 🛑 **None-Zero (`--none-zero` / `-nz`)**: enforces at least one value (0 allowed)
* 🚩 **Flag Recognition**: optional recognition of flags in array mode (`--no-recognize-flags`)

---

## ⚙️ Requirements

* 🐚 Bash Version ≥ 4.3 (for nameref `declare -n`)

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
  local rest_params
  parse_case_flags --name "result" --return output --verbose --rest-params rest_params -i "$@" || return 1
  set -- "${rest_params[@]}"
  ;;
```

* Processes a single value
* `--verbose` optional for error output
* Remaining parameters automatically forwarded

---

### 📦 Array & Multiple Values

```bash
-d|--directory)
  local rest_params
  parse_case_flags --name "directories" --return directories --array --rest-params rest_params -i "$@" || return 1
  set -- "${rest_params[@]}"
  ;;
```

* **No temporary array** needed
* **No manual shifting**
* **Automatic forwarding** to the next case

#### Test Call:

```bash
script.sh -d "/etc" "/home" -f "file1.txt" -v "value"
```

#### Processing:

* `-d` handles `/etc` and `/home`
* Remaining parameters (`-f "file1.txt" -v "value"`) automatically forwarded

---

### ⚡ Toggle Flags

```bash
-F|--force)
  parse_case_flags -n "force" --toggle || return 1
  shift 1
;;
```

* Toggle automatically sets the target variable to `true`
* Only single values possible
* Shift 1, as no value follows

---

### 🔗 Combined Options

```bash
-i|--ids)
  local rest_params
  parse_case_flags --name "ids" --return ids_array --array --number --forbid-full "0" "999" --deduplicate --dropping invalid_ids --rest-params rest_params --verbose -i "$@" || return 1
  set -- "${rest_params[@]}"
  ;;
```

* Combination of array, number check, full-forbid, deduplication and dropping
* Automatic parameter forwarding

---

## 🛡️ Input Validation (Allow / Forbid / Full)

### 🔤 Character-based Validation (`--allow` / `--forbid`)

**Checks individual characters** within values:

```bash
# Allow only these characters
parse_case_flags --allow "a-zA-Z0-9._-" --return username

# Forbid these characters
parse_case_flags --forbid "!@#$%^&*()" --return filename
```

**Examples:**

* `--allow "abc"` → allows: "cab", "abc", "a" | forbids: "abcd", "x"
* `--forbid "123"` → forbids: "a1b", "123", "2" | allows: "abc", "xyz"

### 🔍 Value-based Validation (`--allow-full` / `--forbid-full`)

**Checks entire values** (supports `*` wildcards):

```bash
# Allow only certain values
parse_case_flags --allow-full "admin" "user*" "guest" --return role

# Forbid certain values
parse_case_flags --forbid-full "root" "test*" "temp" --return username
```

**Examples:**

* `--allow-full "admin" "user*"` → allows: "admin", "user1", "user_john" | forbids: "guest", "admin2"
* `--forbid-full "test*" "temp"` → forbids: "test", "test123", "temp" | allows: "prod", "live"

### 📊 Comparison Table

| Feature         | `--allow` / `--forbid`        | `--allow-full` / `--forbid-full` |
| --------------- | ----------------------------- | -------------------------------- |
| **Check Level** | Individual Characters         | Entire Values                    |
| **Wildcards**   | ❌ No                          | ✅ Yes (`*` supported)            |
| **Use Case**    | Character whitelist/blacklist | Value whitelist/blacklist        |
| **Example**     | `--allow "a-z0-9"`            | `--allow-full "user*" "admin"`   |
| **Performance** | Faster (character check)      | Slower (string comparison)       |

### 💡 Combined Usage

Both methods can be combined:

```bash
local rest_params
parse_case_flags --name "inputs" --return inputs --array \
  --allow "a-zA-Z0-9"        # Only alphanumeric characters \
  --forbid-full "admin" "root"  # But not these specific values \
  --rest-params rest_params \
  --verbose -i "$@" || return 1

set -- "${rest_params[@]}"
echo "Valid inputs: ${inputs[*]}"
```

**Result:** "user123" ✅ allowed, "admin" ❌ forbidden, "us$r" ❌ forbidden characters

**Summary:**

* **`--allow`/`--forbid`** = character check ("may/may not contain these characters")
* **`--allow-full`/`--forbid-full`** = value check ("must/must not be this value")

---

### 💎 Masked Leading Dashes

```bash
local rest_params
parse_case_flags --name "options" --return opts_array --array --rest-params rest_params -i "\-example" "\-safe" --verbose || return 1
set -- "${rest_params[@]}"
```

* `\-example` → correctly passed as `-example`

---

## 🔄 Automatic Parameter Forwarding

The new `--rest-params` option makes case logic **much simpler**:

```bash
while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--directory)
      local rest_params
      parse_case_flags --name "directory" --return directories --array --rest-params rest_params -i "$@" || return 1
      set -- "${rest_params[@]}"
      ;;

    -f|--file)
      local rest_params
      parse_case_flags --name "files" --return files --array --rest-params rest_params -i "$@" || return 1
      set -- "${rest_params[@]}"
      ;;

    *)
      echo "Unknown option: $1"
      shift
      ;;
  esac
done
```

**Advantages:**

* ✅ **Less code** in each case
* ✅ **No shift calculations** needed
* ✅ **More robust** against parameter changes
* ✅ **Improved readability**

---

## 📌 API Reference

| Description          | Argument / Alias                       | Optional | Multiple | Type           |
| -------------------- | -------------------------------------- | -------- | -------- | -------------- |
| Flag Name            | `--name` (`-n`)                        | ❌        | ❌        | String         |
| Target Variable      | `--return` / `--output` (`-r` / `-o`)  | ❌        | ❌        | String         |
| Array                | `--array` (`-y`)                       | ✅        | ❌        | Flag           |
| Numbers              | `--number` (`-c`)                      | ✅        | ❌        | Flag           |
| Letters              | `--letters` (`-l`)                     | ✅        | ❌        | Flag           |
| Toggle               | `--toggle` (`-t`)                      | ✅        | ❌        | Flag           |
| Forbidden Characters | `--forbid` (`-f`)                      | ✅        | ❌        | String         |
| Allowed Characters   | `--allow` (`-a`)                       | ✅        | ❌        | String         |
| Forbidden Values     | `--forbid-full` (`-F`)                 | ✅        | ✅        | String / Array |
| Allowed Values       | `--allow-full` (`-A`)                  | ✅        | ✅        | String / Array |
| Dropping Array       | `--dropping` (`-d`)                    | ✅        | ❌        | String / Array |
| Deduplicate Array    | `--deduplicate` (`-D`)                 | ✅        | ❌        | Flag           |
| Deduplicate Input    | `--dedub-input` (`-DI`)                | ✅        | ✅        | String / Array |
| Rest Parameters      | `--rest-params` (`-R`)                 | ✅        | ❌        | String / Array |
| Input Values         | `--input` (`-i`)                       | ❌        | ✅        | String / Array |
| Terminal Output      | `--verbose` (`-v`)                     | ✅        | ❌        | Flag           |
| Must Have Value      | `--none-zero` (`-nz`)                  | ✅        | ❌        | Flag           |
| No Flag Recognition  | `--no-recognize-flags` (`-nrf`, `-NF`) | ✅        | ❌        | Flag           |

> ⚠️ Masked leading dashes (`\-`) are automatically removed.

---

## 🗂️ Changelog

**v1.0.0-beta.04** – *Current Version*

* ✅ **New `--rest-params` option** for automatic parameter forwarding
* ✅ **Simplified case logic** – no more manual shifting
* ✅ **Input Deduplication** (`--dedub-input`) for external values
* ✅ **Improved error handling** and consistency

**v1.0.0-beta.03**

* New flag recognition for case statements
* Temporary variables + `+=` for **multiple identical flags**
* Shift 2 / 1 rule documented
* Improved case integration

**v1.0.0-beta.02**

* `--name` and `--return` mandatory
* Toggle flags limited to single values
* Added masked leading dashes (`\`)
* Included deduplication and dropping
* Refined Allow/Forbid/Full validation

---

## 🤖 Generation Note

This document was created with AI assistance and then manually reviewed.
Scripts, comments, and documentation were finalized and adjusted.
