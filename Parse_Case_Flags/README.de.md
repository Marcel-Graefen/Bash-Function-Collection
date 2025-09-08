# 📋 Bash-Funktion: Parse Case Flags

[![Zurück zum Haupt-README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/README.de.md)
[![Version](https://img.shields.io/badge/version-1.0.0_beta.01-blue.svg)](./Versions/v1.0.0-beta.02/README.de.md)
[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Eine Bash-Funktion zum **parsen, validieren und zuweisen von Kommandozeilen-Flags innerhalb eines case-Blocks**.
Unterstützt **Einzelwerte, Arrays und Toggle-Flags**, prüft Werte auf Zahlen, Buchstaben oder verbotene Zeichen/Werte und lässt **alle verbleibenden Argumente** nach der Verarbeitung erhalten.

---

## 🚀 Inhaltsverzeichnis

* [⚠️ Migrationshinweise](#-migrationshinweise)
* [🛠️ Funktionen & Features](#-funktionen--features)
* [⚙️ Voraussetzungen](#%EF%B8%8F-voraussetzungen)
* [📦 Installation](#-installation)
* [📝 Nutzung](#-nutzung)
  * [🪄 Einfaches Flag](#-einfaches-flag)
  * [📚 Array & Multiple Werte](#-array--multiple-werte)
  * [⚡ Toggle Flags](#-toggle-flags)
  * [🔗 Kombinierte Optionen](#-kombinierte-optionen)
  * [🛡️ Eingabe-Validierung (Allow / Forbid / Forbid-Full)](#-eingabe-validierung-allow--forbid--forbid-full)
    * [✅ Allow Flag](#-allow-flag)
    * [⛔ Forbid Flag](#-forbid-flag)
    * [🚫 Forbid-Full Flag](#-forbid-full-flag)
    * [📊 Vergleich](#-vergleich)
    * [🧩 Komplettes Beispiel mit allen Flags](#-komplettes-beispiel-mit-allen-flags)
* [📌 API-Referenz](#-api-referenz)
* [🗂️ Changelog](#-changelog)
* [🤖 Generierungshinweis](#-generierungshinweis)
* [👤 Autor & Kontakt](#-autor--kontakt)

---

## ⚠️ Migrationshinweise

In Version 1.0.0-beta.01 ist die Funktion **nicht abwärtskompatibel** mit 0.0.0-beta.02.
**Neu erforderlich:** `-n|--name` und `-r|--return|-o|--output`.

### 🔄 Beispiel (Alt → Neu)

```bash
# Alt (0.0.0-beta.02)
parse_case_flags --letters Alice

# Neu (1.0.0-beta.01)
parse_case_flags --name "username" --return user_var --letters -i "$@"
```

> **Erklärung:**
> Du musst nun explizit den **Namen für Fehlermeldungen** (`-n|--name`) und die **Zielvariable für die Rückgabe** (`-r|--return|-o|--output`) angeben.

---

## 🛠️ Funktionen & Features

* 🎯 **Flag Parsing:** Einzelwerte, Arrays und Toggle-Optionen
* 🔢 **Zahlenvalidierung:** `-n|--number` prüft, dass nur numerische Werte erlaubt sind
* 🔤 **Buchstabenvalidierung:** `-l|--letters` erlaubt nur alphabetische Zeichen
* ❌ **Verbotene Zeichen & Werte:** `-f|--forbid` und `-F|--forbid-full` verhindern bestimmte Zeichen oder ganze Werte (inkl. Wildcards `*`)
* 💾 **Variable Zuweisung:** Dynamische Zuweisung an beliebige Variablen per Nameref (`declare -n`)
* 🔄 **Erhalt der restlichen Argumente:** Alle nicht verarbeiteten CLI-Argumente bleiben erhalten
* ⚡ **Toggle-Flags:** Flags ohne Wert können auf `true` gesetzt werden
* 🧩 **Arrayprüfung:** Alle Werte eines Arrays werden geprüft
* 📢 **Verbose-Output:** Bei aktivierter Option (`-v|--verbose`) werden Fehler direkt auf stdout/stderr angezeigt

---

## ⚙️ Voraussetzungen

* 🐚 **Bash Version ≥ 4.3** (für `declare -n` Nameref)

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
      parse_case_flags --name "username" --return user_var --letters -i "$@" || return 1
      shift 2
      ;;
  esac
done
```

**Erklärung:**
Parst das Flag `-n|--name` und weist den Wert `Alice` der Variablen `user_var` zu. Restliche Argumente bleiben erhalten.

---

### 📚 Array & Multiple Werte

```bash
parse_case_flags --name "tags" --return tags_array --array Dev Ops QA -i "$@" || return 1
```

**Erklärung:**

* `-y|--array` → sammelt mehrere Werte in einem Array
* Ergebnis: `tags_array=("Dev" "Ops" "QA")`

---

### ⚡ Toggle Flags

```bash
parse_case_flags --name "verbose_flag" --return verbose_flag --toggle -i "$@" || return 1
```

**Erklärung:**

* Flag ohne Wert → setzt `verbose_flag=true`.

---

### 🔗 Kombinierte Optionen

```bash
parse_case_flags --name "ids" --return ids_array --array --number --forbid-full "0" "999" 1 2 3 -i "$@" || return 1
```

**Erklärung:**

* `y-|--array` → sammelt mehrere Werte
* `-c|--number` → erlaubt nur Zahlen
* `-F|--forbid-full "0" "999"` → verbietet bestimmte Werte
* Ergebnis: `ids_array=(1 2 3)`

---

## 🛡️ Eingabe-Validierung (Allow / Forbid / Forbid-Full)

### ✅ Allow Flag

```bash
parse_case_flags --name "myvar" --return myvar_array --array --allow "azAZ09._" -i "$@" || return 1
```

**Erklärung:**
Nur Buchstaben, Zahlen, Punkte und Unterstriche sind erlaubt.

---

### ⛔ Forbid Flag

```bash
parse_case_flags --name "myvar" --return myvar_array --array --forbid "!@#" -i "$@" || return 1
```

**Erklärung:**
Zeichen `!`, `@` und `#` sind verboten.

---

### 🚫 Forbid-Full Flag

```bash
forbidden_values=("root" "admin" "error_file")
parse_case_flags --name "myvar" --return myvar_array --array --forbid-full "${forbidden_values[@]}" -i "$@" || return 1
```

**Erklärung:**
Strings `root`, `admin` und `error_file` sind verboten.

---

### 📊 Vergleich

| Flag                   | Zweck                          | Beispiel Fehler                |
| ---------------------- | ------------------------------ | ------------------------------ |
| `--allow` \ `-a`       | Nur bestimmte Zeichen zulassen | `bad@file` → `@` nicht erlaubt |
| `--forbid` \ `-f`      | Bestimmte Zeichen verbieten    | `bad@file` → `@` verboten      |
| `--forbid-full` \ `-F` | Ganze Werte verbieten          | `error_file` → Wert verboten   |

#### Erläuterungen:

* Bei `-a|--allow` und `-f|--forbid` wird die Prüfung zeichenweise durchgeführt. Es genügt, dass ein einzelnes der angegebenen Zeichen den Test nicht besteht, um einen Fehler auszulösen.
* Bei `-F|--forbid-full` muss der gesamte Wert mit einem der verbotenen Strings übereinstimmen, damit ein Fehler ausgelöst wird.
* `-F|--forbid-full` kann entweder mehrfach verwendet werden oder ein Array von Werten übergeben bekommen, um mehrere vollständige Werte zu prüfen.

---

### 🧩 Komplettes Beispiel mit allen Flags

```bash
#!/usr/bin/env bash
source ./parse_case_flags.sh

validate_inputs() {
  parse_case_flags --name "inputs" --return inputs --array \
    --allow "azAZ09._" \
    --forbid "!@#" \
    --forbid-full "root" "admin" "error_file" -i "$@" || return 1

  echo "Valid inputs: ${inputs[*]}"
}

validate_inputs "hello_world" "safe.file" "bad@file" "admin"
```

**Erklärung:**

* `hello_world` ✅ erlaubt
* `safe.file` ✅ erlaubt
* `bad@file` ❌ enthält verbotenes Zeichen
* `admin` ❌ kompletter Wert verboten

---


## 📌 API-Referenz

| Beschreibung      | Argument / Alias                      | Optional | Mehrfach | Typ                       |
| ----------------- | ------------------------------------- | -------- | -------- | ------------------------- |
| Flag Name         | `--name` (`-n`)                       | ❌      | ❌       | String                    |
| Zielvariable      | `--return` / `--output` (`-r` / `-o`) | ❌      | ❌       | String                    |
| Array             | `--array` (`-y`)                      | ✅      | ❌       | Flag                      |
| Zahlen            | `--number` (`-c`)                     | ✅      | ❌       | Flag                      |
| Buchstaben        | `--letters` (`-l`)                    | ✅      | ❌       | Flag                      |
| Toggle            | `--toggle` (`-t`)                     | ✅      | ❌       | Flag                      |
| Verbotene Zeichen | `--forbid` (`-f`)                     | ✅      | ❌       | String                    |
| Erlaubte Zeichen  | `--allow` (`-a`)                      | ✅      | ❌       | String                    |
| Verbotene Werte   | `--forbid-full` (`-F`)                | ✅      | ✅       | String / Array            |
| Dropping Array    | `--dropping` (`-d`)                   | ✅      | ❌       | Array                     |
| Deduplicate Array | `--deduplicate` / `--dedub` (`-D`)    | ✅      | ❌       | Array (nur bei `--array`) |
| Ende Parsing      | `--input` (`-i`)                      | ❌      | ❌       | Restliche Argumente       |

### Hinweise zur Nutzung der Flags

* `--name` (`-n`) – Name des Flags für Fehlermeldungen oder Validierungen. **Pflicht ab Version 1.0.0-beta.01**
* `--return` (`-r` / `-o` / `--output`) – Zielvariable, in die der Wert oder das Array geschrieben wird. **Pflicht ab Version 1.0.0-beta.01**
* `--array` (`-y`) – Sammelt mehrere Werte in einem Array
* `--number` (`-n`) – Nur numerische Werte erlaubt
* `--letters` (`-l`) – Nur alphabetische Werte erlaubt
* `--toggle` (`-t`) – Flag ohne Wert; Zielvariable wird auf `true` gesetzt
* `--forbid` (`-f`) – Verbotene einzelne Zeichen
* `--allow` (`-a`) – Erlaubte einzelne Zeichen
* `--forbid-full` (`-F`) – Verbotene ganze Werte (Strings); mehrfach verwendbar oder als Array
* `--dropping` (`-d`) – Speichert ungültige Werte in einem Array
* `--deduplicate` / `--dedub` (`-D`) – Entfernt Duplikate aus Arrays; optionales separates Array
* `--input` (`-i`) – Ende der Optionsliste; alle verbleibenden CLI-Argumente werden an die Funktion übergeben

---

## 🗂️ Changelog

* ⚡ **Pflichtoptionen:** `-n|--name` und `-r|--return|-o|--output` müssen jetzt angegeben werden, da sonst kein Ziel für die Werte existiert.
* 🧩 **Arrayprüfung:** Alle Werte eines Arrays werden einzeln validiert (Zahlen, Buchstaben, Allow/Forbid/Forbid-Full).
* 💾 **Dropping:** Ungültige Werte können optional über `-d|--dropping` in einem Array gespeichert werden.
* ♻️ **Deduplicate:** Duplikate in Arrays können optional über `-D|--dedub|--deduplicate` entfernt und in einem separaten Array gespeichert werden.
* 🛠️ **Code Refactoring:** Vereinfachte Argumentverarbeitung, sauberere Nameref-Logik.
* ✅ **Validierung verbessert:** Zahl- und Buchstaben-Checks, Allow/Forbid/Forbid-Full funktionieren konsistent für Einzelwerte und Arrays.
* ⚡ **Verbose:** Optionales `-v|--verbose` zeigt detaillierte Fehlermeldungen für ungültige Werte an.

---

## 🤖 Generierungshinweis

Dieses Dokument wurde mit KI-Unterstützung erstellt und anschließend manuell überprüft.
Skripte, Kommentare und Dokumentation wurden final geprüft und angepasst.

---

## 👤 Autor & Kontakt

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)
* 📄 [MIT Lizenz](LICENSE)
