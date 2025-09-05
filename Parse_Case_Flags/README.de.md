# 📋 Bash Funktion: parse_case_flags

[![Zurück zum Haupt-README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](../../../README.de.md)
[![Version](https://img.shields.io/badge/version-0.0.0_beta.01-blue.svg)](#)
[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Eine Bash-Funktion zum **parsen, validieren und zuweisen von Kommandozeilen-Flags innerhalb eines case-Blocks**.
Unterstützt **Einzelwerte, Arrays, Toggle-Flags**, prüft Werte auf Zahlen, Buchstaben oder verbotene Zeichen/Werte und lässt **alle verbleibenden Argumente** nach der Verarbeitung erhalten.

---

## 🚀 Inhaltsverzeichnis

* [📌 Wichtige Hinweise](#-wichtige-hinweise)
* [🛠️ Funktionen & Features](#-funktionen--features)
* [⚙️ Voraussetzungen](#%EF%B8%8F-voraussetzungen)
* [📦 Installation](#-installation)
* [📝 Nutzung](#-nutzung)

  * [🪄 Einfaches Flag](#-einfaches-flag)
  * [📚 Array & Multiple Werte](#-array--multiple-werte)
  * [⚡ Toggle Flags](#-toggle-flags)
  * [🔗 Kombinierte Optionen](#-kombinierte-optionen)
* [📌 API-Referenz](#-api-referenz)
* [🤖 Generierungshinweis](#-generierungshinweis)
* [👤 Autor & Kontakt](#-autor--kontakt)

---

## 📌 Wichtige Hinweise

* ⚠️ Alle **Fehler- oder Validierungsausgaben** werden direkt mit `echo` auf **stderr** ausgegeben – es werden keine externen Logging-Funktionen oder Tools genutzt.
* ⚠️ Die Funktion ist gedacht für die Nutzung **in einer while/case-Struktur**.[Weitere 💡Infos](#📝-nutzung)

---

## 🛠️ Funktionen & Features

* 🎯 **Flag Parsing:** Unterstützt einzelne Flags, Arrays und Toggle-Optionen.
* 🔢 **Zahlenvalidierung:** `--number` prüft, dass nur numerische Werte erlaubt sind.
* 🔤 **Buchstabenvalidierung:** `--letters` erlaubt nur alphabetische Zeichen.
* ❌ **Verbotene Zeichen & Werte:** `--forbid` und `--forbid-full` verhindern bestimmte Zeichen oder ganze Werte (inkl. Wildcards `*`).
* 💾 **Variable Zuweisung:** Dynamische Zuweisung an beliebige Variablen per Nameref (`declare -n`).
* 🔄 **Erhalt der restlichen Argumente:** Alle nicht verarbeiteten CLI-Argumente bleiben in `"$@"` erhalten.
* ⚡ **Toggle-Flags:** Flags ohne Wert können auf `true` gesetzt werden.
* 🔗 **Kombinierbare Optionen:** Alle Validierungsoptionen können beliebig kombiniert werden, z. B. `--array --number --forbid-full "root" "admin*"`.

---

## ⚙️ Voraussetzungen

* 🐚 **Bash Version ≥ 4.3** (für `declare -n`)

---

## 📦 Installation

```bash
#!/usr/bin/env bash

source "/pfad/zu/parse_case_flags.sh"
```

---

## 📝 Nutzung

### 🪄 Einfaches Flag

```bash
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      parse_case_flags "$1" name_var --letters "$2" -i "$@" || return 1
      shift 2
      ;;
  esac
done
```

**Erklärung:**
Parst das Flag `--name` und weist den Wert `Alice` der Variablen `name_var` zu. Restliche Argumente bleiben erhalten.

---

### 📚 Array & Multiple Werte

```bash
parse_case_flags --tags tags_array --array Dev Ops QA -i "$@" || return 1
```

**Erklärung:**

* `--array` → sammelt mehrere Werte in einem Array
* Ergebnis: `tags_array=("Dev" "Ops" "QA")`

---

### ⚡ Toggle Flags

```bash
parse_case_flags --verbose verbose_flag --toggle -i "$@" || return 1
```

**Erklärung:**

* Flag ohne Wert → setzt die Variable `verbose_flag` auf `true`.

---

### 🔗 Kombinierte Optionen

```bash
parse_case_flags --ids ids_array --array --number --forbid-full "0" "999" 1 2 3 -i "$@" || return 1
```

**Erklärung:**

* `--array` → sammelt mehrere Werte
* `--number` → erlaubt nur Zahlen
* `--forbid-full "0" "999"` → verbietet bestimmte Werte
* Ergebnis: `ids_array=(1 2 3)`
* Restliche CLI-Argumente bleiben für die Schleife erhalten

---

## 📌 API-Referenz

| Beschreibung      | Argument / Alias        | Optional | Mehrfach | Typ                            |
| ----------------- | ----------------------- | -------- | -------- | ------------------------------ |
| Flag Name         | `<flag>`                | ❌        | ❌        | String                         |
| Zielvariable      | `<target_variable>`     | ❌        | ❌        | String                         |
| Array             | `--array`               | ✅        | ❌        | Flag                           |
| Zahlen            | `--number`              | ✅        | ❌        | Flag                           |
| Buchstaben        | `--letters`             | ✅        | ❌        | Flag                           |
| Toggle            | `--toggle`              | ✅        | ❌        | Flag                           |
| Verbotene Zeichen | `--forbid <chars>`      | ✅        | ❌        | String                         |
| Verbotene Werte   | `--forbid-full <value>` | ✅        | ✅        | String                         |
| Ende Parsing      | `-i "$@"`               | ❌        | ❌        | Signal für restliche Argumente |

**Output:**

* Einzelwert oder Array in der Zielvariable
* Toggle auf `true` bei gesetztem Flag
* Validierungsmeldungen bei Fehlern
* Restliche CLI-Argumente bleiben für die Schleife erhalten

---

## 🤖 Generierungshinweis

Dieses Dokument wurde mit KI-Unterstützung erstellt und anschließend manuell überprüft.
Skripte, Kommentare und Dokumentation wurden final geprüft und angepasst.

---

## 👤 Autor & Kontakt

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)
* 📄 [MIT Lizenz](LICENSE)
