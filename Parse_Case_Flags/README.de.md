# 📋 Bash-Funktion: Parse Case flags

[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.md)
[![Zurück zum Haupt-README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/README.de.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.0_beta.03-blue.svg)](./Versions/v1.0.0-beta.03/README.md)

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
* [📌 API-Referenz](#-api-referenz)
* [🗂️ Changelog](#-changelog)
* [🤖 Generierungshinweis](#-generierungshinweis)

---

## ⚠️ Migrationshinweise

In Version **1.0.0-beta.03** sind `--name` (`-n`) und `--return` (`-r` / `-o`) verpflichtend.
Ohne diese Parameter kann die Funktion keine Fehlermeldungen oder Rückgabewerte korrekt handhaben.

```bash
# Alt (beta.02)
parse_case_flags --letters Alice

# Neu (beta.03)
parse_case_flags --name "username" --return user_var --letters -i "$@"
```

> `--name` dient zur Fehlermeldung, `--return` zur Rückgabe.

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
* 📢 **Verbose**: detaillierte Fehlermeldungen (`--verbose`)
* 💡 **Maskierte führende Bindestriche**: `\-value` → korrekt weitergegeben

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

## 📌 API-Referenz

| Beschreibung      | Argument / Alias                      | Optional  | Mehrfach | Typ            |
| ----------------- | ------------------------------------- | --------- | -------- | -------------- |
| Flag Name         | `--name` (`-n`)                       | ❌        | ❌      | String         |
| Zielvariable      | `--return` / `--output` (`-r` / `-o`) | ❌        | ❌      | String         |
| Array             | `--array` (`-y`)                      | ✅        | ❌      | Flag           |
| Zahlen            | `--number` (`-c`)                     | ✅        | ❌      | Flag           |
| Buchstaben        | `--letters` (`-l`)                    | ✅        | ❌      | Flag           |
| Toggle            | `--toggle` (`-t`)                     | ✅        | ❌      | Flag           |
| Verbotene Zeichen | `--forbid` (`-f`)                     | ✅        | ❌      | String         |
| Erlaubte Zeichen  | `--allow` (`-a`)                      | ✅        | ❌      | String         |
| Verbotene Werte   | `--forbid-full` (`-F`)                | ✅        | ✅      | String / Array |
| Erlaubte Werte    | `--allow-full` (`-A`)                 | ✅        | ✅      | String / Array |
| Dropping Array    | `--dropping` (`-d`)                   | ✅        | ❌      | String / Array |
| Deduplicate Array | `--deduplicate` (`-D`)                | ✅        | ❌      | Flag           |
| Input Values      |  `--input` (`-i`)                     | ❌        | ✅      | String / Array |
| Terminal Output   |  `--verbose` (`-v`)                   | ✅        | ❌      | Flag           |

> ⚠️ Maskierte führende Bindestriche (`\-`) werden automatisch entfernt.

---

## 🗂️ Changelog

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
