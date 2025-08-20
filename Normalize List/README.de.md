# 📋 Bash Funktion: normalize_list

[![Zurück zum Haupt-README](https://img.shields.io/badge/Main-README-blue?style=flat&logo=github)](../README.de.md)
[![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)](#)
[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Eine flexible Bash-Funktion zum Normalisieren von Eingabe-Strings in Arrays. Sie zerlegt Strings anhand von Leerzeichen, Kommas, Pipes oder benutzerdefinierten Trennzeichen und gibt ein sauberes Array zurück.

---

## 🚀 Inhaltsverzeichnis

* [📌 Wichtige Hinweise](#-wichtige-hinweise)
* [🛠️ Funktionen & Features](#-funktionen--features)
* [⚙️ Voraussetzungen](#%EF%B8%8F-voraussetzungen)
* [📦 Installation](#-installation)
* [📝 Nutzung](#-nutzung)
  * [1️⃣ Grundlegender Aufruf](#1️⃣-grundlegender-aufruf)
  * [2️⃣ Benutzerdefinierte Separatoren](#2️⃣-benutzerdefinierte-separatoren)
  * [3️⃣ Mehrere Inputs gleichzeitig](#3️⃣-mehrere-inputs-gleichzeitig)
  * [4️⃣ Komplexe Separatoren](#4️⃣-komplexe-separatoren)
* [📌 API-Referenz](#-api-referenz)
* [🗂️ Changelog](#-changelog)
* [👤 Autor & Kontakt](#-autor--kontakt)
* [🤖 Generierungshinweis](#-generierungshinweis)
* [📜 Lizenz](#-lizenz)

---

## 📌 Wichtige Hinweise

* ⚠️ **Output nur über `-o|--output`:** Ohne Angabe des Output-Arrays wird kein Ergebnis zurückgegeben.
* ⚠️ **Bash 4.0+ erforderlich:** Die Funktion nutzt Namerefs für Arrays.
* ⚠️ **Fehlerhandling:** Alle Fehler liefern konsistent `echo "❌ ERROR: ..."` und `return 2`.
* ⚠️ **Trennzeichen:** Standardmäßig Leerzeichen, Pipe `|` und Komma `,`. Zusätzliche Separatoren können über `-s` angegeben werden.

---

## 🛠️ Funktionen & Features

* 🟢 **Flexible Eingabe:** Akzeptiert einen oder mehrere Strings gleichzeitig.
* 🔹 **Benutzerdefinierte Trennzeichen:** Regex-ähnlich, z. B. Leerzeichen, Komma, Pipe oder eigene Zeichen.
* 🟣 **Array-Ausgabe:** Befüllt ein Bash-Array über Nameref (`-o|--output`).
* 🔒 **Robustes Fehlerhandling:** Fehlende Parameter werden erkannt und gemeldet.
* ⚡ **Einfache Integration:** Kann direkt in Skripte eingebunden werden, keine externen Abhängigkeiten.
* 💡 **Return-Wert:** 0 bei Erfolg, 2 bei Fehlern.

---

## ⚙️ Voraussetzungen

* 🐚 **Bash** Version 4.0 oder höher (für Namerefs und Arrays).

---

## 📦 Installation

Binde die Funktion einfach in dein Bash-Skript ein:

```bash
#!/usr/bin/env bash

source "/pfad/zu/normalize_list.sh"
```

---

## 📝 Nutzung

### 1️⃣ Grundlegender Aufruf

```bash
declare -a my_array

normalize_list -i "apple orange banana" -o my_array

printf "%s\n" "${my_array[@]}"
```

**Output:**

```
apple
orange
banana
```

---

### 2️⃣ Benutzerdefinierte Separatoren

```bash
declare -a fruits

normalize_list -i "apple,orange,banana" -s "," -o fruits

printf "%s\n" "${fruits[@]}"
```

**Output:**

```
apple
orange
banana
```

---

### 3️⃣ Mehrere Inputs gleichzeitig

```bash
declare -a items

normalize_list -i "apple orange" -i "banana|kiwi" -o items

printf "%s\n" "${items[@]}"
```

**Output:**

```
apple
orange
banana
kiwi
```

---

### 4️⃣ Komplexe Separatoren

```bash
declare -a values

normalize_list -i "val1|val2;val3 val4" -s "|; " -o values

printf "%s\n" "${values[@]}"
```

**Output:**

```
val1
val2
val3
val4
```

---

## 📌 API-Referenz

### `normalize_list`

Zerlegt Strings in ein Array anhand von Trennzeichen. Fehler werden als `echo "❌ ERROR: ..."` ausgegeben und liefern `return 2`.

**Argumente:**

* `-i|--input` : Eingabe-String (mehrfach möglich).
* `-o|--output`: Name des Arrays, das befüllt wird (**erforderlich!**).
* `-s|--separator`: Zusätzliche Zeichen als Separator (optional).

**Beispiel:**

```bash
declare -a arr
normalize_list -i "foo bar,baz|qux" -s "|," -o arr
echo "${arr[@]}"
# Output: foo bar baz qux
```

**Return-Werte:**

* `0` bei Erfolg
* `2` bei fehlendem Output-Parameter oder anderen Fehlern

---

## 🗂️ Changelog

**Version 1.1.0 – Verbesserungen gegenüber 1.0.0**

- ❌ **Consistent error output**: Alle Fehlermeldungen verwenden nun das gleiche Icon-Format `❌ ERROR: ...`
- ⚡ **Compact argument parsing**: `case`-Blöcke wurden kompakter geschrieben und Parameter direkt geprüft
- 🟢 **Optimized separator handling**: Separatoren werden jetzt mit `IFS + read -r -a` gesplittet, statt verschachtelte Schleifen
- 💡 **Defined return values 0/2**: Erfolg gibt `0` zurück, Fehler immer `2`
- 📝 **Improved readability & structure**: Klarere Kommentare und kompakte Funktionsstruktur, Helper-Funktion `check_value` eingeführt

> Alle anderen Features wie Mehrfachinputs oder der optionale Separator `-s` waren bereits in 1.0.0 vorhanden und sind unverändert.

### Unterschiede zur Version 1.0.0

| Feature / Änderung                     | 1.1.0 | 1.0.0 |
|---------------------------------------|-------|-------|
| ❌ Konsistente Fehlerausgabe mit Icon |  ✅  |  ❌  |
| ⚡ Kompaktes Argumenten-Parsing       |  ✅  |  ❌  |
| 🟢 Separator-Verarbeitung optimiert   |  ✅  |  ❌  |
| 💡 Klar definierte Return-Werte 0/2   |  ✅  |  ❌  |
| 📝 Lesbarkeit & Struktur verbessert   |  ✅  |  ❌  |

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
