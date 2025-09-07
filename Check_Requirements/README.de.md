# 📋 Bash Funktion: check_requirements

[![Zurück zum Haupt-README](https://img.shields.io/badge/Main-README-blue?style=flat&logo=github)](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/README.de.md)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](#)
[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Eine Bash-Funktion zum Überprüfen von Skriptanforderungen, wie Bash-Version, erforderliche Funktionen und Programme. Optional können Root-Rechte geprüft werden, und alternative Programme können als Gruppe spezifiziert werden.

---

## 🚀 Inhaltsverzeichnis

* [📌 Wichtige Hinweise](#-wichtige-hinweise)
* [🛠️ Funktionen & Features](#-funktionen--features)
* [⚙️ Voraussetzungen](#%EF%B8%8F-voraussetzungen)
* [📦 Installation](#-installation)
* [📝 Nutzung](#-nutzung)
  * [1️⃣ Prüfen von Bash-Version](#1️⃣-prüfen-von-bash-version)
  * [2️⃣ Prüfen von Funktionen](#2️⃣-prüfen-von-funktionen)
  * [3️⃣ Prüfen von Programmen](#3️⃣-prüfen-von-programmen)
  * [4️⃣ Prüfen von Root-Rechten](#4️⃣-prüfen-von-root-rechten)
  * [5️⃣ Prüfen von alternativen Programmen](#5️⃣-prüfen-von-alternativen-programmen)
  * [6️⃣ Kombinierte Nutzung](#6️⃣-kombinierte-nutzung)
  * [7️⃣ Script Abbruch](#7️⃣-script-abbruch)
* [📌 API-Referenz](#-api-referenz)
* [👤 Autor & Kontakt](#-autor--kontakt)
* [🤖 Generierungshinweis](#-generierungshinweis)
* [📜 Lizenz](#-lizenz)

---

## 🛠️ Funktionen & Features

* 🟢 **Bash-Version prüfen:** Optionale Vorgaben für Major/Minor.
* 🔹 **Funktionen prüfen:** Über `--funcs/-f` können zu prüfende Funktionen angegeben werden.
* 🟣 **Programme prüfen:** Über `--programs/-p` oder Gruppen `--programs-alternative/-a`.
* 🔒 **Root-Rechte prüfen:** Optional via `--root/-r` oder `--sudo/-s`.
* ⚡ **Flexible Fehlerbehandlung:** Mit `--exit/-x` lässt sich steuern, ob das Skript im Fehlerfall sofort mit `exit` beendet oder lediglich mit `return` zurückkehrt.
* 🔍 **Vollständige Prüfung:** Alle angegebenen Anforderungen werden zuerst geprüft; Rückgabe oder Abbruch erfolgt erst nach Abschluss aller Checks.
* 💡 **Return-Werte:** 0 bei Erfolg, 2 bei einem oder mehreren Fehlern.

---

## ⚙️ Voraussetzungen

* 🐚 **Bash** Version 4.0 oder höher.

---

## 📦 Installation

```bash
#!/usr/bin/env bash

source "/pfad/zu/check_requirements.sh"
```

---

## 📝 Nutzung

### 1️⃣ Prüfen von Bash-Version

Prüft, ob die Bash-Version mindestens 4.2 ist.

```bash
check_requirements --major 4 --minor 2
````

---

### 2️⃣ Prüfen von Funktionen

Prüft, ob die Funktionen `normalize_list` und `display_table` definiert sind.

```bash
check_requirements --funcs "normalize_list display_table"
```

---

### 3️⃣ Prüfen von Programmen

Prüft, ob die Programme `awk` und `sed` installiert und verfügbar sind.

```bash
check_requirements --programs "awk sed"
```

---

### 4️⃣ Prüfen von Root-Rechten

Prüft, ob das Script als Root-Benutzer ausgeführt wird.

```bash
check_requirements --root
```

---

### 5️⃣ Prüfen von alternativen Programmen

Mit `--programs-alternative` (`-a`) können mehrere Gruppen von Programmen angegeben werden.
Pro Aufruf entsteht **eine Gruppe** – aus der mindestens **ein Programm vorhanden** sein muss.
Werden mehrere `-a` angegeben, muss **jeweils mindestens eines** aus jeder Gruppe installiert sein.

#### Beispiel

```bash
# Gruppe 1: curl oder wget muss vorhanden sein
# Gruppe 2: tar oder unzip muss vorhanden sein
check_requirements -a "curl wget" -a "tar unzip"
```

***Erklärung:***

* -a "curl wget" → erfüllt, wenn curl ODER wget existiert.
* -a "tar unzip" → erfüllt, wenn tar ODER unzip existiert.
* Beide Bedingungen müssen zutreffen, sonst schlägt die Prüfung fehl.

---

### 6️⃣ Kombinierte Nutzung

Prüft Bash-Version ≥ 4, die Funktion `normalize_list`, das Programm `awk`, mindestens eines der Programme `git` oder `svn` und Root-Rechte gleichzeitig.

```bash
check_requirements --major 4 --funcs "normalize_list" --programs "awk" --programs-alternative "git svn" --root
```
---

### 7️⃣ Script Abbruch

Mit `--exit` (`-x`) kann festgelegt werden, dass das Skript bei einem Fehler **sofort beendet** wird.
Ohne diese Option gibt die Funktion nur einen Fehlercode zurück (`2`), und das Skript kann selbst entscheiden, wie es weitergeht.

#### Beispiel

```bash
# Script bricht sofort ab, falls Anforderungen nicht erfüllt sind
check_requirements -p "git" -x

echo "✅ Diese Zeile wird nur erreicht, wenn git installiert ist."
```

---

## 📌 API-Referenz

| Beschreibung                                                 | Argument / Option                 | Mehrfach möglich | Typ                            |
|---------------------------------------------------------------|----------------------------------|------------------|--------------------------------|
| 🔢 Mindest **Major-Version** von Bash                        | `--major` / `-M`                  | ❌              | Nummer                         |
| 🔢 Mindest **Minor-Version** von Bash (nur mit Major)        | `--minor` / `-m`                  | ❌              | Nummer                         |
| 🧩 Benötigte **Funktionen**                                  | `--funcs` / `-f`                  | ❌              | String (leerzeichengetrennt)   |
| ⚙️ Benötigte **Programme**                                   | `--programs` / `-p`               | ❌              | String (leerzeichengetrennt)   |
| 🔀 Alternative **Programmgruppen** (mind. eins erforderlich) | `--programs-alternative` / `-a`   | ✅              | Strings (leerzeichengetrennt)  |
| 🔑 **Root-Rechte** erforderlich                              | `--root` / `-r` / `--sudo` / `-s` | ❌              | Flag/Aufruf                    |
| ⛔ Sofortiges **Beenden bei Fehlern**                        | `-x` / `--exit`                   | ❌              | Flag/Aufruf                    |


**Rückgabewerte:**

* `0` bei Erfolg
* `2` bei einem oder mehreren Fehlern

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
