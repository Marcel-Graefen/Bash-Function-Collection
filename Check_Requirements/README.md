# 📋 Bash Function: check\_requirements

[![Back to Main README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/README.md)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](#)
[![Language](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

A Bash function for checking script requirements such as Bash version, required functions, and installed programs. Optionally, root privileges can be checked, and alternative programs can be specified as groups.

---

## 🚀 Table of Contents

* [📌 Important Notes](#-important-notes)
* [🛠️ Features](#️-features)
* [⚙️ Requirements](#️-requirements)
* [📦 Installation](#-installation)
* [📝 Usage](#-usage)
  * [1️⃣ Check Bash Version](#1️⃣-check-bash-version)
  * [2️⃣ Check Functions](#2️⃣-check-functions)
  * [3️⃣ Check Programs](#3️⃣-check-programs)
  * [4️⃣ Check Root Privileges](#4️⃣-check-root-privileges)
  * [5️⃣ Check Alternative Programs](#5️⃣-check-alternative-programs)
  * [6️⃣ Combined Usage](#6️⃣-combined-usage)
  * [7️⃣ Script Termination](#7️⃣-script-termination)
* [📌 API Reference](#-api-reference)
* [👤 Author & Contact](#-author--contact)
* [🤖 Generation Note](#-generation-note)
* [📜 License](#-license)

---

## 🛠️ Features

* 🟢 **Check Bash version:** Optional constraints for Major/Minor.
* ⚙️ **Check functions:** Use `--funcs/-f` to verify required functions.
* 🟣 **Check programs:** Use `--programs/-p` or groups with `--programs-alternative/-a`.
* 🔒 **Check root privileges:** Optionally via `--root/-r` or `--sudo/-s`.
* ⚡ **Flexible error handling:** With `--exit/-x` you decide whether the script should immediately terminate (`exit`) or just return (`return`) in case of failure.
* 🔍 **Complete validation:** All provided requirements are checked first; only after all checks are completed does return/exit occur.
* 💡 **Return codes:** `0` on success, `2` if one or more checks failed.

---

## ⚙️ Requirements

* 🐚 **Bash** version 4.0 or higher.

---

## 📦 Installation

```bash
#!/usr/bin/env bash

source "/path/to/check_requirements.sh"
```

---

## 📝 Usage

### 1️⃣ Check Bash Version

Checks whether the Bash version is at least 4.2.

```bash
check_requirements --major 4 --minor 2
```

---

### 2️⃣ Check Functions

Checks whether the functions `normalize_list` and `display_table` are defined.

```bash
check_requirements --funcs "normalize_list display_table"
```

---

### 3️⃣ Check Programs

Checks whether the programs `awk` and `sed` are installed and available.

```bash
check_requirements --programs "awk sed"
```

---

### 4️⃣ Check Root Privileges

Checks whether the script is being executed as root.

```bash
check_requirements --root
```

---

### 5️⃣ Check Alternative Programs

With `--programs-alternative` (`-a`), multiple groups of alternative programs can be defined.
Each call to `-a` creates a **group** – at least **one program from that group** must be present.
If multiple groups are defined, **each group** must have at least one installed program.

#### Example

```bash
# Group 1: curl or wget must exist
# Group 2: tar or unzip must exist
check_requirements -a "curl wget" -a "tar unzip"
```

***Explanation:***

* `-a "curl wget"` → valid if either curl OR wget exists.
* `-a "tar unzip"` → valid if either tar OR unzip exists.
* Both conditions must be true, otherwise the check fails.

---

### 6️⃣ Combined Usage

Checks for Bash ≥ 4, function `normalize_list`, program `awk`, at least one of `git` or `svn`, and root privileges.

```bash
check_requirements --major 4 --funcs "normalize_list" --programs "awk" --programs-alternative "git svn" --root
```

---

### 7️⃣ Script Termination

With `--exit` (`-x`), you can enforce that the script **terminates immediately** on error.
Without this option, the function only returns error code `2`, leaving it up to the script to decide what to do.

#### Example

```bash
# Script will immediately exit if git is missing
check_requirements -p "git" -x

echo "✅ This line will only be reached if git is installed."
```

---

## 📌 API Reference

| Description                                               | Argument / Option                 | Multiple Allowed | Type                      |
| --------------------------------------------------------- | --------------------------------- | ---------------- | ------------------------- |
| 🔢 Minimum **Major version** of Bash                      | `--major` / `-M`                  | ❌                | Number                    |
| 🔢 Minimum **Minor version** of Bash (only with Major)    | `--minor` / `-m`                  | ❌                | Number                    |
| 🧩 Required **functions**                                 | `--funcs` / `-f`                  | ❌                | String (space-separated)  |
| ⚙️ Required **programs**                                  | `--programs` / `-p`               | ❌                | String (space-separated)  |
| 🔀 Alternative **program groups** (at least one required) | `--programs-alternative` / `-a`   | ✅                | Strings (space-separated) |
| 🔑 **Root privileges** required                           | `--root` / `-r` / `--sudo` / `-s` | ❌                | Flag/Call                 |
| ⛔ Immediate **exit on error**                            | `-x` / `--exit`                   | ❌                | Flag/Call                 |

**Return codes:**

* `0` on success
* `2` if one or more checks fail

---

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)

---

## 🤖 Generation Note

This project was created with the help of Artificial Intelligence (AI).
The AI assisted in generating the script, comments, and documentation (README.md).
The final result was reviewed and adjusted by me.

---

## 📜 License

[MIT License](LICENSE)
