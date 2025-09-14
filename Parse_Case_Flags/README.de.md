# 📋 Bash-Funktion: Parse Case flags

[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.md)
[![Zurück zum Haupt-README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.0_beta.04-blue.svg)](./Versions/v1.1.0-beta.01/README.md)

`parse_case_flags` ist eine Bash-Funktion zum **parsen, validieren und zuweisen von Kommandozeilen-Flags innerhalb eines case-Blocks**.
Unterstützt **Single-Werte, Arrays und Toggle-Flags**, prüft Werte auf Zahlen, Buchstaben, erlaubte/verbotene Zeichen/Werte und lässt **alle nicht verarbeiteten Argumente** erhalten.

---

## 🚀 Inhaltsverzeichnis

* [⚠️ Migrationshinweise](#-migrationshinweise)
* [🛠️ Funktionen & Features](#-funktionen--features)
* [⚙️ Voraussetzungen](#%EF%B8%8F-voraussetzungen)
* [📦 Installation](#-installation)
* [📝 Nutzung](#-nutzung)
  * [💡 Einzelwert](#-einzelwert)
  * [📦 Array & Multiple Werte](#-array--multiple-werte)
  * [⚡ Toggle Flags](#-toggle-flags)
  * [🔗 Kombinierte Optionen](#-kombinierte-optionen)
  * [🛡️ Eingabe-Validierung (Allow / Forbid / Full)](#-eingabe-validierung-allow--forbid--full)
  * [💎 Maskierte führende Bindestriche](#-maskierte-führende-bindestriche)
  * [🚩 Flag-Erkennung in Case-Statements](#-flag-erkennung-in-case-statements)
    * [🎯 Mehrere gleiche Flags im Command](#-mehrere-gleiche-flags-im-command)
    * [🔄 Sequenzielle Flag-Verarbeitung](#-sequenzielle-flag-verarbeitung)
    * [✅ Einfache Validation](#-einfache-validation)
* [📌 API-Referenz](#-api-referenz)
* [🗂️ Changelog](#-changelog)
* [🤖 Generierungshinweis](#-generierungshinweis)

---

## ⚠️ Migrationshinweise

In Version **1.0.0-beta.04** wurde die **Flag-Erkennung** für Case-Statements verbessert:

```bash
# Alt (beta.03)
parse_case_flags --name "directory" --return dirs --array -i "$@"

# Neu (beta.04) - mit optionaler Flag-Erkennung
parse_case_flags --name "directory" --return dirs --array --no-recognize-flags -i "$@"
```

> Die Flag-Erkennung ist standardmäßig aktiviert für Abwärtskompatibilität.

---

## 🛠️ Funktionen & Features

* 🎯 **Flag Parsing**: Single-Werte, Arrays, Toggle
* 🔢 **Zahlenvalidierung**: `--number`
* 🔤 **Buchstabenvalidierung**: `--letters`
* ✅ **Erlaubte Zeichen & Werte**: `--allow` / `--allow-full`
* ❌ **Verbotene Zeichen & Werte**: `--forbid` / `--forbid-full`
* 💾 **Variable Zuweisung**: via Nameref (`declare -n`)
* 💾 **Dropping Array**: ungültige Werte optional speichern (`--dropping`)
* 💾 **Deduplicate Array**: Duplikate optional entfernen (`--deduplicate`)
* 🔄 **Restliche Argumente bleiben erhalten**
* ⚡ **Toggle-Flags**: Zielvariable wird auf `true` gesetzt, nur Single-Werte
* 📢 **Verbose**: detaillierte Fehlermeldungen (`--verbose` / `-v`)
* 💡 **Maskierte führende Bindestriche**: `\-value` → korrekt weitergegeben
* 🛑 **None-Zero (`--none-zero` / `-nz`)**: zwingt, dass mindestens ein Wert übergeben wird (0 als Wert ist erlaubt)
* 🚩 **Flag-Erkennung**: Optionale Erkennung von Flags in Array-Modus (`--no-recognize-flags`)

---

## ⚙️ Voraussetzungen

* 🐚 Bash Version ≥ 4.3 (für Nameref `declare -n`)

---

## 📦 Installation

```bash
#!/usr/bin/env bash
source "/pfad/zu/parse_case_flags.sh"
```

---

## 📝 Nutzung

### 💡 Einzelwert

```bash
-v|--value)
  parse_case_flags --name "result" --return output --verbose -i "$2" || return 1
  shift 2
;;
```

* `$2` wird als Single-Wert übergeben.
* `--verbose` optional für Fehlerausgaben.

---

### 📦 Array & Multiple Werte

```bash
-a|--array)
  parse_case_flags --name "tags" --return output --array --deduplicate --dropping invalid_tags --verbose -i "$@" || return 1
  shift $#
;;
```

* `$@` → alle restlichen Argumente
* `--deduplicate` → entfernt Duplikate
* `--dropping` → ungültige Werte landen in `invalid_tags`
* `shift $#` → alle verarbeiteten Argumente entfernen

---

### ⚡ Toggle Flags

```bash
-t|--toggle)
  parse_case_flags --name "enabled_flag" --return output --toggle --verbose || return 1
  shift
;;
```

* Toggle setzt Zielvariable automatisch auf `true`
* Nur Single-Werte möglich

---

### 🔗 Kombinierte Optionen

```bash
-i|--ids)
  parse_case_flags --name "ids" --return ids_array --array --number --forbid-full "0" "999" --deduplicate --dropping invalid_ids --verbose -i "$@" || return 1
  shift $#
;;
```

* Zeigt Kombination von Array, Number-Check, Full-Forbid, Deduplication und Dropping

---

### 🛡️ Eingabe-Validierung (Allow / Forbid / Full)

```bash
parse_case_flags --name "inputs" --return inputs --array \
  --allow "a-zA-Z0-9._" \
  --forbid "!@#" \
  --allow-full "user*" \
  --forbid-full "root" "admin" \
  --dropping invalid_inputs --verbose -i "$@" || return 1

echo "Valid inputs: ${inputs[*]}"
echo "Dropped invalid inputs: ${invalid_inputs[*]}"
```

* Zeichen-Prüfung (`--allow` / `--forbid`)
* Wert-Prüfung (`--allow-full` / `--forbid-full`)
* Wildcards in `allow-full` / `forbid-full` möglich

---

### 💎 Maskierte führende Bindestriche

```bash
parse_case_flags --name "options" --return opts_array --array -i "\-example" "\-safe" --verbose || return 1
```

* `\-example` → wird korrekt als `-example` weitergegeben

---

## 🚩 Flag-Erkennung in Case-Statements

### 🎯 Wofür ist die Flag-Erkennung eigentlich da?

Die **Flag-Erkennung** wurde speziell für die Verwendung in **Case-Statements** entwickelt. Sie sorgt dafür, dass beim Parsen eines Flags nur die dafür bestimmten Werte gesammelt werden und nicht versehentlich Werte von nachfolgenden Flags.

---

### 🎯 Mehrere gleiche Flags im Command

#### 📋 Wann verwenden?
| Use-Case | Empfohlene Einstellung | Beschreibung |
|----------|---------------------|-------------|
| **Mehrere gleiche Flags** | `--no-recognize-flags` | Sammelt ALLE Werte für DIESES Flag im gesamten Command |

#### 💡 Code-Beispiel
```bash
#!/bin/bash

process_arguments() {
    local all_dirs=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--dir)
                # SAMMLE ALLE -d WERTE im gesamten Command
                parse_case_flags --name "directory" --return all_dirs --array --no-recognize-flags -i "$@" || return 1
                echo "📁 ALLE Directory Werte: ${all_dirs[*]}"
                shift $?
                ;;
            *)
                shift
                ;;
        esac
    done
}

# Testaufruf mit mehreren -d Flags
echo "=== Test: Mehrere -d Flags ==="
process_arguments -d /pfad1 -f datei.txt -d /pfad2 -d /pfad3 -u test
```

#### 📊 Erwartete Ausgabe
```
=== Test: Mehrere -d Flags ===
📁 ALLE Directory Werte: /pfad1 /pfad2 /pfad3
```

---

### 🔄 Sequenzielle Flag-Verarbeitung

#### 📋 Wann verwenden?
| Use-Case | Empfohlene Einstellung | Beschreibung |
|----------|---------------------|-------------|
| **Sequenzielle Verarbeitung** | Standard | Stoppt beim nächsten Flag für saubere Trennung |

#### 💡 Code-Beispiel
```bash
#!/bin/bash

process_arguments() {
    local user_data=() dirs=() file=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -u|--user)
                # STOPPT bei nächstem Flag (-d)
                parse_case_flags --name "user" --return user_data --array -i "$@" || return 1
                echo "👤 User: ${user_data[*]}"
                shift $?
                ;;

            -d|--dir)
                # STOPPT bei nächstem Flag (-f)
                parse_case_flags --name "directory" --return dirs --array -i "$@" || return 1
                echo "📁 Directories: ${dirs[*]}"
                shift $?
                ;;

            -f|--file)
                parse_case_flags --name "file" --return file -i "$@" || return 1
                echo "📄 File: $file"
                shift $?
                ;;
        esac
    done
}

# Testaufruf
echo "=== Test: Sequenzielle Verarbeitung ==="
process_arguments -u name alter stadt -d /pfad1 /pfad2 -f datei.txt
```

#### 📊 Erwartete Ausgabe
```
=== Test: Sequenzielle Verarbeitung ===
👤 User: name alter stadt
📁 Directories: /pfad1 /pfad2
📄 File: datei.txt
```

---

### ✅ Einfache Validation

#### 📋 Wann verwenden?
| Use-Case | Empfohlene Einstellung | Beschreibung |
|----------|---------------------|-------------|
| **Einfache Validation** | `--no-recognize-flags` | Prüft nur Zeichen/Werte, ignoriert Flag-Struktur |

#### 💡 Code-Beispiel
```bash
#!/bin/bash

validate_input() {
    local valid_values=() invalid_values=()

    # VALIDIERE nur Zeichen, ignoriere Flag-Struktur
    parse_case_flags --name "input" --return valid_values --array \
        --allow "a-zA-Z0-9" \
        --forbid "!@#$%^&*" \
        --dropping invalid_values \
        --no-recognize-flags \
        -i "$@" || return 1

    echo "✅ Valide Werte: ${valid_values[*]}"
    echo "❌ Ungültige Werte: ${invalid_values[*]}"
}

# Testaufruf
echo "=== Test: Einfache Validation ==="
validate_input gutes_wort "schlechtes@zeichen" another_word "noch@schlimmer"
```

#### 📊 Erwartete Ausgabe
```
=== Test: Einfache Validation ===
✅ Valide Werte: gutes_wort another_word
❌ Ungültige Werte: schlechtes@zeichen noch@schlimmer
```

---

## 📌 API-Referenz

| Beschreibung                | Argument / Alias                              | Optional  | Mehrfach | Typ            |
| --------------------------- | --------------------------------------------- | --------- | -------- | -------------- |
| Flag Name                   | `--name` (`-n`)                               | ❌        | ❌      | String         |
| Zielvariable                | `--return` / `--output` (`-r` / `-o`)         | ❌        | ❌      | String         |
| Array                       | `--array` (`-y`)                              | ✅        | ❌      | Flag           |
| Zahlen                      | `--number` (`-c`)                             | ✅        | ❌      | Flag           |
| Buchstaben                  | `--letters` (`-l`)                            | ✅        | ❌      | Flag           |
| Toggle                      | `--toggle` (`-t`)                             | ✅        | ❌      | Flag           |
| Verbotene Zeichen           | `--forbid` (`-f`)                             | ✅        | ❌      | String         |
| Erlaubte Zeichen            | `--allow` (`-a`)                              | ✅        | ❌      | String         |
| Verbotene Werte             | `--forbid-full` (`-F`)                        | ✅        | ✅      | String / Array |
| Erlaubte Werte              | `--allow-full` (`-A`)                         | ✅        | ✅      | String / Array |
| Dropping Array              | `--dropping` (`-d`)                           | ✅        | ❌      | String / Array |
| Deduplicate Array           | `--deduplicate` (`-D`)                        | ✅        | ❌      | Flag           |
| Input Values                | `--input` (`-i`)                              | ❌        | ✅      | String / Array |
| Terminal Output             | `--verbose` (`-v`)                            | ✅        | ❌      | Flag           |
| Muss Value haben            | `--none-zero` (`-nz`)                         | ✅        | ❌      | Flag           |
| Keine Flag-Erkennung        | `--no-recognize-flags` (`-nrf`, `-NF`)        | ✅        | ❌      | Flag           |

> ⚠️ Maskierte führende Bindestriche (`\-`) werden automatisch entfernt.

---

## 🗂️ Changelog

**v1.0.0-beta.04**

* **Neue Flag-Erkennung**: `--no-recognize-flags` (`-nrf`, `-NF`) hinzugefügt
* **Verbesserte Case-Integration**: Bessere Unterstützung für Case-Statements
* **Rückgabewert-Anpassung**: Gibt Anzahl verbrauchter Argumente zurück für `shift $?`

**v1.0.0-beta.03**

* `--name` und `--return` verpflichtend
* Toggle-Flags auf Single-Werte beschränkt
* Maskierte führende Bindestriche (`\`) hinzugefügt
* Case-Block Beispiele für Single, Array, Toggle und kombiniert
* Deduplication und Dropping berücksichtigt
* Validierung Allow/Forbid/Full präzisiert

**v1.0.0-beta.02**

* Einzelwerte, Arrays, Toggle
* Validierung auf Zahlen und Buchstaben
* Erlaubte und verbotene Zeichen

---

## 🤖 Generierungshinweis

Dieses Dokument wurde mit KI-Unterstützung erstellt und anschließend manuell überprüft.
Skripte, Kommentare und Dokumentation wurden final geprüft und angepasst.
