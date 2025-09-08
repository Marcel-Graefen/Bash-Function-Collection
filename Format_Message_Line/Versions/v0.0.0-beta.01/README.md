# 📋 Bash Function: Format Message Line

[![Back to Main README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/README.de.md)
[![Version](https://img.shields.io/badge/version-0.0.0_beta.01-blue.svg)](#)
[![German](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

A Bash function to **format messages in decorative lines** with brackets, fill characters, padding, and minimum length.
The output can either be printed directly via `echo` or stored in a variable.

---

## 🚀 Table of Contents

* [📌 Important Notes](#-important-notes)
* [🛠️ Features](#-features)
* [⚙️ Requirements](#-requirements)
* [📦 Installation](#-installation)
* [📝 Usage](#-usage)
  * [🪄 Simple Flag](#-simple-flag)
  * [📚 Various Parameters](#-various-parameters)
  * [💾 Output to Variable](#-output-to-variable)
  * [📊 Output Examples](#-output-examples)
* [📌 API Reference](#-api-reference)
* [🤖 Generation Note](#-generation-note)
* [👤 Author & Contact](#-author--contact)

---

## 📌 Important Notes

* ⚠️ All output is sent to `echo` by default unless the `-r|--result` option is provided.
* ⚠️ The function parameters can be combined freely: length, brackets, fill characters, inner and outer padding.

---

## 🛠️ Features

* 🎯 Flexible text formatting
* 🔢 Adjustable minimum length
* ↔️ Inner (`-ip`) and outer (`-op`) padding
* 🔤 Different brackets: `[]`, `()`, `{}`, `<>`
* 💾 Output via `echo` or variable (`-r|--result`)
* ⚡ Supports combining all parameters for complex layouts

---

## ⚙️ Requirements

* 🐚 Bash Version ≥ 4.3
* Required function: [`parse_case_flags`](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/Parse_Case_Flags/README.md)

---

## 📦 Installation

```bash
#!/usr/bin/env bash

source "/path/to/format_message_line.sh"
```

---

## 📝 Usage

### 🪄 Simple Flag

```bash
format_message_line -m "Hello World"
```

Output via `echo`:

```
=================[Hello World]=================
```

---

### 📚 Various Parameters

```bash
format_message_line -m "Hello" -l 30
format_message_line -m "Hello" -b "{}"
format_message_line -m "Hello" -b "<>" -f "-"
format_message_line -m "Hello" -ip 2 -op 3
format_message_line -m "Hello World!" -l 40 -b "[]" -f "*" -ip 1 -op 2
format_message_line -m "Short" -b "()" -f "~" -ip 0 -op 0
format_message_line -m "Longer Message" -l 60 -b "{}" -f "=" -ip 3 -op 1
```

---

### 💾 Output to Variable

```bash
format_message_line -m "Hello" -r line1
format_message_line -m "World" -b "{}" -f "*" -ip 2 -op 1 -r line2
format_message_line -m "Bash Fun!" -l 50 -b "()" -f "-" -ip 1 -op 3 -r line3

echo "Line 1: $line1"
echo "Line 2: $line2"
echo "Line 3: $line3"
```

---

### 📊 Output Examples

| Call                                                   | Possible Output                                              |
| ------------------------------------------------------ | ------------------------------------------------------------ |
| `-m "Hello"`                                           | `====================[Hello]====================`            |
| `-m "Hello" -l 30`                                     | `========[Hello]========`                                    |
| `-m "Hello" -b "{}"`                                   | `========{Hello}========`                                    |
| `-m "Hello" -b "<>" -f "-"`                            | `--------<Hello>--------`                                    |
| `-m "Hello" -ip 2 -op 3`                               | `===   [  Hello  ]   ===`                                    |
| `-m "Hello World!" -l 40 -b "[]" -f "*" -ip 1 -op 2`   | `********  [ Hello World! ]  ********`                       |
| `-m "Short" -b "()" -f "~" -ip 0 -op 0`                | `~~~~~(Short)~~~~~`                                          |
| `-m "Longer Message" -l 60 -b "{}" -f "=" -ip 3 -op 1` | `================= {   Longer Message   } =================` |

---

## 📌 API Reference

| Argument                  | Description                                       |
| ------------------------- | ------------------------------------------------- |
| `-m` \ `--msg`            | Text for the line                                 |
| `-l` \ `--length`         | Minimum line length                               |
| `-b` \ `--brackets`       | Brackets around the text (`[]`, `()`, `{}`, `<>`) |
| `-f` \ `--fill_char`      | Fill character (`=`, `*`, `-`, `~`)               |
| `-ip` \ `--inner_padding` | Spaces between brackets and text                  |
| `-op` \ `--outer_padding` | Spaces between fill characters and brackets/text  |
| `-r` \ `--result`         | Variable to store the output                      |

---

## 🤖 Generation Note

This document was generated with AI assistance and manually reviewed.
Scripts, comments, and documentation have been verified and adjusted.

---

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)
* 📄 [MIT License](LICENSE)
