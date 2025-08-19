# 📂 Bash Functions Collection

[![Deutsch](https://img.shields.io/badge/Language-German-blue)](./README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Welcome to the **Bash Functions Collection**!
This repository contains a collection of useful Bash functions that are modular, documented, and ready to integrate into your scripts.

---

## 📌 Quick Summary

* [⚙️ Normalize List](#%EF%B8%8F-normalize-list) – Splits input strings and returns a clean array. [Full Documentation](Normalize%20List/README.md)
* [👤 Author & Contact](#-author--contact)
* [🤖 Generation Note](#-generation-note)
* [📜 License](#-license)

---

## ⚙️ Normalize List

Splits input strings using spaces, commas, pipes, or custom separators and returns a clean array.

**Short Example:**

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

For full documentation and additional options, see [Full Documentation](Normalize%20List/README.md).

---

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)

---

## 🤖 Generation Note

This project was created with the help of Artificial Intelligence (AI). The AI assisted in generating the script, comments, and documentation (README.md). The final result was reviewed and adjusted by me.

---

## 📜 License

[MIT License](LICENSE)
