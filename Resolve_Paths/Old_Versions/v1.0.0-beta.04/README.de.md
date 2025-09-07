# 📋 Bash Funktion: Resolve Paths

[![Zurück zum Haupt-README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/README.de.md)
[![Version](https://img.shields.io/badge/version-1.0.0_beta.04-blue.svg)](#)
[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Eine Bash-Funktion zum Normalisieren und Auflösen von Dateipfaden, automatische Wildcard-Erweiterung (\*, ?, \*\*) mit **Globstar-Unterstützung**, Klassifizierung nach Existenz und Berechtigungen (r/w/x, rw, rx, wx, rwx) sowie optionales Mapping der Ergebnisse in benannte Arrays.

---

## 🚀 Inhaltsverzeichnis

* [📌 Wichtige Hinweise](#-wichtige-hinweise)
* [🛠️ Funktionen & Features](#-funktionen--features)
* [⚙️ Voraussetzungen](#%EF%B8%8F-voraussetzungen)
* [📦 Installation](#-installation)
* [📝 Nutzung](#-nutzung)

  * <details>
    <summary>▶️ Beispiele</summary>

    * [🗂️ Pfade normalisieren und auflösen](#-pfade-normalisieren-und-auflösen)
    * [⚙️ Benutzerdefinierte Trennzeichen](#%EF%B8%8F-benutzerdefinierte-trennzeichen)
    * [🔍 Pfade klassifizieren](#-pfade-klassifizieren)
    * [📝 Ausgabe in benannte Arrays](#📝-ausgabe-in-benannte-arrays)
    * [✨ Wildcards verwenden](#-wildcards-verwenden)
    * [🔄 Kombination mehrerer Eingaben](#-kombination-von-mehreren-eingaben)
    * [🔑 Nur Schreibbarkeit prüfen](#-prüfen-nur-nach-schreibbarkeit)
    * [📛 Fehlende Dateien ermitteln](#-fehlende-dateien-ermitteln)
    * [▶️ Prüfen auf ausführbare Skripte](#-prüfen-auf-ausführbare-skripte)
    * [🔒 Alle Berechtigungen prüfen](#-alle-berechtigungen-prüfen)

    </details>
* [📌 API-Referenz](#-api-referenz)
* [🗂️ Changelog](#-changelog)
* [👤 Autor & Kontakt](#-autor--kontakt)
* [🤖 Generierungshinweis](#-generierungshinweis)
* [📜 Lizenz](#-lizenz)

---

## 🛠️ Funktionen & Features

* 🗂️ **Eingaben normalisieren:** Trennt Pfade automatisch nach Leerzeichen oder benutzerdefinierten Zeichen.
* 🔹 **Absolute Pfade:** Wandelt relative Pfade in absolute Pfade um (`realpath`).
* ✨ **Automatische Wildcard-Erweiterung:** Unterstützt `*` und `**` (Globstar).
* 🟣 **Existenzprüfung:** Trennt vorhandene von fehlenden Pfaden.
* 🔒 **Berechtigungsprüfung:** Prüft Lesbarkeit (`r`), Schreibbarkeit (`w`) und Ausführbarkeit (`x`) sowie Kombinationen (`rw`, `rx`, `wx`, `rwx`) inklusive Negationen.
* ⚡ **Flexible Ausgabe:** Ergebnisse können in benannte Arrays geschrieben werden.
* ❌ **Eingabeschutz:** `/ **/` als führender Pfad wird abgelehnt.
* ❌ **Separator-Prüfung:** Trennzeichen dürfen `/`, `*` oder `.` nicht enthalten.
* 💡 **Rückgabewerte:** `0` bei Erfolg, `2` bei Fehler.

---

## ⚙️ Voraussetzungen

* 🐚 **Bash** Version 4.3 oder höher
* `normalize_list` Funktion verfügbar
* `realpath` Befehl verfügbar

---

## 📦 Installation

```bash
#!/usr/bin/env bash

source "/pfad/zu/resolve_paths.sh"
```

---

## 📝 Nutzung

### 🗂️ Pfade normalisieren und auflösen

```bash
declare -a alle_pfade

resolve_paths -i "file1.txt file2.txt,/tmp/file3" -o-all alle_pfade
printf "%s\n" "${alle_pfade[@]}"
```

**Erklärung:** Alle Pfade werden absolut aufgelöst, mehrere Eingaben werden getrennt normalisiert und in das Array `alle_pfade` geschrieben. Praktisch, wenn man verschiedene Pfade konsistent weiterverarbeiten möchte.

---

### ⚙️ Benutzerdefinierte Trennzeichen

```bash
declare -a alle_pfade

resolve_paths \
  -i "file1.txt,file2.txt;/tmp/file3|/var/log/syslog" \
  -s ",;|" \
  --out-all alle_pfade

printf "%s\n" "${alle_pfade[@]}"
```

**Erklärung:** Trennzeichen können beliebig angegeben werden; hier werden mehrere Separatoren gleichzeitig genutzt.

>  Standardmäßig trennt die Funktion `normalize_list` Pfade anhand von Leerzeichen (` `), Komma (`,`) und Pipe (`|`). Daher ist die Angabe von -s|--separator meist nicht erforderlich.

> Volgende trennzeichen sind in dieser Funktion NICHT möglich: Punkt (`.`), Slash (`/`) und Sternchen (`*`).

---

### 🔍 Pfade klassifizieren

```bash
declare -a exist missing r not_r w not_w x not_x rw not_rw rx not_rx wx not_wx rwx not_rwx

resolve_paths \
  -i "file1.txt file2.txt /tmp/file3" \
  --out-exist exist --out-missing missing \
  --out-r r --out-not-r not_r \
  --out-w w --out-not-w not_w \
  --out-x x --out-not-x not_x \
  --out-rw rw --out-not-rw not_rw \
  --out-rx rx --out-not-rx not_rx \
  --out-wx wx --out-not-wx not_wx \
  --out-rwx rwx --out-not-rwx not_rwx
```

**Erklärung:** Trennt Pfade nach Existenz und Berechtigungen. So kann man z. B. prüfen, welche Dateien lesbar, schreibbar oder ausführbar sind – oder welche nicht.

---

### 📝 Ausgabe in benannte Arrays

```bash
declare -a ALL EXIST MISSING RW NOT_RW

resolve_paths \
  -i "file1.txt,file2.txt,/tmp/file3" \
  --out-all ALL \
  --out-exist EXIST \
  --out-missing MISSING \
  --out-rw RW \
  --out-not-rw NOT_RW

echo "ALL:     ${ALL[*]}"
echo "EXIST:   ${EXIST[*]}"
echo "MISSING: ${MISSING[*]}"
echo "RW:      ${RW[*]}"
echo "NOT_RW:  ${NOT_RW[*]}"
```

**Erklärung:** Ergebnisse werden in beliebige benannte Arrays geschrieben. Dadurch lassen sich die Ergebnisse gezielt weiterverarbeiten oder filtern.

---

### ✨ Wildcards verwenden

```bash
declare -a ALL EXIST RX NOT_RX

resolve_paths \
  -i "./**/*.sh" \
  --out-all ALL \
  --out-exist EXIST \
  --out-rx RX \
  --out-not-rx NOT_RX

echo "ALL:    ${ALL[*]}"
echo "EXIST:  ${EXIST[*]}"
echo "RX:     ${RX[*]}"
echo "NOT_RX: ${NOT_RX[*]}"
```

**Erklärung:** Unterstützt `*` und `**`. Praktisch, um z. B. alle Dateien eines Typs in Unterverzeichnissen zu erfassen und auf Berechtigungen zu prüfen.

---

### 🔄 Kombination mehrerer Eingaben

```bash
declare -a ALL

resolve_paths -i "file1.txt file2.txt" -i "/tmp/file3 /var/log/syslog" --out-all ALL
echo "${ALL[*]}"
```

**Erklärung:** Mehrere `-i` Parameter können gleichzeitig übergeben werden. Alle Eingaben werden zusammengeführt, normalisiert und in ein Array geschrieben.

---

### 🔑 Prüfen nur nach Schreibbarkeit

```bash
declare -a W WRITEABLE_NOT

resolve_paths -i "/tmp/*" --out-w W --out-not-w WRITEABLE_NOT
echo "Writable: ${W[*]}"
echo "Not writable: ${WRITEABLE_NOT[*]}"
```

**Erklärung:** Praktisch, wenn man nur prüfen möchte, welche Dateien beschreibbar sind. Alle anderen Berechtigungen werden ignoriert.

---

### 📛 Fehlende Dateien ermitteln

```bash
declare -a MISSING

resolve_paths -i "file1.txt file2.txt /nonexistent/file" --out-missing MISSING
echo "Missing files: ${MISSING[*]}"
```

**Erklärung:** Schnell erkennen, welche Pfade noch erstellt oder überprüft werden müssen, z. B. vor Dateioperationen.

---

### ▶️ Prüfen auf ausführbare Skripte

```bash
declare -a RX RX_NOT

resolve_paths -i "/usr/bin/*" --out-rx RX --out-not-rx RX_NOT
echo "Executable: ${RX[*]}"
echo "Not executable: ${RX_NOT[*]}"
```

**Erklärung:** Filtert Kombinationen von Berechtigungen, hier lesbar + ausführbar. Nützlich, um Skripte oder ausführbare Dateien zu identifizieren.

---

### 🔒 Alle Berechtigungen prüfen

```bash
declare -a ALL RWX NOT_RWX

resolve_paths -i "./*" --out-rwx RWX --out-not-rwx NOT_RWX
echo "All rwx: ${RWX[*]}"
echo "Not rwx: ${NOT_RWX[*]}"
```

**Erklärung:** Prüft, welche Dateien vollständige Lese-/Schreib-/Ausführrechte haben und welche nicht. Hilfreich, um Zugriffsrechte konsistent zu prüfen.

---

## 📌 API-Referenz

| Beschreibung                                         | Argument / Alias                                    | Optional | Mehrfach | Typ       |
| ---------------------------------------------------- | --------------------------------------------------- | ------- | -------- | ---------- |
| 🟢📂 Eingabepfade                                   | `-i` / `--input` / `-d` / `--dir` / `-f` / `--file` | ❌      | ✅      | String     |
| 🔹📂 Trennzeichen                                   | `-s` / `--separator`                                | ✅      | ❌      | String     |
| 🟣📂 Alle normalisierten Pfade                      | `--out-all`                                         | ✅      | ❌      | Array-Name |
| 🟣✅ Existierende Pfade                             | `--out-exist`                                       | ✅      | ❌      | Array-Name |
| 🟣❌ Fehlende Pfade                                 | `--out-missing`                                     | ✅      | ❌      | Array-Name |
| 🔒👀 Lesbar                                         | `--out-r`                                           | ✅      | ❌      | Array-Name |
| 🔒🚫 Nicht-lesbar                                   | `--out-not-r`                                       | ✅      | ❌      | Array-Name |
| 🔒✍️ Schreibbar                                     | `--out-w`                                           | ✅      | ❌      | Array-Name |
| 🔒🚫 Nicht-schreibbar                               | `--out-not-w`                                       | ✅      | ❌      | Array-Name |
| 🔒▶️ Ausführbar                                     | `--out-x`                                           | ✅      | ❌      | Array-Name |
| 🔒🚫 Nicht-ausführbar                               | `--out-not-x`                                       | ✅      | ❌      | Array-Name |
| 🔒⚡ Kombinierte Berechtigungen (rw)                | `--out-rw` / `--out-wr`                             | ✅      | ❌      | Array-Name |
| 🔒❌ Negation kombinierter Berechtigungen (rw)      | `--out-not-rw` / `--out-not-wr`                     | ✅      | ❌      | Array-Name |
| 🔒⚡ Kombinierte Berechtigungen (rx)                | `--out-rx` / `--out-xr`                             | ✅      | ❌      | Array-Name |
| 🔒❌ Negation kombinierter Berechtigungen (rx)      | `--out-not-rx` / `--out-not-xr`                     | ✅      | ❌      | Array-Name |
| 🔒⚡ Kombinierte Berechtigungen (wx)                | `--out-wx` / `--out-xw`                             | ✅      | ❌      | Array-Name |
| 🔒❌ Negation kombinierter Berechtigungen (wx)      | `--out-not-wx` / `--out-not-xw`                     | ✅      | ❌      | Array-Name |
| 1️⃣🔒⚡💡 Kombinierte Berechtigungen (rwx)          | `--out-rwx` / `--out-rxw` / `--out-wrx`             | ✅      | ❌      | Array-Name |
| 2️⃣🔒⚡💡 Kombinierte Berechtigungen (rwx)          |  `--out-wxr` / `--out-xrw` / `--out-xwr`            | ✅      | ❌      | Array-Name |
| 1️⃣🔒❌💡 Negation kombinierter Berechtigungen (rwx)| `--out-not-rwx` / `--out-not-rxw` / `--out-not-wrx` | ✅      | ❌      | Array-Name |
| 2️⃣🔒⚡💡 Negation kombinierter Berechtigungen (rwx)| `--out-not-wxr` / `--out-not-xrw` / `--out-not-xwr` | ✅      | ❌      | Array-Name |

**Rückgabewerte:**

* `0` bei Erfolg
* `2` bei Fehler

---

## 🗂️ Changelog

**Version 1.0.0-Beta.04 – Verbesserungen gegenüber 1.0.0-Beta.03**

* 🆕 **Globstar-Unterstützung:** Wildcards `**` jetzt unterstützt
* ❌ **Eingabesicherheit:** `/ **/` am Anfang verboten (Da dies zu lange dauert)
* ❌ **Separator-Prüfung:** `/`, `.` oder `*` im Separator nicht erlaubt
* 📂 **Eingabepfade:** Neue Aliasse, neben den schon vorhandenen: `-i` / `--input` sind jetzt neu: `-d` / `--dir` / `-f` / `--file`
* ⚠️ **Änderung von Argument:** Sämtliche Output Argument haben NICHT mehr den Prefix `-o-` sondern neu `--out-`

---

## 👤 Autor & Kontakt

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)

---

## 🤖 Generierungshinweis

Dieses Projekt wurde mit Unterstützung einer KI entwickelt. Skripte, Kommentare und Dokumentation wurden final von mir geprüft und angepasst.

---

## 📜 Lizenz

[MIT Lizenz](LICENSE)
