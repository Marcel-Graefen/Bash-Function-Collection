# 📋 Bash Funktion: Log Call Chain

[![Zurück zum Haupt-README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](../../../README.de.md)
[![Version](https://img.shields.io/badge/version-0.0.0_beta.01-blue.svg)](#)
[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Eine Bash-Funktion zur **vollständigen Aufzeichnung von verschachtelten Funktions- und Skriptaufrufen**.
Erzeugt eine **ASCII-Baumdarstellung** der Call Chain inklusive verkürzter Pfade, Fehler-Logs und optionaler Details. Unterstützt mehrere Log-Dateien und Verzeichnisse sowie Unterdrückung bestimmter Funktionen oder Skripte.

---

## 🚀 Inhaltsverzeichnis

* [🛠️ Funktionen & Features](#🛠️-funktionen--features)
* [⚙️ Voraussetzungen](#⚙️-voraussetzungen)
* [📦 Installation](#📦-installation)
* [📝 Nutzung](#📝-nutzung)

  * [🪄 Einfacher Log](#🪄-einfacher-log)
  * [💡 Detaillierte Logs](#💡-detaillierte-logs)
  * [📛 Fehler & Unterdrückungen](#📛-fehler--unterdrückungen)
* [📌 API-Referenz](#📌-api-referenz)
* [🤖 Generierungshinweis](#🤖-generierungshinweis)
* [👤 Autor & Kontakt](#👤-autor--kontakt)


---

## 🛠️ Funktionen & Features

* 📋 **Hierarchische Aufzeichnung:** Funktions- und Skriptaufrufe werden im Baumformat dargestellt.
* ✨ **Verkürzte Pfade:** Zeigt nur erstes Verzeichnis + ... + Skriptname.
* 💬 **Kurze Nachricht & Details:** `-m/--message` für kurze Beschreibung, `-D/--details` für ausführliche Fehlermeldungen.
* 🗂️ **Flexible Log-Ausgabe:** Mehrere Log-Dateien und -Verzeichnisse werden unterstützt.
* ❌ **Unterdrückungen:** Funktionen oder Skripte können im Call Chain ausgeschlossen werden.
* ⚡ **Fehler-Logging:** Verzeichnisse, die nicht existieren oder nicht beschreibbar sind, werden protokolliert.
* 📝 **Legende:** Vollständige Pfade der Skripte werden am Ende angezeigt, Log-Dateien werden separat gelistet, wenn mehrere existieren.

---

## ⚙️ Voraussetzungen

* 🐚 **Bash Version ≥ 4.3**
* `realpath` Befehl verfügbar

---

## 📦 Installation

```bash
#!/usr/bin/env bash

source "/pfad/zu/log_call_chain.sh"
```

---

## 📝 Nutzung

### 🪄 Einfacher Log

```bash
log_call_chain -s INFO -m "Starting process" -d "/tmp" -f "process.log"
```

**Erklärung:**
Protokolliert die Call Chain mit Status INFO und kurzer Beschreibung.

---

### 💡 Detaillierte Logs

```bash
log_call_chain -s ERROR -m "Failed task" -D "Detailed error description with stack trace" -d "/tmp/logs" -f "error.log"
```

**Erklärung:**
Zusätzlich zur kurzen Nachricht wird eine ausführliche Fehlermeldung (`--details`) im Log ausgegeben.

---

### 📛 Fehler & Unterdrückungen

```bash
log_call_chain -s WARNING -m "Partial run" -x "func_to_skip" -d "/tmp/logs" -f "partial.log"
```

**Erklärung:**
Unterdrückt bestimmte Funktionen (`--suppress`) im Call Chain und protokolliert Warnungen.

---

## 📌 API-Referenz

| Beschreibung           | Argument / Alias             | Optional | Mehrfach | Typ    |
| ---------------------- | ---------------------------- | -------- | -------- | ------ |
| Status                 | `-s` / `--status`            | ❌        | ❌        | String |
| Kurze Nachricht        | `-m` / `--message` / `--msg` | ❌        | ❌        | String |
| Detaillierte Nachricht | `-D` / `--details`           | ✅        | ❌        | String |
| Log-Verzeichnisse      | `-d` / `--dir`               | ✅        | ✅        | String |
| Log-Dateien            | `-f` / `--file`              | ✅        | ✅        | String |
| Unterdrückung          | `-x` / `--suppress`          | ✅        | ✅        | String |

**Output:**

* ASCII-Baum der Funktionsaufrufe
* Optional: `Message` & `Details`
* Legend mit vollständigen Pfaden
* Liste zusätzlicher Log-Dateien, falls mehr als eine

## 🤖 Generierungshinweis

Dieses Dokument wurde mit KI-Unterstützung erstellt und anschließend manuell überprüft.
Skripte, Kommentare und Dokumentation wurden final geprüft und angepasst.

---

## 👤 Autor & Kontakt

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)
* 📄 [MIT Lizenz](LICENSE)
