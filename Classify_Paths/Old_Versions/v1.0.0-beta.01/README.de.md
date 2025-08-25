# 📋 Bash Funktion: Classify Paths

[![Zurück zum Haupt-README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](../../../README.de.md)
[![Version](https://img.shields.io/badge/version-0.0.1_beta.01-blue.svg)](#)
[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Eine Bash-Funktion zum Klassifizieren von Dateipfaden nach **Existenz** und **Berechtigungen** (r/w/x, rw, rx, wx, rwx), inklusive **Wildcard-Erweiterung** (`*`, `**`), Duplikaterkennung und optionalem Mapping der Ergebnisse in benannte Arrays.

---

## 🚀 Inhaltsverzeichnis

* [📌 Wichtige Hinweise](#📌-wichtige-hinweise)
* [🛠️ Funktionen & Features](#🛠️-funktionen--features)
* [⚙️ Voraussetzungen](#⚙️-voraussetzungen)
* [📦 Installation](#📦-installation)
* [📝 Nutzung](#📝-nutzung)

  * [🔍 Pfade klassifizieren](#🔍-pfade-klassifizieren)
  * [✨ Wildcards verwenden](#✨-wildcards-verwenden)
  * [🔑 Berechtigungen prüfen](#🔑-berechtigungen-prüfen)
  * [📛 Fehlende Dateien ermitteln](#📛-fehlende-dateien-ermitteln)
* [📌 API-Referenz](#📌-api-referenz)
* [🗂️ Changelog](#🗂️-changelog)
* [👤 Autor & Kontakt](#👤-autor--kontakt)
* [🤖 Generierungshinweis](#🤖-generierungshinweis)
* [📜 Lizenz](#📜-lizenz)

---

## 🛠️ Funktionen & Features

* 🗂️ **Eingaben normalisieren:** Unterstützt mehrere `-i`/`--input`, `-d`/`--dir` und `-f`/`--file` Parameter.
* ✨ **Wildcard-Erweiterung:** `*` und `**` werden automatisch aufgelöst.
* 🔹 **Absolute Pfade:** Pfade werden via `realpath -m` normalisiert.
* 🟣 **Existenzprüfung:** Trennt vorhandene Pfade von fehlenden.
* 🔒 **Berechtigungsprüfung:** Prüft Lese (`r`), Schreib (`w`) und Ausführrechte (`x`) sowie Kombinationen (`rw`, `rx`, `wx`, `rwx`) inkl. Negationen.
* ⚡ **Flexible Ausgabe:** Ergebnisse werden in benannte Arrays geschrieben.
* ❌ **Eingabeschutz:** Führendes `/**/` wird abgelehnt.
* ❌ **Separator-Prüfung:** `/`, `*` oder `.` als Separator nicht erlaubt.
* 💡 **Rückgabewerte:** `0` bei Erfolg, `1` bei Fehler.

---

## ⚙️ Voraussetzungen

* 🐚 **Bash** Version 4.3 oder höher
* `normalize_list` Funktion verfügbar
* `realpath` Befehl verfügbar

---

## 📦 Installation

```bash
#!/usr/bin/env bash

source "/pfad/zu/classify_paths.sh"
```

---

## 📝 Nutzung

### 🔍 Pfade klassifizieren

```bash
declare -A Hallo

classify_paths -i "/tmp/file1 /tmp/file2" -o Hallo -p "r w x rwx"
echo "All files: ${Hallo[all]}"
echo "Existing files: ${Hallo[file]}"
echo "Directories: ${Hallo[dir]}"
echo "Missing: ${Hallo[missing]}"
```

**Erklärung:** Trennt Pfade nach Existenz und Typ. Filtert zusätzlich nach Berechtigungen, wenn Masken (`-p`) angegeben werden.

---

### ✨ Wildcards verwenden

```bash
declare -A Hallo

classify_paths -i "/tmp/**/*.sh" -o Hallo -p "rx"
echo "Executable scripts: ${Hallo[rx]}"
echo "Not executable: ${Hallo[not-rx]}"
```

**Erklärung:** Unterstützt `*` und `**`. Praktisch, um alle Dateien eines Typs in Unterverzeichnissen zu erfassen und zu prüfen.

---

### 🔑 Berechtigungen prüfen

```bash
declare -A Hallo

classify_paths -i "/tmp/file*" -o Hallo -p "r w x rw rx wx rwx"
echo "Readable: ${Hallo[r]}"
echo "Writable: ${Hallo[w]}"
echo "Executable: ${Hallo[x]}"
echo "RWX files: ${Hallo[rwx]}"
```

**Erklärung:** Prüft jede angegebene Maske auf die Dateien und trennt auch die negativen Varianten (`not-r`, `not-rw`, etc.).

---

### 📛 Fehlende Dateien ermitteln

```bash
declare -A Hallo

classify_paths -i "/tmp/file1 /tmp/file2 /nonexistent/file" -o Hallo
echo "Missing files: ${Hallo[missing]}"
```

**Erklärung:** Ermittelt alle Pfade, die nicht existieren.

---

## 📌 API-Referenz

| Beschreibung          | Argument / Alias                                    | Optional | Mehrfach | Typ                    |
| --------------------- | --------------------------------------------------- | -------- | -------- | ---------------------- |
| Eingabepfade          | `-i` / `--input` / `-d` / `--dir` / `-f` / `--file` | ❌        | ✅        | String                 |
| Alle Pfade            | `-o` / `--output`                                   | ❌        | ❌        | Associative Array Name |
| Berechtigungen prüfen | `-p` / `--perm`                                     | ✅        | ✅        | String                 |

**Output Keys im Array:**

* `all` – alle Pfade
* `file` – existierende Dateien
* `dir` – existierende Verzeichnisse
* `missing` – nicht vorhandene Pfade
* `r, w, x, rw, rx, wx, rwx` – Pfade passend zu Berechtigung
* `not-r, not-w, not-x, not-rw, not-rx, not-wx, not-rwx` – Pfade, die Berechtigungen **nicht** erfüllen

---

## 🗂️ Changelog

**Version 1.0.0-Beta.01**

* 🆕 Erstveröffentlichung der Funktion `classify_paths`
* 🔹 Klassifiziert Pfade nach Existenz, Typ und Berechtigungen
* ✨ Wildcard-Erweiterung (`*`, `**`) implementiert
* 💡 Unterstützung für multiple Eingaben und multiple Permission-Masken

---

## 👤 Autor & Kontakt

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)

---

## 🤖 Generierungshinweis

Dieses Projekt wurde mit KI-Unterstützung dokumentiert. Skripte, Kommentare und Dokumentation wurden final von mir geprüft und angepasst.

---

## 📜 Lizenz

[MIT Lizenz](LICENSE)
