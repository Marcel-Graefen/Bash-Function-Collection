# 📋 Bash Function: normalize_list

[![Back to Main README](https://img.shields.io/badge/Main-README-blue?style=flat&logo=github)](../README.md)
[![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)](#)
[![German](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

A flexible Bash function to normalize input strings into arrays. It splits strings using spaces, commas, pipes, or custom separators and returns a clean array. Errors are handled consistently with `echo` + `return 2`.

---

## 🚀 Table of Contents

* [📌 Important Notes](#-important-notes)
* [🛠️ Features](#-features)
* [⚙️ Requirements](#%EF%B8%8F-requirements)
* [📦 Installation](#-installation)
* [📝 Usage](#-usage)
* [📌 API Reference](#-api-reference)
* [🗂️ Changelog](#-changelog)
* [👤 Author & Contact](#-author--contact)
* [🤖 Generation Note](#-generation-note)
* [📜 License](#-license)

---

## 📌 Important Notes

* ⚠️ **Output only via `-o|--output`:** No result is returned without specifying the output array.
* ⚠️ **Bash 4.0+ required:** The function uses Namerefs for arrays.
* ⚠️ **Error handling:** All errors print `echo "❌ ERROR: ..."` and return `2`.
* ⚠️ **Separators:** By default space, pipe `|`, and comma `,`. Additional separators can be set with `-s`.

---

## 🛠️ Features

* 🟢 **Flexible input:** Accepts one or multiple strings simultaneously.
* 🔹 **Custom separators:** Supports regex-like splitting, e.g., space, comma, pipe, or custom characters.
* 🟣 **Array output:** Populates a Bash array using Nameref (`-o|--output`).
* 🔒 **Robust error handling:** Detects missing parameters and reports errors.
* ⚡ **Easy integration:** Can be directly embedded into scripts with no external dependencies.
* 💡 **Return value:** `0` on success, `2` on errors.

---

## ⚙️ Requirements

* 🐚 **Bash** version 4.0 or higher (for Namerefs and arrays).

---

## 📦 Installation

Simply include the function in your Bash script:

```bash
#!/usr/bin/env bash

source "/path/to/normalize_list.sh"
````

---

## 📝 Usage

### Basic Call

```bash
declare -a my_array

normalize_list -i "apple orange banana" -o my_array

printf "%s\n" "${my_array[@]}"
```

**Output:**

```
apple
orange
banana
```

---

### Custom Separators

```bash
declare -a fruits

normalize_list -i "apple,orange,banana" -s "," -o fruits

printf "%s\n" "${fruits[@]}"
```

**Output:**

```
apple
orange
banana
```

---

### Multiple Inputs at Once

```bash
declare -a items

normalize_list -i "apple orange" -i "banana|kiwi" -o items

printf "%s\n" "${items[@]}"
```

**Output:**

```
apple
orange
banana
kiwi
```

---

### Complex Separators

```bash
declare -a values

normalize_list -i "val1|val2;val3 val4" -s "|; " -o values

printf "%s\n" "${values[@]}"
```

**Output:**

```
val1
val2
val3
val4
```

---

## 📌 API Reference

### `normalize_list`

Splits strings into an array based on separators. Errors are printed as `echo "❌ ERROR: ..."` and return `2`.

**Arguments:**

* `-i|--input` : Input string (multiple allowed).
* `-o|--output`: Name of the array to populate (**required!**).
* `-s|--separator`: Additional characters as separators (optional).

**Example:**

```bash
declare -a arr
normalize_list -i "foo bar,baz|qux" -s "|," -o arr
echo "${arr[@]}"
# Output: foo bar baz qux
```

**Return values:**

* `0` on success
* `2` if output parameter is missing or other errors occur

---

## 🗂️ Changelog

* ✅ **Unified error handling:** All errors now print `echo "❌ ERROR: ..."` + `return 2`.
* ⚡ **Compact argument parsing:** `case` blocks are one-line, with `check_value` helper for required values.
* 🟢 **Modernized separator handling:** Uses `IFS + read -a` for fast and compact array creation.
* 📝 **Improved readability & structure:** Clearer comments and explicit `return 0` at the end.

### Differences to Version 1.0.0

| Feature / Change                                | 1.1.0 | 1.0.0 |
|-------------------------------------------------|-------|-------|
| ❌ Consistent error output                      |  ✅  |  ❌  |
| ⚡ Compact argument parsing                     |  ✅  |  ❌  |
| 🟢 Separator handling                           |  ✅  |  ❌  |
| 💡 Clearly defined return values 0/2            |  ✅  |  ❌  |
| 📝 Readability & structure                      |  ✅  |  ❌  |
| 🔹 Support for multiple inputs                  |  ✅  |  ❌  |
| 🧩 Optional additional separator `-s`           |  ✅  |  ❌  |
| ✅ Multiple calls for input/separator           |  ✅  |  ❌  |
| 🌐 Consistent English and German error messages |  ✅  |  ❌  |
| ⚡ Exit option `-x/--exit` available            |  ✅  |  ❌  |


---

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)

---

## 🤖 Generation Note

This project was developed with the help of an AI. The AI assisted in writing the script, comments, and documentation. The final result was reviewed and adapted manually.

---

## 📜 License

[MIT License](LICENSE)
