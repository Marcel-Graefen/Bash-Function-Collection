# 📋 Bash Funktion: display_table

[![Zurück zum Haupt-README](https://img.shields.io/badge/Main-README-blue?style=flat&logo=github)](../README.de.md)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](#)
[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Eine flexible Bash-Funktion zum Anzeigen von formatierten Tabellen im Terminal. Sie berechnet Spaltenbreiten automatisch, zentriert den Header und gibt jede Zeile sauber formatiert aus.

---

## 🚀 Inhaltsverzeichnis

* [📌 Wichtige Hinweise](#-wichtige-hinweise)
* [🛠️ Funktionen & Features](#-funktionen--features)
* [⚙️ Voraussetzungen](#%EF%B8%8F-voraussetzungen)
* [📦 Installation](#-installation)
* [📝 Nutzung](#-nutzung)
  * [Grundlegender Aufruf](#grundlegender-aufruf)
  * [Mehrere Zeilen](#mehrere-zeilen)
  * [Benutzerdefinierter Separator](#benutzerdefinierter-separator)
  * [Ausgabe in eine Variable schreiben](#ausgabe-in-eine-variable-schreiben)
* [📌 API-Referenz](#-api-referenz)
* [👤 Autor & Kontakt](#-autor--kontakt)
* [🤖 Generierungshinweis](#-generierungshinweis)
* [📜 Lizenz](#-lizenz)

---

## 📌 Wichtige Hinweise

* ⚠️ **normalize_list erforderlich:** Die Funktion nutzt `normalize_list` intern. Diese muss verfügbar sein.
* ⚠️ **Bash 4.0+ erforderlich:** Für Namerefs und Arrays.
* ⚠️ **Output standardmäßig im Terminal:** Die Funktion druckt direkt in die Standardausgabe.

---

## 🛠️ Funktionen & Features

* 🟢 **Flexible Zeilen & Spalten:** Jede Zeile kann mehrere Spalten enthalten.
* 🔹 **Automatische Spaltenbreiten:** Passt Spaltenbreite an längste Inhalte an.
* 🟣 **Header-Zentrierung:** Optionaler Tabellen-Header wird mittig angezeigt.
* 🔒 **Robuste Fehlerprüfung:** Prüft auf fehlende Funktionen.
* ⚡ **Einfache Integration:** Kann direkt in Bash-Skripte eingebunden werden.
* 💡 **Return-Wert:** 0 bei Erfolg, 2 wenn benötigte Funktionen fehlen.

---

## ⚙️ Voraussetzungen

* 🐚 **Bash** Version 4.0 oder höher (für Namerefs und Arrays).
* ƒ  **Function** Braucht die Funktion [`Normalize List`](../Normalize%20List/README.de.md) v1.0.0

---

## 📦 Installation

Binde die Funktion einfach in dein Bash-Skript ein:

```bash
#!/usr/bin/env bash

source "/pfad/zu/display_table.sh"
source "/pfad/zu/normalize_list.sh"
````

---

## 📝 Nutzung

### Grundlegender Aufruf

```bash
display_table -H "Meine Tabelle" -v "Value1,Value2,Value3"
```

**Output:**

```
+--------+--------+--------+
|       Meine Tabelle      |
+--------+--------+--------+
| Value1 | Value2 | Value3 |
+--------+--------+--------+
```

---

### Mehrere Zeilen

```bash
display_table -H "Meine Tabelle" \
  -v "Value1,Value2,Value3" \
  -v "A,B,C"
```

**Output:**

```
+--------+--------+--------+
|       Meine Tabelle      |
+--------+--------+--------+
| Value1 | Value2 | Value3 |
+--------+--------+--------+
| A      | B      | C      |
+--------+--------+--------+
```

---

### Benutzerdefinierter Separator

```bash
display_table -H "Meine Tabelle" \
  -v "Value1|Value2|Value3" \
  -s "|"
```

**Output:**

```
+--------+--------+--------+
|       Meine Tabelle      |
+--------+--------+--------+
| Value1 | Value2 | Value3 |
+--------+--------+--------+
```

---

### Ausgabe in eine Variable schreiben

```bash
# Speichert die Ausgabe in einer Variable
table_output=$(display_table -H "My Table" -v "Value1,Value2,Value3" -v "A,B,C")

# Nun kann die Variable verwendet werden
echo "$table_output"
```

---

## 📌 API-Referenz

### `display_table`

Zeigt formatierte Tabellen im Terminal an.

**Argumente:**

* `-H|--header` : Optionaler Tabellenheader.
* `-v|--value`  : Zeileninhalt (mehrfach möglich).
* `-s|--separator`: Trennzeichen für Spalten (default: Leerzeichen).

**Return-Werte:**

* `0` bei Erfolg
* `2` wenn benötigte Funktionen fehlen (z. B. `normalize_list`)

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
