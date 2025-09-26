# 📋 Bash-Funktion: Parse Case Flags

[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.de.md)
[![Zurück zum Haupt-README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/README.de.md)
[![Version](https://img.shields.io/badge/version-1.0.0_beta.03-blue.svg)](./README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-≥4.3-green.svg)]()

`parse_case_flags` ist eine Bash-Funktion zum **Parsen, Validieren und Zuweisen von Kommandozeilen-Flags innerhalb eines Case-Blocks**.
Sie unterstützt **Single-Werte, Arrays und Toggle-Flags**, prüft Werte auf Zahlen, Buchstaben, erlaubte/verbotene Zeichen/Werte und lässt **alle nicht verarbeiteten Argumente** erhalten.

---

## 🚀 Inhaltsverzeichnis

* [⚠️ Migrationshinweise](#-migrationshinweise)
* [🛠️ Funktionen & Features](#-funktionen--features)
* [⚙️ Voraussetzungen](#-voraussetzungen)
* [📦 Installation](#-installation)
* [📝 Nutzung](#-nutzung)
  * [💡 Einzelwert](#-einzelwert)
  * [📦 Array & Multiple Werte](#-array--multiple-werte)
  * [⚡ Toggle Flags](#-toggle-flags)
  * [🔗 Kombinierte Optionen](#-kombinierte-optionen)
  * [🛡️ Eingabe-Validierung (Allow / Forbid / Full)](#-eingabe-validierung-allow--forbid--full)
  * [💎 Maskierte führende Bindestriche](#-maskierte-führende-bindestriche)
  * [🚩 Flag-Erkennung in Case-Statements](#-flag-erkennung-in-case-statements)
* [📌 API-Referenz](#-api-referenz)
* [🗂️ Changelog](#-changelog)
* [🤖 Generierungshinweis](#-generierungshinweis)

---

## ⚠️ Migrationshinweise

In Version **1.0.0-beta.03** wurde die **Flag-Erkennung** für Case-Statements verbessert:

```bash
# Alt (beta.03)
parse_case_flags --name "directory" --return dirs --array -i "$@"

# Neu (beta.02)
parse_case_flags --name "directory" --return tmpdir --array -i "$@"
directories+=("${tmpdir[@]}")
shift "${#tmpdir[@]}"
shift 1
```

> Die neue Vorgehensweise nutzt **temporäre Variablen** und `+=`, um **mehrere gleiche Flags** korrekt zu sammeln.

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
* ⚠️ **Shift-Regel für Case**: Flags mit Wert `shift 2`, Toggle `shift 1`

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

* `$2` wird als Single-Wert übergeben
* `--verbose` optional für Fehlerausgaben
* Shift 2 für Flag + Wert

---

### 📦 Array & Multiple Werte (mehrfach gleiche Flags)

```bash
directories=()
files=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--dir|--directory)
      parse_case_flags --name "directories" --return tmpdir --array -i "$@" || return 1
      directories+=("${tmpdir[@]}")
      shift "${#tmpdir[@]}"
      shift 1
      ;;
    -f|--file)
      parse_case_flags --name "files" --return tmpfile --array -i "$@" || return 1
      files+=("${tmpfile[@]}")
      shift "${#tmpfile[@]}"
      shift $1
      ;;
  esac
done

echo "Directories: ${directories[*]}"
echo "Files: ${files[*]}"
```

* **tmpdir / tmpfile** → nur nötig, wenn mehrere gleiche Flags vorkommen
* `+=` → fügt die Werte ans endgültige Array an
* `shift 2` → Flag + Wert entfernen

#### Testaufruf:

```bash
create_folder -d "/etc" -d "/home" -f "file1.txt" -f "file2.txt"
```

#### Erwartete Ausgabe:

```
Directories: /etc /home
Files: file1.txt file2.txt
```

---

### ⚡ Toggle Flags

```bash
-F|--force)
  parse_case_flags -n "force" --toggle || return 1
  shift 1
;;
```

* Toggle setzt Zielvariable automatisch auf `true`
* Nur Single-Werte möglich
* Shift 1, da kein Wert folgt

---

### 🔗 Kombinierte Optionen

```bash
-i|--ids)
  parse_case_flags --name "ids" --return ids_array --array --number --forbid-full "0" "999" --deduplicate --dropping invalid_ids --verbose -i "$@" || return 1

;;
```

* Kombination von Array, Number-Check, Full-Forbid, Deduplication und Dropping

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

---

### 💎 Maskierte führende Bindestriche

```bash
parse_case_flags --name "options" --return opts_array --array -i "\-example" "\-safe" --verbose || return 1
```

* `\-example` → korrekt als `-example` weitergegeben

---

## 🚩 Flag-Erkennung in Case-Statements

* **Mehrfach gleiche Flags** → temporäre Variable + `+=`
* **Sequenzielle Verarbeitung** → `parse_case_flags` erkennt intern Flag-Enden
* **Shift**: Flags mit Wert `shift 2`, Toggle `shift 1`

---

## 📌 API-Referenz

| Beschreibung         | Argument / Alias                         | Optional | Mehrfach | Typ            |
| -------------------- | ---------------------------------------- | -------- | -------- | -------------- |
| Flag Name            | `--name` (`-n`)                          | ❌       | ❌      | String         |
| Zielvariable         | `--return` / `--output` (`-r` / `-o`)    | ❌       | ❌      | String         |
| Array                | `--array` (`-y`)                         | ✅       | ❌      | Flag           |
| Zahlen               | `--number` (`-c`)                        | ✅       | ❌      | Flag           |
| Buchstaben           | `--letters` (`-l`)                       | ✅       | ❌      | Flag           |
| Toggle               | `--toggle` (`-t`)                        | ✅       | ❌      | Flag           |
| Verbotene Zeichen    | `--forbid` (`-f`)                        | ✅       | ❌      | String         |
| Erlaubte Zeichen     | `--allow` (`-a`)                         | ✅       | ❌      | String         |
| Verbotene Werte      | `--forbid-full` (`-F`)                   | ✅       | ✅      | String / Array |
| Erlaubte Werte       | `--allow-full` (`-A`)                    | ✅       | ✅      | String / Array |
| Dropping Array       | `--dropping` (`-d`)                      | ✅       | ❌      | String / Array |
| Deduplicate Array    | `--deduplicate` (`-D`)                   | ✅       | ❌      | Flag           |
| Input Values         | `--input` (`-i`)                         | ❌       | ✅      | String / Array |
| Terminal Output      | `--verbose` (`-v`)                       | ✅       | ❌      | Flag           |
| Muss Value haben     | `--none-zero` (`-nz`)                    | ✅        | ❌     | Flag           |
| Keine Flag-Erkennung | `--no-recognize-flags` (`-nrf`, `-NF\`)  | ✅        | ❌     | Flag           |

> ⚠️ Maskierte führende Bindestriche (`\-`) werden automatisch entfernt.

---

## 🗂️ Changelog

**v1.0.0-beta.03**

* Neue Flag-Erkennung für Case-Statements
* Temporäre Variablen + `+=` für **mehrere gleiche Flags**
* Shift 2 / 1 Regel dokumentiert
* Verbesserte Case-Integration

**v1.0.0-beta.02**

* `--name` und `--return` verpflichtend
* Toggle-Flags auf Single-Werte beschränkt
* Maskierte führende Bindestriche (`\`) hinzugefügt
* Deduplication und Dropping berücksichtigt
* Validierung Allow/Forbid/Full präzisiert

**v1.0.0-beta.01**

* Einzelwerte, Arrays, Toggle
* Validierung auf Zahlen und Buchstaben
* Erlaubte und verbotene Zeichen

---

## 🤖 Generierungshinweis

Dieses Dokument wurde mit KI-Unterstützung erstellt und anschließend manuell überprüft.
Skripte, Kommentare und Dokumentation wurden final geprüft und angepasst.
