# 📋 Bash Function: Log Call Chain

[![Back to Main README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/README.md)
[![Version](https://img.shields.io/badge/version-0.0.0_beta.01-blue.svg)](#)
[![German](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

A Bash function for **completely logging nested function and script calls**.
Generates an **ASCII tree** of the call chain including shortened paths, error logs, and optional details. Supports multiple log files and directories, as well as suppression of specific functions or scripts.

---

## 🚀 Table of Contents

* [🛠️ Functions & Features](#-functions--features)
* [⚙️ Requirements](#-requirements)
* [📦 Installation](#-installation)
* [📝 Usage](#-usage)

  * [🪄 Simple Log](#-simple-log)
  * [💡 Detailed Logs](#-detailed-logs)
  * [📛 Errors & Suppressions](#-errors--suppressions)
* [📌 API Reference](#-api-reference)
* [🤖 Generation Note](#-generation-note)
* [👤 Author & Contact](#-author--contact)

---

## 🛠️ Functions & Features

* 📋 **Hierarchical Logging:** Function and script calls are displayed in a tree format.
* ✨ **Shortened Paths:** Shows only the first folder + ... + script name.
* 💬 **Message & Details:** `-m/--message` for a short description, `-D/--details` for detailed error messages.
* 🗂️ **Flexible Log Output:** Supports multiple log files and directories.
* ❌ **Suppressions:** Certain functions or scripts can be excluded from the call chain.
* ⚡ **Error Logging:** Logs directories that do not exist or are not writable.
* 📝 **Legend:** Full paths of scripts are shown at the end; log files are listed separately if more than one exists.

---

## ⚙️ Requirements

* 🐚 **Bash Version ≥ 4.3**
* `realpath` command available

---

## 📦 Installation

```bash
#!/usr/bin/env bash

source "/path/to/log_call_chain.sh"
```

---

## 📝 Usage

### 🪄 Simple Log

```bash
log_call_chain -s INFO -m "Starting process" -d "/tmp" -f "process.log"
```

**Explanation:**
Logs the call chain with status INFO and a short description.

---

### 💡 Detailed Logs

```bash
log_call_chain -s ERROR -m "Failed task" -D "Detailed error description with stack trace" -d "/tmp/logs" -f "error.log"
```

**Explanation:**
In addition to the short message, a detailed error description (`--details`) is included in the log.

---

### 📛 Errors & Suppressions

```bash
log_call_chain -s WARNING -m "Partial run" -x "func_to_skip" -d "/tmp/logs" -f "partial.log"
```

**Explanation:**
Suppresses certain functions (`--suppress`) in the call chain and logs warnings.

---

## 📌 API Reference

| Description        | Argument / Alias             | Optional | Multiple | Type   |
| ------------------ | ---------------------------- | -------- | -------- | ------ |
| Status             | `-s` / `--status`            | ❌        | ❌        | String |
| Short Message      | `-m` / `--message` / `--msg` | ❌        | ❌        | String |
| Detailed Message   | `-D` / `--details`           | ✅        | ❌        | String |
| Log Directories    | `-d` / `--dir`               | ✅        | ✅        | String |
| Log Files          | `-f` / `--file`              | ✅        | ✅        | String |
| Suppress Functions | `-x` / `--suppress`          | ✅        | ✅        | String |

**Output:**

* ASCII tree of function calls
* Optional: `Message` & `Details`
* Legend with full script paths
* List of other log files if more than one exists

---

## 🤖 Generation Note

This document was generated with AI assistance and manually reviewed.
Scripts, comments, and documentation were final-checked and adapted.

---

## 👤 Author & Contact

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)
* 📄 [MIT License](LICENSE)
