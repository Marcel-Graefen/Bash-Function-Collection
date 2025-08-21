# 📋 Bash Function: display_table

[![Back to Main README](https://img.shields.io/badge/Main-README-blue?style=flat&logo=github)](../README.md)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](#)
[![Deutsch](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

A flexible Bash function to display formatted tables in the terminal. It automatically calculates column widths, centers the header, and prints each row neatly.

---

## 🚀 Table of Contents

* [📌 Important Notes](#-important-notes)
* [🛠️ Functions & Features](#-functions--features)
* [⚙️ Requirements](#%EF%B8%8F-requirements)
* [📦 Installation](#-installation)
* [📝 Usage](#-usage)
  * [1️⃣ Basic Call](#1️⃣-basic-call)
  * [2️⃣ Multiple Rows](#2️⃣-multiple-rows)
  * [3️⃣ Custom Separator](#3️⃣-custom-separator)
  * [4️⃣ Write output to a variable](#4️⃣-write-output-to-a-variable)
* [📌 API Reference](#-api-reference)
* [👤 Author & Contact](#-author--contact)
* [🤖 Generation Note](#-generation-note)
* [📜 License](#-license)

---

## 📌 Important Notes

* ⚠️ **normalize_list required:** The function internally uses `normalize_list`. It must be available.
* ⚠️ **Bash 4.0+ required:** For namerefs and arrays.
* ⚠️ **Output by default in the terminal:** The function prints directly to the standard output.

---

## 🛠️ Functions & Features

* 🟢 **Flexible rows & columns:** Each row can contain multiple columns.
* 🔹 **Automatic column widths:** Adjusts column width to the longest content.
* 🟣 **Header centering:** Optional table header is centered.
* 🔒 **Robust error checking:** Verifies required functions exist.
* ⚡ **Easy integration:** Can be included directly in Bash scripts.
* 💡 **Return value:** 0 on success, 2 if required functions are missing.

---

## ⚙️ Requirements

* 🐚 **Bash** version 4.0 or higher (for namerefs and arrays).
* ƒ  **Function** Needs the function [`Normalize List`](../Normalize%20List/README.md) v1.0.0

---

## 📦 Installation

Simply include the function in your Bash script:

```bash
#!/usr/bin/env bash

source "/path/to/display_table.sh"
source "/path/to/normalize_list.sh"
```

---

## 📝 Usage

### 1️⃣ Basic Call

```bash
display_table -H "My Table" -v "Value1,Value2,Value3"
```

**Output:**

```
+--------+--------+--------+
|       My Table          |
+--------+--------+--------+
| Value1 | Value2 | Value3 |
+--------+--------+--------+
```

---

### 2️⃣ Multiple Rows

```bash
display_table -H "My Table" \
  -v "Value1,Value2,Value3" \
  -v "A,B,C"
```

**Output:**

```
+--------+--------+--------+
|       My Table          |
+--------+--------+--------+
| Value1 | Value2 | Value3 |
+--------+--------+--------+
| A      | B      | C      |
+--------+--------+--------+
```

---

### 3️⃣ Custom Separator

```bash
display_table -H "My Table" \
  -v "Value1|Value2|Value3" \
  -s "|"
```

**Output:**

```
+--------+--------+--------+
|       My Table          |
+--------+--------+--------+
| Value1 | Value2 | Value3 |
+--------+--------+--------+
```

---

### 4️⃣ Write output to a variable

```bash
# Stores the output in a variable
table_output=$(display_table -H "My Table" -v "Value1,Value2,Value3" -v "A,B,C")

# Now the variable can be used
echo "$table_output"
```

---

## 📌 API Reference

### `display_table`

Displays formatted tables in the terminal.

**Arguments:**

* `-H|--header` : Optional table header.
* `-v|--value`  : Row content (can be used multiple times).
* `-s|--separator`: Column separator (default: space).

**Return Values:**

* `0` on success
* `2` if required functions are missing (e.g., `normalize_list`)

---

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)

---

## 🤖 Generation Note

This project was developed with the help of Artificial Intelligence (AI). The AI assisted in writing the script, comments, and documentation (README.md). The final result was reviewed and adjusted by me.

---

## 📜 License

[MIT License](LICENSE)
