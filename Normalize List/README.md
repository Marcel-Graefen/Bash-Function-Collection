# 📋 Bash Function: normalize_list

[![Back to Main-README](https://img.shields.io/badge/Main-README-blue?style=flat&logo=github)](../README.md)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](#)
[![German](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

A flexible Bash function to normalize input strings into arrays. It splits strings based on spaces, commas, pipes, or custom separators and returns a clean array.

---

## 🚀 Table of Contents

* [📌 Important Notes](#-important-notes)
* [🛠️ Features & Functions](#-features--functions)
* [⚙️ Requirements](#%EF%B8%8F-requirements)
* [📦 Installation](#-installation)
* [📝 Usage](#-usage)
  * [Basic Call](#basic-call)
  * [Custom Separators](#custom-separators)
  * [Multiple Inputs at Once](#multiple-inputs-at-once)
  * [Complex Separators](#complex-separators)
* [📌 API Reference](#-api-reference)
* [👤 Author & Contact](#-author--contact)
* [🤖 Generation Note](#-generation-note)
* [📜 License](#-license)

---

## 📌 Important Notes

* ⚠️ **Output only via `-o|--output`:** Without specifying the output array, no result is returned.
* ⚠️ **Bash 4.0+ required:** The function uses namerefs for arrays.
* ⚠️ **Separators:** Default separators are space, pipe `|`, and comma `,`. Additional separators can be added with `-s`.

---

## 🛠️ Features & Functions

* 🟢 **Flexible Input:** Accepts one or multiple input strings at once.
* 🔹 **Custom Separators:** Regex-supported, e.g., space, comma, pipe, or custom characters.
* 🟣 **Array Output:** Populates a Bash array using a nameref (`-o|--output`).
* 🔒 **Robust Error Handling:** Warns if the output parameter is missing.
* ⚡ **Easy Integration:** Can be directly included in scripts with no dependencies.
* 💡 **Return Value:** 0 on success, 2 if `-o|--output` is missing.

---

## ⚙️ Requirements

* 🐚 **Bash** version 4.0 or higher (for namerefs and arrays).

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

# Check output
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

Splits strings into an array based on separators.

**Arguments:**

* `-i|--input` : Input string(s) (can be used multiple times)
* `-o|--output`: Name of the array to populate (**required!**)
* `-s|--separator`: Additional characters as separators (optional)

**Example:**

```bash
declare -a arr
normalize_list -i "foo bar,baz|qux" -s "|," -o arr
echo "${arr[@]}"
# Output: foo bar baz qux
```

**Return Values:**

* `0` on success
* `2` if `-o|--output` is missing

---

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)

---

## 🤖 Generation Note

This project was developed with the assistance of Artificial Intelligence (AI). The AI helped create the script, comments, and documentation (README.md). The final version was reviewed and adjusted by me.

---

## 📜 License

[MIT License](LICENSE)
