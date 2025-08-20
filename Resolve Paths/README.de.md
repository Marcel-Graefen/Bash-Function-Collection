# 📋 Bash Funktion: resolve_paths

[![Zurück zum Haupt-README](https://img.shields.io/badge/Main-README-blue?style=flat&logo=github)](../README.de.md)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](#)
[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Eine Bash-Funktion zum Normalisieren und Auflösen von Dateipfaden, Klassifizieren nach Existenz, Lesbarkeit und Schreibbarkeit sowie optionales Mapping der Ergebnisse in benannte Arrays.

---

## 🚀 Inhaltsverzeichnis

* [📌 Wichtige Hinweise](#-wichtige-hinweise)
* [🛠️ Funktionen & Features](#-funktionen--features)
* [⚙️ Voraussetzungen](#-voraussetzungen)
* [📦 Installation](#-installation)
* [📝 Nutzung](#-nutzung)
  * [1️⃣ Pfade normalisieren und auflösen](#1️⃣-pfade-normalisieren-und-auflösen)
  * [2️⃣ Benutzerdefinierte Trennzeichen](#2️⃣-benutzerdefinierte-trennzeichen)
  * [3️⃣ Ausgabe in benannte Arrays](#3️⃣-ausgabe-in-benannte-arrays)
  * [4️⃣ Pfade klassifizieren](#4️⃣-pfade-klassifizieren)
* [📌 API-Referenz](#-api-referenz)
* [👤 Autor & Kontakt](#-autor--kontakt)
* [🤖 Generierungshinweis](#-generierungshinweis)
* [📜 Lizenz](#-lizenz)

---

## 🛠️ Funktionen & Features

* 🟢 **Eingaben normalisieren:** Unterstützt mehrere Pfade und benutzerdefinierte Trennzeichen.
* 🔹 **Absolute Pfade:** Wandelt relative Pfade in absolute Pfade um (`realpath`).
* 🟣 **Existenzprüfung:** Trennt vorhandene von fehlenden Pfaden.
* 🔒 **Lesbar/Schreibbar prüfen:** Trennt lesbare/schreibbare und nicht-lesbare/nicht-schreibbare Pfade.
* ⚡ **Flexible Ausgabe:** Ergebnisse können in ein oder mehrere benannte Arrays geschrieben werden.
* 💡 **Rückgabewerte:** `0` bei Erfolg, `2` bei Fehler (z. B. fehlende Eingabe, unbekannte Option).

---

## ⚙️ Voraussetzungen

* 🐚 **Bash** Version 4.0 oder höher
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

### 1️⃣ Pfade normalisieren und auflösen

Normalisiert die Eingabepfade, teilt sie korrekt auf und wandelt sie in absolute Pfade um.

```bash
declare -a alle_pfade

# Beispiel 1: Alle Pfade in einer Eingabe
resolve_paths -i "file1.txt file2.txt,/tmp/file3" -o-all alle_pfade

# Beispiel 2: Mehrere Eingaben
resolve_paths -i "file1.txt file2.txt" -i "/tmp/file3" -o-all alle_pfade

# Ausgabe prüfen
printf "%s\n" "${alle_pfade[@]}"
```

**Erklärung:**

* Trennzeichen wie Leerzeichen, Komma oder Pipe werden automatisch erkannt.
* Alle Pfade werden in absolute Pfade umgewandelt.
* Ergebnis wird in das Array `alle_pfade` geschrieben.

---

### 2️⃣ Benutzerdefinierte Trennzeichen

Mit `-s` / `--separator` können eigene Zeichen als Trenner für die Eingaben angegeben werden.
Im Beispiel werden Komma, Semikolon und Pipe als Trennzeichen verwendet:

> Standardmäßige Separatorn sind `Leerzeichen, Pipe | und Komma ,`

```bash
declare -a alle_pfade

resolve_paths \
  -i "file1.txt,file2.txt;/tmp/file3|/var/log/syslog" \
  -s ";" \
  -o-all alle_pfade

# Ausgabe prüfen
printf "%s\n" "${alle_pfade[@]}"
````

**Beispiel-Ausgabe:**

```
file1.txt
file2.txt
/tmp/file3
/var/log/syslog
```

**Erklärung:**

* Die Eingabe enthält Pfade, die durch Komma `,`, Semikolon `;` oder Pipe `|` getrennt sind.
* `-s ",;|"` teilt die Eingabe an allen angegebenen Zeichen auf.
* Das Ergebnis wird in das Array `alle_pfade` geschrieben.

---

### 3️⃣ Pfade klassifizieren

Klassifiziert die aufgelösten Pfade nach Existenz, Lesbarkeit und Schreibbarkeit:

```bash
declare -a exist missing readable not_readable writable not_writable

resolve_paths \
  -i "file1.txt file2.txt /tmp/file3" \
  -o-exist exist \
  -o-missing missing \
  -o-read readable \
  -o-not-read not_readable \
  -o-write writable \
  -o-not-write not_writable
```

---

### 4️⃣ Ausgabe in benannte Arrays

Beliebige Kombination interner Arrays kann in eigene benannte Arrays geschrieben werden:

```bash
declare -a alle_dateien vorhandene_dateien

resolve_paths \
  -i "file1.txt,file2.txt,/tmp/file3" \
  -o-all alle_dateien \
  -o-exist vorhandene_dateien
```

---

## 📌 API-Referenz

| Beschreibung                          | Argument / Option    | Mehrfach möglich | Typ                                 |
| ------------------------------------- | -------------------- | ---------------- | ----------------------------------- |
| 🟢 Eingabepfade                       | `--input` / `-i`     | ✅                | String (Leerzeichen/Komma getrennt) |
| 🔹 Trennzeichen                       | `--separator` / `-s` | ❌                | String (Zeichen)                    |
| 🟣 Alle normalisierten Pfade ausgeben | `-o-all VAR`         | ❌                | Array-Name                          |
| 🟣 Existierende Pfade ausgeben        | `-o-exist VAR`       | ❌                | Array-Name                          |
| 🟣 Fehlende Pfade ausgeben            | `-o-missing VAR`     | ❌                | Array-Name                          |
| 🟣 Lesbare Pfade ausgeben             | `-o-read VAR`        | ❌                | Array-Name                          |
| 🟣 Nicht-lesbare Pfade ausgeben       | `-o-not-read VAR`    | ❌                | Array-Name                          |
| 🟣 Schreibbare Pfade ausgeben         | `-o-write VAR`       | ❌                | Array-Name                          |
| 🟣 Nicht-schreibbare Pfade ausgeben   | `-o-not-write VAR`   | ❌                | Array-Name                          |

**Rückgabewerte:**

* `0` bei Erfolg
* `2` bei Fehler

---

## 👤 Autor & Kontakt

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)

---

## 🤖 Generierungshinweis

Dieses Projekt wurde mithilfe einer Künstlichen Intelligenz (KI) entwickelt. Die KI hat bei der Erstellung des Skripts, der Kommentare und der Dokumentation (README.md) geholfen. Das endgültige Ergebnis wurde von mir überprüft und angepasst.

---

## 📜 Lizenz

[MIT Lizenz](LICENSE)
