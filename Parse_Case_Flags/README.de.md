# 📋 Bash Funktion: Parse Case Flags

[![Zurück zum Haupt-README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/README.de.md)
[![Version](https://img.shields.io/badge/version-0.0.0_beta.02-blue.svg)](#)
[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Eine Bash-Funktion zum **parsen, validieren und zuweisen von Kommandozeilen-Flags innerhalb eines case-Blocks**.
Unterstützt **Einzelwerte, Arrays, Toggle-Flags**, prüft Werte auf Zahlen, Buchstaben oder verbotene Zeichen/Werte und lässt **alle verbleibenden Argumente** nach der Verarbeitung erhalten.

---

## ✨ Neue Features

ℹ️ **Info – Allow Flags**

Mit `--allow` kannst du genau festlegen, welche Zeichen in einem Wert erlaubt sind.
Alle anderen Zeichen führen automatisch zu einem Fehler.


⚠️ Kombinationen wie `a-z` sind **nicht möglich**.
Verwende stattdessen `--letters`, wenn du ganze Buchstabenbereiche zulassen möchtest.


➖ Das Übergeben von `-` oder `-<value>` ist ebenfalls möglich.
Dabei muss das Minuszeichen (`-`) jedoch mit einem Backslash (`\`) escaped werden.
Intern wird das `\` entfernt und der Wert ohne Backslash weitergegeben.

Das ist nützlich um z.b. Parameter intern an andere Funktionen weiter geben zu können.

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
  * [🛡️ Eingabe-Validierung (Allow / Forbid / Forbid-Full)</summary)](#%EF%B8%8F-input-validation-allow--forbid--forbid-full)
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

Perfekt 🚀 — dann erweitere ich deinen **README-Abschnitt** um ein komplettes Beispiel, das **alle drei Flags gleichzeitig** demonstriert.
Das ist sehr praktisch, weil man so direkt sieht, wie man `--allow`, `--forbid` und `--forbid-full` kombiniert.

Hier der fertige Block:

---

## 🛡️ Eingabe-Validierung (Allow / Forbid / Forbid-Full)

Verstanden 👍 – hier die **passende README-Ergänzung** für deine aktuelle Funktion:

---

### ✅ Allow Flags

```bash
parse_case_flags --name myvar --array --allow "azAZ09._" -i "$@" || return 1
```

**Erklärung:**
Mit `--allow` kannst du genau festlegen, welche Zeichen in einem Wert erlaubt sind.
Alle anderen Zeichen führen zu einem Fehler.
Im Beispiel sind nur Buchstaben, Zahlen, Punkte und Unterstriche zulässig.

>️ **Hinweis:** Kombinationen wie `a-z` sind **nicht möglich**.
>
> Verwende stattdessen `--letters`, für ganze Buchstabenbereiche,
>
> oder `--number`, für zahlen.

---

### ❌ Forbid Flags

```bash
parse_case_flags --name myvar --array --forbid "!@#" -i "$@" || return 1
```

**Erklärung:**
Mit `--forbid` kannst du einzelne **verbotene Zeichen** angeben.
Tauchen diese Zeichen im Wert auf, wird ein Fehler geworfen.
Im Beispiel sind die Zeichen `!`, `@` und `#` verboten.

---

### ⛔ Forbid-Full Flags

```bash
forbidden_values=("root" "admin" "error_file")
parse_case_flags --name myvar --array --forbid-full "${forbidden_values[@]}" -i "$@" || return 1
```

**Erklärung:**
Mit `--forbid-full` kannst du **bestimmte ganze Werte** verbieten.
Im Beispiel sind die Strings `root`, `admin` und `error_file` nicht zulässig – wenn ein Parameter exakt so lautet, bricht die Funktion mit einem Fehler ab.

---

### 📊 Vergleich

| Flag            | Zweck                          | Beispiel Fehler                |
| --------------- | ------------------------------ | ------------------------------ |
| `--allow`       | Nur bestimmte Zeichen zulassen | `bad@file` → `@` nicht erlaubt |
| `--forbid`      | Bestimmte Zeichen verbieten    | `bad@file` → `@` verboten      |
| `--forbid-full` | Ganze Werte verbieten          | `error_file` → Wert verboten   |

---

### 🧩 Komplettes Beispiel mit allen Flags

```bash
#!/usr/bin/env bash
source ./parse_case_flags.sh

validate_inputs() {
  local inputs=()

  # Verbotene ganze Werte
  local forbidden_values=("root" "admin" "error_file")

  parse_case_flags -i "$@" \
    --name inputs --array \
    --allow "azAZ09._" \
    --forbid "!@#" \               # Zeichen ! @ # verboten
    --forbid-full "${forbidden_values[@]}" || return 1  # ganze Werte verboten

  echo "Valid inputs: ${inputs[*]}"
}

# Beispielaufruf
validate_inputs "hello_world" "safe.file" "bad@file" "admin"
```

**Erklärung zum Beispiel:**

* `hello_world` ✅ erlaubt
* `safe.file` ✅ erlaubt
* `bad@file` ❌ Fehler, da `@` nicht erlaubt ist (`--forbid`)
* `admin` ❌ Fehler, da kompletter Wert verboten ist (`--forbid-full`)

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
| Erlaubte Zeichen  | `--allow <chars>`       | ✅        | ❌        | String                         |
| Verbotene Werte   | `--forbid-full <value>` | ✅        | ✅        | String                         |
| Ende Parsing      | `-i "$@"`               | ❌        | ❌        | Signal für restliche Argumente |

**Output:**

* Einzelwert oder Array in der Zielvariable
* Toggle auf `true` bei gesetztem Flag
* Validierungsmeldungen bei Fehlern
* Restliche CLI-Argumente bleiben für die Schleife erhalten

---

## 🗂️ Changelog

### Version 0.0.0-Beta.02 – Verbesserungen gegenüber 0.0.1-Beta.01

🆕 **Allow/Forbidden chars validation:**

* Neue Funktion `check_chars()` für Allow- und Forbidden-Zeichenlisten
* Automatische Reduktion von Klammerpaaren `()`, `[]`, `{}` auf öffnende Klammern
* Alle Sonderzeichen korrekt geprüft, keine Regex-Probleme mehr

⚡ **Performance & Robustheit:**

* Character-by-character Prüfung ersetzt problematische Regex-Zeichenklassen
* Stabil bei allen Eingaben, auch bei Kombinationen von Sonderzeichen und Klammern

✨ **Argument improvements:**

* Neuer Parameter `--allow` für erlaubte Zeichen
* Verbesserte Verarbeitung von escaped Eingaben (`\-`) für `forbid_full` und Werte

🧹 **Code Refactoring:**

* Validierung ausgelagert in wiederverwendbare Funktion
* Doppelte Regex-Logik entfernt
* Einheitliche Fehlerausgaben mit erlaubten/verbotenen Zeichen

---

## 🤖 Generierungshinweis

Dieses Dokument wurde mit KI-Unterstützung erstellt und anschließend manuell überprüft.
Skripte, Kommentare und Dokumentation wurden final geprüft und angepasst.

---

## 👤 Autor & Kontakt

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)
* 📄 [MIT Lizenz](LICENSE)
