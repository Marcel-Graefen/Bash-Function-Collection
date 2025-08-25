# 📋 Bash Funktion: Classify Paths

[![Zurück zum Haupt-README](https://img.shields.io/badge/Main-README-blue?style=flat\&logo=github)](../README.de.md)
[![Version](https://img.shields.io/badge/version-0.0.1_beta.02-blue.svg)](#)
[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Eine Bash-Funktion zum Klassifizieren von Dateipfaden nach **Existenz** und **Berechtigungen** (r/w/x, rw, rx, wx, rwx), inklusive **Wildcard-Erweiterung** (`*`, `**`), Duplikaterkennung und optionalem Mapping der Ergebnisse in benannte Arrays.

---

## ✨ Neue Features – `classify_paths()`

* 🔑 **Flexible Berechtigungsprüfung:** Teilmasken (`r`, `w`, `x`, `rw`, `rx`, `wx`, `rwx`) + Negation (`-` / `not`), nicht angegebene Rechte werden ignoriert. Alle Perm-Keys inkl. `not` initialisiert.
* ⚡ **Separator-Option:** Unterstützt `| ! $ & ' ( ) * ; < > ? [ ] ^ { } ~` + Leerzeichen / kein Separator (`false/off/no/not`). Ungültige Werte → Warnung + Standard `|`.
* ✨ **Wildcard-Erweiterung:** `*` und `**` werden aufgelöst, Dotfiles korrekt, fehlende Pfade landen in `missing`.
* 🗂️ **Handling von Pfaden mit Leerzeichen:** Separatoren korrekt eingefügt, Arrays sauber konvertierbar.
* 🔄 **Duplikaterkennung:** Doppelte Pfade zuverlässig entfernt; existierende vs. fehlende Pfade getrennt.
* ⚠️ **Logging & Warnungen:** Hinweise bei ungültigen Masken, Separatoren oder führendem `/**/`.
* 📝 **Output-Keys vollständig initialisiert:** Alle Typen (`file`, `dir`) + Masken (`mask`, `mask,not`) vorbereitet.
* 🔄 **Rückwärtskompatibel:** Alte Aufrufe funktionieren weiterhin; neue Features optional nutzbar.

---

Wenn du willst, kann ich daraus noch **eine kleine Tabelle mit Icon + Feature + Kurzbeschreibung** bauen, die noch übersichtlicher wirkt. Willst du, dass ich das mache?


---

## 🚀 Inhaltsverzeichnis

* [📌 Wichtige Hinweise](#📌-wichtige-hinweise)
* [🛠️ Funktionen & Features](#🛠️-funktionen--features)
* [⚙️ Voraussetzungen](#⚙️-voraussetzungen)
* [📦 Installation](#📦-installation)
* [📝 Nutzung](#📝-nutzung)

  * <details>
    <summary>▶️ Beispiele</summary>

    * [🔍 Pfade klassifizieren](#🔍-pfade-klassifizieren)
    * [✨ Wildcards verwenden](#✨-wildcards-verwenden)
    * [🔑 Berechtigungen prüfen](#🔑-berechtigungen-prüfen)

      * [🛡️ Berechtigungslogik](#🛡️-berechtigungslogik)
    * [📛 Fehlende Dateien ermitteln](#📛-fehlende-dateien-ermitteln)
    * [📝 Output](#📝-output)
      * [📊 Alle verfügbaren Output-Optionen](#📊-alle-verfügbaren-output-optionen)

    </details>
* [📌 API-Referenz](#📌-api-referenz)
* [🗂️ Changelog](#🗂️-changelog)
* [🤖 Generierungshinweis](#🤖-generierungshinweis)
* [👤 Autor & Kontakt](#👤-autor--kontakt)

---

## 🛠️ Funktionen & Features

* 🗂️ **Eingaben normalisieren:** Unterstützt mehrere `-i`/`--input`, `-d`/`--dir` und `-f`/`--file` Parameter.
* ✨ **Wildcard-Erweiterung:** `*` und `**` werden automatisch aufgelöst.
* 🔹 **Absolute Pfade:** Pfade werden via `realpath -m` normalisiert.
* 🟣 **Existenzprüfung:** Trennt vorhandene Pfade von fehlenden.
* 🔒 **Berechtigungsprüfung:** Prüft Lese (`r`), Schreib (`w`) und Ausführrechte (`x`) sowie Kombinationen (`rw`, `rx`, `wx`, `rwx`) inkl. Negationen.
* ⚡ **Flexible Ausgabe:** Ergebnisse werden in benannte Arrays geschrieben.
* ❌ **Eingabeschutz:** Führendes `/**/` wird abgelehnt.
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

**Erklärung:**
Trennt Pfade nach **Existenz** und **Typ**. Filtert zusätzlich nach Berechtigungen, wenn Masken (`-p`) angegeben werden.

---

### ✨ Wildcards verwenden

```bash
declare -A Hallo

classify_paths -i "/tmp/**/*.sh" -o Hallo -p "rx"
echo "Executable scripts: ${Hallo[rx]}"
echo "Not executable: ${Hallo[not-rx]}"
```

**Erklärung:**
Unterstützt `*` und `**`. Praktisch, um alle Dateien eines Typs in Unterverzeichnissen zu erfassen und zu prüfen.

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

**Erklärung:**
Prüft jede angegebene Maske auf die Dateien und trennt auch die negativen Varianten (`not-r`, `not-rw`, etc.).

---

### 🛡️ Berechtigungslogik

* `xrw` → **Alle Rechte** werden geprüft.
* `rw` → **Nur `r` und `w`** werden geprüft, andere Rechte werden ignoriert.
* `r-x` →

  * `r` → **muss gesetzt sein**
  * `w` → **darf nicht gesetzt sein** (negierte Prüfung: `-(w)`)
  * `x` → **darf gesetzt sein**, wird aber nicht zwingend geprüft

**Legende:**

| Symbol            | Bedeutung                                   |
| ----------------- | ------------------------------------------- |
| `r`               | Leserecht                                   |
| `w`               | Schreibrecht                                |
| `x`               | Ausführungsrecht                            |
| `-`               | Negation: Recht darf **nicht** gesetzt sein |
| (nicht angegeben) | Wird nicht geprüft                          |

---

### 📛 Fehlende Dateien ermitteln

```bash
declare -A Hallo

classify_paths -i "/tmp/file1 /tmp/file2 /nonexistent/file" -o Hallo
echo "Missing files: ${Hallo[missing]}"
```

**Erklärung:**
Ermittelt alle Pfade, die nicht existieren.

---

### 📝 Output

#### Hinweis zum Output:

Der Output erfolgt als String. Standardmäßig werden die einzelnen Einträge durch den Separator `|` getrennt. Über das entsprechende Argument lässt sich der Separator jedoch ändern oder komplett deaktivieren. Weitere Informationen siehe: [Separator-Konfiguration weiter unten](#-separator-konfiguration)

---

### 📊 Alle verfügbaren Output-Optionen

| Icon | Output-Key        | Beschreibung                                                                               |
| ---- | ----------------- | ------------------------------------------------------------------------------------------ |
| 🔍   | `all`             | Alle Eingaben nach Realpath- und Wildcard-Auflösung (inkl. fehlende Pfade)                 |
| 📄   | `file`            | Nur gefundene Dateien                                                                      |
| 📁   | `dir`             | Nur gefundene Verzeichnisse                                                                |
| ❌    | `missing`         | Eingaben, die nicht gefunden wurden                                                        |
| 🔑   | `file.{Mask}`     | Dateien, die die angegebene Berechtigung erfüllen (`r`, `w`, `x`, `rw`, `rx`, `wx`, `rwx`) |
| ⚠️   | `file.{Mask,not}` | Dateien, die die angegebene Berechtigung **nicht** erfüllen                                |
| 🔑   | `dir.{Mask}`      | Verzeichnisse, die die angegebene Berechtigung erfüllen                                    |
| ⚠️   | `dir.{Mask,not}`  | Verzeichnisse, die die Berechtigung **nicht** erfüllen                                     |
| 🔑   | `{Mask}`          | Alle Einträge (Dateien + Verzeichnisse) mit der angegebenen Berechtigung                   |
| ⚠️   | `{Mask,not}`      | Alle Einträge, die die Berechtigung **nicht** erfüllen                                     |


---

### 🔄 Beispiele für Output-Nutzung

```bash
declare -A Hallo

# Alle Dateien nach Berechtigung prüfen
classify_paths -i "/tmp/file*" -o Hallo -p "rwx"

# Zugriff auf Array
IFS='|' read -r -a FileArray <<< "${Hallo[file]}"
for f in "${FileArray[@]}"; do
    echo "Datei: $f"
done

# Zugriff auf Dateien, die Berechtigungen nicht erfüllen
IFS='|' read -r -a NotRWXArray <<< "${Hallo[rwx,not]}"
for f in "${NotRWXArray[@]}"; do
    echo "Nicht-RWX: $f"
done
```

\* **Mask**: Eine Berechtigungskombination, siehe Abschnitt [🛡️ Berechtigungslogik](#🛡️-berechtigungslogik) für Details.

---

### 📌 API-Referenz

| Beschreibung          | Argument / Alias                                    | Optional | Mehrfach | Typ                    |
| --------------------- | --------------------------------------------------- | -------- | -------- | ---------------------- |
| Eingabepfade          | `-i` / `--input` / `-d` / `--dir` / `-f` / `--file` | ❌        | ✅        | String                 |
| Alle Pfade            | `-o` / `--output`                                   | ❌        | ❌        | Associative Array Name |
| Berechtigungen prüfen | `-p` / `--perm`                                     | ✅        | ✅        | String                 |
| Separator             | `-s` / `--seperator`                                | ✅        | ❌        | String                 |

---


## 🗂️ Changelog

| 🔹 Feature / Änderung                            | ✨ Feature-Beschreibung                                                                       | v0.0.1-Beta.01 | v0.0.1-Beta.02 |
| ------------------------------------------------- | --------------------------------------------------------------------------------------------- | -------------- | -------------- |
| 🗂️ Eingabepfade (`-i/--input`, `-d/--dir`, `-f`) | Unterstützung mehrerer Eingaben, Leerzeichen in Pfaden                                         | ✅            | ✅            |
| 📤 Output-Array (`-o/--output`)                  | Benanntes assoziatives Array                                                                   | ✅            | ✅            |
| 🔑 Berechtigungen (`-p/--perm`)                  | Teilmasken, Kombinationen (`r`, `w`, `x`, `rw`, `rx`, `wx`, `rwx`), Negation (`-`/`not`)       | ✅            | ✅            |
| 🧩 Separator (`-s/--seperator`)                  | Flexibel:, Sonderzeichen, Leerzeichen oder leer/`false/off/no/not`; ungültige Werte → Warnung  | ❌            | ✅            |
| ✨ Wildcard-Erweiterung (`*`, `**`)              | Vollständige Unterstützung, fehlende Pfade landen in `missing`, Dotfiles berücksichtigt        | ❌            | ✅            |
| ♻️ Duplikaterkennung                             | Duplikate entfernt, getrennt für existierende und fehlende Pfade                               | ✅            | ✅            |
| 📂 Klassifizierung                               | `file`, `dir`, `missing` + zusätzliche Keys für Berechtigungen (`file.{mask}`, `dir.{mask}`)   | ✅            | ✅            |
| ⚠️ Negierte Berechtigungen (`not`)               | Alle Perm-Keys inkl. `not` initialisiert, unterstützt Teilmasken und kombinierte Rechte        | ✅            | ✅            |
| 📝 Fehler-/Warnmeldungen                         | Logging via `log_msg`, Warnungen bei ungültigen Masken oder Separatoren                        | ✅            | ✅            |
| 🛠️ Code-Struktur                                 | Helper-Funktionen sauber integriert, klare Trennung existierende vs. missing Pfade             | ❌            | ✅            |
| 🔄 Rückwärtskompatibilität                       | Alte Aufrufe laufen weiterhin korrekt                                                          | ✅            | ✅            |
| 💡 Zusätzliche Features                          | Teilmasken möglich, Leerzeichen als Separator, verbessertes Logging                            | ❌            | ✅            |

---

## 🤖 Generierungshinweis

Dieses Projekt wurde mit KI-Unterstützung dokumentiert. Skripte, Kommentare und Dokumentation wurden final von mir geprüft und angepasst.


## 👤 Autor & Kontakt

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)
* 📄 [MIT Lizenz](LICENSE)
