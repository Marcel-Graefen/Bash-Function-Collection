# 📋 Bash Funktion: resolve_paths

[![Zurück zum Haupt-README](https://img.shields.io/badge/Main-README-blue?style=flat&logo=github)](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/README.de.md)
[![Version](https://img.shields.io/badge/version-1.0.0_beta.02-blue.svg)](#)
[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Eine Bash-Funktion zum Normalisieren und Auflösen von Dateipfaden, automatische Wildcard-Erweiterung (`*?`), Klassifizierung nach Existenz, Lesbarkeit und Schreibbarkeit sowie optionales Mapping der Ergebnisse in benannte Arrays.

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
  * [5️⃣ Wildcards verwenden](#5️⃣-wildcards-verwenden)
* [📌 API-Referenz](#-api-referenz)
* [🗂️ Changelog](#-changelog)
* [👤 Autor & Kontakt](#-autor--kontakt)
* [🤖 Generierungshinweis](#-generierungshinweis)
* [📜 Lizenz](#-lizenz)

---

## 🛠️ Funktionen & Features

* 🟢 **Eingaben normalisieren:** Unterstützt mehrere Pfade und benutzerdefinierte Trennzeichen.
* 🔹 **Absolute Pfade:** Wandelt relative Pfade in absolute Pfade um (`realpath`).
* 🟣 **Automatische Wildcard-Erweiterung:** Pfade mit `*` oder `?` werden automatisch aufgelöst.
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

Standardmäßige Separatorn sind `Leerzeichen, Pipe | und Komma ,`.

> Somit ist bei nutztung dieser `Separatorn` KEINE angabe von `-s |--seperator` nötig!

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
declare -a ALL EXIST MISSING READABLE NOT_READABLE

resolve_paths \
  -i "file1.txt,file2.txt,/tmp/file3" \
  -o-all ALL \
  -o-exist EXIST \
  -o-missing MISSING \
  -o-read READABLE \
  -o-not-read NOT_READABLE

  echo "ALL:        ${ALL[*]}"
  echo "EXIST:      ${EXIST[*]}"
  echo "MISSING:    ${MISSING[*]}"
  echo "READABLE:   ${READABLE[*]}"
  echo "NOT_READ:   ${NOT_READABLE[*]}"
```

**Ausgabe:**

```
ALL:        /home/user/project/test.sh /home/user/project/build.sh /home/user/project/old.sh
EXIST:      /home/user/project/test.sh /home/user/project/build.sh
MISSING:    /home/user/project/old.sh
READABLE:   /home/user/project/test.sh /home/user/project/build.sh
NOT_READ:   /home/user/project/old.sh
```

---

### 5️⃣ Wildcards verwenden

Eingaben dürfen **Wildcard-Zeichen** enthalten:

* `*` steht für **beliebig viele Zeichen**
* `?` steht für **genau ein Zeichen**

Damit lassen sich zum Beispiel alle `.sh`-Dateien in einem Verzeichnis auflösen:

```bash
declare -a ALL EXIST

resolve_paths \
  -i "./*.sh" \
  -o-all ALL \
  -o-exist EXIST \


echo "ALL:        ${ALL[*]}"
echo "EXIST:      ${EXIST[*]}"
```

**Ausgabe:**

```
ALL:        /home/user/project/test.sh /home/user/project/build.sh /home/user/project/old.sh
EXIST:      /home/user/project/test.sh /home/user/project/build.sh
```

---


## 📌 API-Referenz

| Beschreibung                          | Argument / Option    | Optional | Mehrfach möglich   | Typ                                 |
| ------------------------------------- | -------------------- | -------- | ------------------ | ----------------------------------- |
| 🟢 Eingabepfade                       | `--input` / `-i`     | ❌      | ✅                | String (Leerzeichen/Komma/Pipe/-s)  |
| 🔹 Trennzeichen                       | `--separator` / `-s` | ✅      | ❌                | String (Zeichen)                    |
| 🟣 Alle normalisierten Pfade ausgeben | `-o-all VAR`         | ✅      | ❌                | Array-Name                          |
| 🟣 Existierende Pfade ausgeben        | `-o-exist VAR`       | ✅      | ❌                | Array-Name                          |
| 🟣 Fehlende Pfade ausgeben            | `-o-missing VAR`     | ✅      | ❌                | Array-Name                          |
| 🟣 Lesbare Pfade ausgeben             | `-o-read VAR`        | ✅      | ❌                | Array-Name                          |
| 🟣 Nicht-lesbare Pfade ausgeben       | `-o-not-read VAR`    | ✅      | ❌                | Array-Name                          |
| 🟣 Schreibbare Pfade ausgeben         | `-o-write VAR`       | ✅      | ❌                | Array-Name                          |
| 🟣 Nicht-schreibbare Pfade ausgeben   | `-o-not-write VAR`   | ✅      | ❌                | Array-Name                          |

**Rückgabewerte:**

* `0` bei Erfolg
* `2` bei Fehler

---

## 🗂️ Changelog

**Version 1.0.0-Beta.02 – Verbesserungen gegenüber 1.0.0-Beta.01**

* ❌ **Consistent error output:** Alle Fehlermeldungen verwenden nun das gleiche Icon-Format `❌ ERROR: ...`
* ⚡ **Compact argument parsing:** `case`-Blöcke wurden kompakter geschrieben und Parameter direkt geprüft
* 🟢 **Optimized separator handling:** Separatoren werden jetzt mit `IFS + read -r -a` gesplittet
* 🟣 **Wildcard expansion:** Automatische Expansion von `*` und `?` Pfaden
* ⚡ **-o-all Mapping vor Duplikaten:** Array wird vor Entfernen von Duplikaten geschrieben
* 💡 **Defined return values 0/2:** Erfolg gibt `0` zurück, Fehler immer `2`
* 📝 **Improved readability & structure:** Klarere Kommentare und kompakte Funktionsstruktur, Helper-Funktion `check_value` eingeführt

### Unterschiede zur Beta.01

| Feature / Änderung                    | 01 | 01 |
| ------------------------------------- | -- | -- |
| ❌ Konsistente Fehlerausgabe mit Icon | ✅ |❌ |
| ⚡ Kompaktes Argumenten-Parsing       | ✅ |❌ |
| 🟢 Separator-Verarbeitung optimiert   | ✅ |❌ |
| 🟣 Automatische Wildcard-Erweiterung  | ✅ |❌ |
| ⚡ -o-all Mapping vor Duplikaten      | ✅ |❌ |


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
