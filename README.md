# 📂 Bash Functions Collection

[![Deutsch](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Welcome to the **Bash Functions Collection**!
This repository contains a collection of useful Bash functions that are modular, documented, and can be directly integrated into your scripts.

---

## 📌 Quick Summary

This repository provides modular Bash functions ready to be sourced in scripts.

* [⚙️ Normalize List](#%EF%B8%8F-normalize-list) – Splits input strings into clean arrays based on spaces, commas, pipes, or custom separators. [Full documentation](Normalize%20List/README.md)
* [📋 Display Table](#%EF%B8%8F-display-table) – Displays formatted tables in the terminal, automatically calculates column widths, and centers the header. Supports multiple rows and custom separators. [Full documentation](Display%20Table/README.md)
* [👤 Author & Contact](#-author--contact)
* [🤖 Generation Note](#-generation-note)
* [📜 License](#-license)

---

## ⚙️ Normalize List

Splits input strings based on spaces, commas, pipes, or custom separators and returns a clean array.

**Quick example:**

```bash
declare -a my_array

normalize_list -i "apple orange,banana|kiwi" -o my_array

# Check output
printf "%s\n" "${my_array[@]}"
````

**Output:**

```
apple
orange
banana
kiwi
```

For full documentation and more options, see [Full Documentation](Normalize%20List/README.md).

---

## 📋 Display Table

Displays formatted tables in the terminal, automatically calculates column widths, and centers the header. Supports multiple rows and custom separators.

**Quick example:**

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

For full documentation, see [Full Documentation](Display%20Table/README.md).

---

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)

---

## 🤖 Generation Note

This project was developed with the help of Artificial Intelligence (AI).
The AI assisted in writing the scripts, comments, and documentation (README.md).
The final result was reviewed and adjusted by me.

---

## 📜 License

[MIT License](LICENSE)
