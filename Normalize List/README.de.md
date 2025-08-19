# 📋 Bash Funktion: normalize_list

[![Zurück zum Haupt-README](https://img.shields.io/badge/Main-README-blue?style=flat&logo=github)](../README.de.md)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](#)
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
  * [Grundlegender Aufruf](#grundlegender-aufruf)
  * [Benutzerdefinierte Separatoren](#benutzerdefinierte-separatoren)
  * [Mehrere Inputs gleichzeitig](#mehrere-inputs-gleichzeitig)
  * [Komplexe Separatoren](#komplexe-separatoren)
* [📌 API-Referenz](#-api-referenz)
* [👤 Autor & Kontakt](#-autor--kontakt)
* [🤖 Generierungshinweis](#-generierungshinweis)
* [📜 Lizenz](#-lizenz)

---

## 📌 Wichtige Hinweise

* ⚠️ **Output nur über `-o|--output`:** Ohne Angabe des Output-Arrays wird kein Ergebnis zurückgegeben.
* ⚠️ **Bash 4.0+ erforderlich:** Die Funktion nutzt Namerefs für Arrays.
* ⚠️ **Trennzeichen:** Standardmäßig Leerzeichen, Pipe `|` und Komma `,`. Zusätzliche Separatoren können über `-s` angegeben werden.

---

## 🛠️ Funktionen & Features

* 🟢 **Flexible Eingabe:** Akzeptiert einen oder mehrere Strings gleichzeitig.
* 🔹 **Benutzerdefinierte Trennzeichen:** Regex-unterstützt, z. B. Leerzeichen, Komma, Pipe oder eigene Zeichen.
* 🟣 **Array-Ausgabe:** Befüllt ein Bash-Array über Nameref (`-o|--output`).
* 🔒 **Robuste Fehlerprüfung:** Warnt bei fehlendem Output-Parameter.
* ⚡ **Einfache Integration:** Kann direkt in Skripte eingebunden werden, keine Abhängigkeiten.
* 💡 **Return-Wert:** 0 bei Erfolg, 2 bei fehlendem Output-Parameter.

---

## ⚙️ Voraussetzungen

* 🐚 **Bash** Version 4.0 oder höher (für Namerefs und Arrays).

---

## 📦 Installation

Binde die Funktion einfach in dein Bash-Skript ein:

```bash
#!/usr/bin/env bash

source "/pfad/zu/normalize_list.sh"
````

---

## 📝 Nutzung

### Grundlegender Aufruf

```bash
declare -a my_array

normalize_list -i "apple orange banana" -o my_array

# Ausgabe prüfen
printf "%s\n" "${my_array[@]}"
```

**Output:**

```
apple
orange
banana
```

---

### Benutzerdefinierte Separatoren

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

### Mehrere Inputs gleichzeitig

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

### Komplexe Separatoren

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

Zerlegt Strings in ein Array anhand von Trennzeichen.

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
* `2` wenn `-o|--output` fehlt

---

## 👤 Autor & Kontakt

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)

---

## 🤖 Generierungshinweis

Dieses Projekt wurde mithilfe einer Künstlichen Intelligenz (KI) entwickelt. Die KI hat bei der Erstellung des Skripts, der Kommentare und der Dokumentation (README.md) geholfen. Das endgültige Ergebnis wurde von mir überprüft und angepasst.

-----

## 📜 Lizenz

[MIT Lizenz](LICENSE)
