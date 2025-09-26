# 📋 Bash-Funktion: Parse Case Flags

[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.md)
[![Zurück zum Haupt-README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/README.de.md)
[![Version](https://img.shields.io/badge/version-1.0.0_beta.04-blue.svg)](./Versions/README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-≥4.3-green.svg)]()

`parse_case_flags` ist eine Bash-Funktion zum **Parsen, Validieren und Zuweisen von Kommandozeilen-Flags innerhalb eines Case-Blocks**.
Sie unterstützt **Single-Werte, Arrays und Toggle-Flags**, prüft Werte auf Zahlen, Buchstaben, erlaubte/verbotene Zeichen/Werte und gibt **automatisch restliche Parameter** zurück.

---

## 🚀 Inhaltsverzeichnis

* [🆕 Neu in Version 1.1.0](#-neu-in-version-100-beta04)
* [🛠️ Funktionen & Features](#-funktionen--features)
* [⚙️ Voraussetzungen](#-voraussetzungen)
* [📦 Installation](#-installation)
* [📝 Nutzung](#-nutzung)
  * [💡 Einzelwert](#-einzelwert)
  * [📦 Array & Multiple Werte](#-array--multiple-werte)
  * [⚡ Toggle Flags](#-toggle-flags)
  * [🔗 Kombinierte Optionen](#-kombinierte-optionen)
  * [🛡️ Eingabe-Validierung (Allow / Forbid / Full)](#-eingabe-validierung-allow--forbid--full)
    * [Zeichen-basierte Validierung](#zeichen-basierte-validierung---allow---forbid)
    * [Wert-basierte Validierung](#wert-basierte-validierung---allow-full---forbid-full)
    * [Vergleichstabelle](#vergleichstabelle)
    * [Kombinierte Anwendung](#kombinierte-anwendung)
  * [💎 Maskierte führende Bindestriche](#-maskierte-führende-bindestriche)
  * [🔄 Automatische Parameter-Weiterleitung](#-automatische-parameter-weiterleitung)
* [📌 API-Referenz](#-api-referenz)
* [🗂️ Changelog](#-changelog)
* [🤖 Generierungshinweis](#-generierungshinweis)

---

## 🆕 Neu in Version 1.0.0-beta.04

### 🔄 Automatische Parameter-Weiterleitung
Neue Option `--rest-params` (`-R`) gibt **automatisch nicht verarbeitete Parameter** zurück:

```bash
-d|--directory)
  local rest_params
  parse_case_flags --name "directory" --return dir --array --rest-params rest_params -i "$@" || return 1
  set -- "${rest_params[@]}"
  ;;
```

**Vorteile:**
- ✅ **Kein manuelles Shiften** mehr nötig
- ✅ **Automatische Weiterleitung** an nächsten Case
- ✅ **Funktioniert für Single und Array** gleichermaßen
- ✅ **Einfachere Code-Struktur**

### 🎯 Vereinfachte Case-Logik
**Vorher (komplex):**
```bash
-d|--directory)
  parse_case_flags --name "directory" --return tmpdir --array -i "$@" || return 1
  directories+=("${tmpdir[@]}")
  shift "${#tmpdir[@]}"
  shift 1
  ;;
```

**Nachher (einfach):**
```bash
-d|--directory)
  local rest_params
  parse_case_flags --name "directory" --return directories --array --rest-params rest_params -i "$@" || return 1
  set -- "${rest_params[@]}"
  ;;
```

### 🔧 Weitere Verbesserungen
- **Deduplication Input**: `--dedub-input` (`-DI`) für externe Deduplizierungs-Werte
- **Verbesserte Fehlerbehandlung**: Konsistente Rückgabecodes
- **Optimierte Performance**: Effizientere Parameter-Verarbeitung

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
* 🔄 **Automatische Parameter-Weiterleitung**: `--rest-params`
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
  local rest_params
  parse_case_flags --name "result" --return output --verbose --rest-params rest_params -i "$@" || return 1
  set -- "${rest_params[@]}"
  ;;
```

* Verarbeitet einen einzelnen Wert
* `--verbose` optional für Fehlerausgaben
* Restliche Parameter werden automatisch weitergeleitet

---

### 📦 Array & Multiple Werte

```bash
-d|--directory)
  local rest_params
  parse_case_flags --name "directories" --return directories --array --rest-params rest_params -i "$@" || return 1
  set -- "${rest_params[@]}"
  ;;
```

* **Kein temporäres Array** mehr nötig
* **Kein manuelles Shiften**
* **Automatische Weiterleitung** an nächsten Case

#### Testaufruf:

```bash
script.sh -d "/etc" "/home" -f "file1.txt" -v "value"
```

#### Verarbeitung:
- `-d` verarbeitet `/etc` und `/home`
- Restliche Parameter (`-f "file1.txt" -v "value"`) werden automatisch weitergeleitet

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
  local rest_params
  parse_case_flags --name "ids" --return ids_array --array --number --forbid-full "0" "999" --deduplicate --dropping invalid_ids --rest-params rest_params --verbose -i "$@" || return 1
  set -- "${rest_params[@]}"
  ;;
```

* Kombination von Array, Number-Check, Full-Forbid, Deduplication und Dropping
* Automatische Parameter-Weiterleitung

---

## 🛡️ Eingabe-Validierung (Allow / Forbid / Full)

### 🔤 Zeichen-basierte Validierung (`--allow` / `--forbid`)
**Prüft einzelne Zeichen** innerhalb der Werte:

```bash
# Nur diese Zeichen erlauben
parse_case_flags --allow "a-zA-Z0-9._-" --return username

# Diese Zeichen verbieten
parse_case_flags --forbid "!@#$%^&*()" --return filename
```

**Beispiele:**
- `--allow "abc"` → erlaubt: "cab", "abc", "a" | verbietet: "abcd", "x"
- `--forbid "123"` → verbietet: "a1b", "123", "2" | erlaubt: "abc", "xyz"

### 🔍 Wert-basierte Validierung (`--allow-full` / `--forbid-full`)
**Prüft komplette Werte** (unterstützt Wildcards `*`):

```bash
# Nur bestimmte Werte erlauben
parse_case_flags --allow-full "admin" "user*" "guest" --return role

# Bestimmte Werte verbieten
parse_case_flags --forbid-full "root" "test*" "temp" --return username
```

**Beispiele:**
- `--allow-full "admin" "user*"` → erlaubt: "admin", "user1", "user_john" | verbietet: "guest", "admin2"
- `--forbid-full "test*" "temp"` → verbietet: "test", "test123", "temp" | erlaubt: "prod", "live"

### 📊 Vergleichstabelle

| Feature | `--allow` / `--forbid` | `--allow-full` / `--forbid-full` |
|---------|------------------------|----------------------------------|
| **Prüfebene** | Einzelne Zeichen | Komplette Werte |
| **Wildcards** | ❌ Nein | ✅ Ja (`*` unterstützt) |
| **Use-Case** | Zeichen-Whitelist/Blacklist | Wert-Whitelist/Blacklist |
| **Beispiel** | `--allow "a-z0-9"` | `--allow-full "user*" "admin"` |
| **Performance** | Schneller (Zeichen-Check) | Langsamer (String-Vergleich) |

### 💡 Kombinierte Anwendung
Beide Methoden können kombiniert werden:

```bash
local rest_params
parse_case_flags --name "inputs" --return inputs --array \
  --allow "a-zA-Z0-9"        # Nur alphanumerische Zeichen \
  --forbid-full "admin" "root"  # Aber nicht diese spezifischen Werte \
  --rest-params rest_params \
  --verbose -i "$@" || return 1

set -- "${rest_params[@]}"
echo "Valid inputs: ${inputs[*]}"
```

**Ergebnis:** "user123" ✅ erlaubt, "admin" ❌ verboten, "us$r" ❌ verbotene Zeichen

**Zusammenfassung:**
- **`--allow`/`--forbid`** = Zeichen-Check ("darf diese Zeichen enthalten/nicht enthalten")
- **`--allow-full`/`--forbid-full`** = Wert-Check ("muss dieser Wert sein/darf nicht dieser Wert sein")

---

### 💎 Maskierte führende Bindestriche

```bash
local rest_params
parse_case_flags --name "options" --return opts_array --array --rest-params rest_params -i "\-example" "\-safe" --verbose || return 1
set -- "${rest_params[@]}"
```

* `\-example` → korrekt als `-example` weitergegeben

---

## 🔄 Automatische Parameter-Weiterleitung

Die neue `--rest-params` Option macht die Case-Logik **viel einfacher**:

```bash
while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--directory)
      local rest_params
      parse_case_flags --name "directory" --return directories --array --rest-params rest_params -i "$@" || return 1
      set -- "${rest_params[@]}"
      ;;

    -f|--file)
      local rest_params
      parse_case_flags --name "files" --return files --array --rest-params rest_params -i "$@" || return 1
      set -- "${rest_params[@]}"
      ;;

    *)
      echo "Unknown option: $1"
      shift
      ;;
  esac
done
```

**Vorteile:**
- ✅ **Weniger Code** in jedem Case
- ✅ **Keine Shift-Berechnungen** mehr nötig
- ✅ **Robuster** gegen Parameter-Änderungen
- ✅ **Bessere Lesbarkeit**

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
| Deduplicate Input    | `--dedub-input` (`-DI`)                  | ✅       | ✅      | String / Array |
| Rest-Parameter       | `--rest-params` (`-R`)                   | ✅       | ❌      | String / Array |
| Input Values         | `--input` (`-i`)                         | ❌       | ✅      | String / Array |
| Terminal Output      | `--verbose` (`-v`)                       | ✅       | ❌      | Flag           |
| Muss Value haben     | `--none-zero` (`-nz`)                    | ✅       | ❌      | Flag           |
| Keine Flag-Erkennung | `--no-recognize-flags` (`-nrf`, `-NF`)   | ✅       | ❌      | Flag           |

> ⚠️ Maskierte führende Bindestriche (`\-`) werden automatisch entfernt.

---

## 🗂️ Changelog

**v1.0.0-beta.04** - *Aktuelle Version*
* ✅ **Neue `--rest-params` Option** für automatische Parameter-Weiterleitung
* ✅ **Vereinfachte Case-Logik** - kein manuelles Shiften mehr nötig
* ✅ **Deduplication Input** (`--dedub-input`) für externe Werte
* ✅ **Verbesserte Fehlerbehandlung** und Konsistenz

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

---

## 🤖 Generierungshinweis

Dieses Dokument wurde mit KI-Unterstützung erstellt und anschließend manuell überprüft.
Skripte, Kommentare und Dokumentation wurden final geprüft und angepasst.
