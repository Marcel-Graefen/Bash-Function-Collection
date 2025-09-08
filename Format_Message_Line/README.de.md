# 📋 Bash Funktion: Format Message Line

[![Zurück zum Haupt-README](https://img.shields.io/badge/Main-README-blue?style=flat&logo=github)](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/README.de.md)
[![Version](https://img.shields.io/badge/version-0.0.0_beta.01-blue.svg)](#)
[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Eine Bash-Funktion zum **formatieren von Nachrichten in dekorativen Linien** mit Klammern, Füllzeichen, Padding und Mindestlänge.
Die Ausgabe kann direkt über `echo` erfolgen oder in einer Variablen gespeichert werden.

---

## 🚀 Inhaltsverzeichnis

* [📌 Wichtige Hinweise](#-wichtige-hinweise)
* [🛠️ Funktionen & Features](#-funktionen--features)
* [⚙️ Voraussetzungen](#%EF%B8%8F-voraussetzungen)
* [📦 Installation](#-installation)
* [📝 Nutzung](#-nutzung)
  * [🪄 Einfaches Flag](#-einfaches-flag)
  * [📚 Verschiedene Parameter](#-verschiedene-parameter)
  * [💾 Ausgabe in Variablen](#-ausgabe-in-variablen)
  * [📊 Output Beispiele](#-output-beispiele)
* [📌 API-Referenz](#-api-referenz)
* [🤖 Generierungshinweis](#-generierungshinweis)
* [👤 Autor & Kontakt](#-autor--kontakt)

---

## 📌 Wichtige Hinweise

* ⚠️ Alle Ausgaben erfolgen standardmäßig über `echo`, außer die Option `-r|--result` wird angegeben.
* ⚠️ Die Funktion kann beliebig kombiniert werden: Länge, Klammern, Füllzeichen, inneres und äußeres Padding.

---

## 🛠️ Funktionen & Features

* 🎯 Flexible Textformatierung
* 🔢 Einstellbare Mindestlänge
* ↔️ Inneres (`-ip`) und äußeres (`-op`) Padding
* 🔤 Verschiedene Klammern: `[]`, `()`, `{}`, `<>`
* 💾 Ausgabe via `echo` oder Variable (`-r|--result`)
* ⚡ Unterstützt Kombination aller Parameter für komplexe Layouts

---

## ⚙️ Voraussetzungen

* 🐚 Bash Version ≥ 4.3
* Benötigte Funktion: [`parse_case_flags`](https://github.com/Marcel-Graefen/Bash-Function-Collection/blob/main/Parse_Case_Flags/README.de.md)

---

## 📦 Installation

```bash
#!/usr/bin/env bash

source "/pfad/zu/format_message_line.sh"
````

---

## 📝 Nutzung

### 🪄 Einfaches Flag

```bash
format_message_line -m "Hello World"
```

Ausgabe via `echo`:

```
=================[Hello World]=================
```

---

### 📚 Verschiedene Parameter

```bash
format_message_line -m "Hello" -l 30
format_message_line -m "Hello" -b "{}"
format_message_line -m "Hello" -b "<>" -f "-"
format_message_line -m "Hello" -ip 2 -op 3
format_message_line -m "Hello World!" -l 40 -b "[]" -f "*" -ip 1 -op 2
format_message_line -m "Short" -b "()" -f "~" -ip 0 -op 0
format_message_line -m "Longer Message" -l 60 -b "{}" -f "=" -ip 3 -op 1
```

---

### 💾 Ausgabe in Variablen

```bash
format_message_line -m "Hello" -r line1
format_message_line -m "World" -b "{}" -f "*" -ip 2 -op 1 -r line2
format_message_line -m "Bash Fun!" -l 50 -b "()" -f "-" -ip 1 -op 3 -r line3

echo "Line 1: $line1"
echo "Line 2: $line2"
echo "Line 3: $line3"
```

---

### 📊 Output Beispiele

| Aufruf                                                 | Mögliche Ausgabe                                             |
| ------------------------------------------------------ | ------------------------------------------------------------ |
| `-m "Hello"`                                           | `====================[Hello]====================`            |
| `-m "Hello" -l 30`                                     | `========[Hello]========`                                    |
| `-m "Hello" -b "{}"`                                   | `========{Hello}========`                                    |
| `-m "Hello" -b "<>" -f "-"`                            | `--------<Hello>--------`                                    |
| `-m "Hello" -ip 2 -op 3`                               | `===   [  Hello  ]   ===`                                    |
| `-m "Hello World!" -l 40 -b "[]" -f "*" -ip 1 -op 2`   | `********  [ Hello World! ]  ********`                       |
| `-m "Short" -b "()" -f "~" -ip 0 -op 0`                | `~~~~~(Short)~~~~~`                                          |
| `-m "Longer Message" -l 60 -b "{}" -f "=" -ip 3 -op 1` | `================= {   Longer Message   } =================` |

---

## 📌 API-Referenz

| Argument                  | Beschreibung                                       |
| ------------------------- | -------------------------------------------------- |
| `-m` \ `--msg`            | Text für die Zeile                                 |
| `-l` \ `--length`         | Mindestlänge der Zeile                             |
| `-b` \ `--brackets`       | Klammern um den Text (`[]`, `()`, `{}`, `<>`)      |
| `-f` \ `--fill_char`      | Füllzeichen (`=`, `*`, `-`, `~`)                   |
| `-ip` \ `--inner_padding` | Leerzeichen zwischen Klammern und Text             |
| `-op` \ `--outer_padding` | Leerzeichen zwischen Füllzeichen und Klammern/Text |
| `-r ` \ `--result`        | Variable zur Speicherung der Ausgabe               |

---

## 🤖 Generierungshinweis

Dieses Dokument wurde mit KI-Unterstützung erstellt und anschließend manuell überprüft.
Skripte, Kommentare und Dokumentation wurden final geprüft und angepasst.

---

## 👤 Autor & Kontakt

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)
* 📄 [MIT Lizenz](LICENSE)
