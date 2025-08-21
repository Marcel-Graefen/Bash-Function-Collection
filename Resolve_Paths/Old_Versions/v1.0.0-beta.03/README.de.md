# 📋 Bash Funktion: resolve_paths

[![Zurück zum Haupt-README](https://img.shields.io/badge/Main-README-blue?style=flat&logo=github)](../../../README.de.md)
[![Version](https://img.shields.io/badge/version-1.0.0_beta.03-blue.svg)](#)
[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Eine Bash-Funktion zum Normalisieren und Auflösen von Dateipfaden, automatische Wildcard-Erweiterung (*?), Klassifizierung nach Existenz und einzelnen sowie kombinierten Berechtigungen (r/w/x, rw, rx, wx, rwx) sowie optionales Mapping der Ergebnisse in benannte Arrays.

---

## 🚀 Inhaltsverzeichnis

* [📌 Wichtige Hinweise](#📌-wichtige-hinweise)
* [🛠️ Funktionen & Features](#🛠️-funktionen--features)
* [⚙️ Voraussetzungen](#⚙️-voraussetzungen)
* [📦 Installation](#📦-installation)
* [📝 Nutzung](#📝-nutzung)
  * <details>
    <summary>▶️ Beispiele</summary>

      * [🗂️ Pfade normalisieren und auflösen](#🗂️-pfade-normalisieren-und-auflösen)
      * [⚙️ Benutzerdefinierte Trennzeichen](#⚙️-benutzerdefinierte-trennzeichen)
      * [🔍 Pfade klassifizieren](#🔍-pfade-klassifizieren)
      * [📝 Ausgabe in benannte Arrays](#📝-ausgabe-in-benannte-arrays)
      * [✨ Wildcards verwenden](#✨-wildcards-verwenden)
      * [🔄 Kombination mehrerer Eingaben](#🔄-kombination-von-mehreren-eingaben)
      * [🔑 Nur Schreibbarkeit prüfen](#🔑-prüfen-nur-nach-schreibbarkeit)
      * [📛 Fehlende Dateien ermitteln](#📛-fehlende-dateien-ermitteln)
      * [▶️ Prüfen auf ausführbare Skripte](#▶️-prüfen-auf-ausführbare-skripte)
      * [🔒 Alle Berechtigungen prüfen](#🔒-alle-berechtigungen-prüfen)

    </details>
* [📌 API-Referenz](#📌-api-referenz)
* [🗂️ Changelog](#🗂️-changelog)
* [👤 Autor & Kontakt](#👤-autor--kontakt)
* [🤖 Generierungshinweis](#🤖-generierungshinweis)
* [📜 Lizenz](#📜-lizenz)



---

## 🛠️ Funktionen & Features

* 🗂️ **Eingaben normalisieren:** Trennt eine oder mehrere Pfade automatisch nach Leerzeichen oder benutzerdefinierten Zeichen.
* 🔹 **Absolute Pfade:** Wandelt relative Pfade in absolute Pfade um (`realpath`).
* ✨ **Automatische Wildcard-Erweiterung:** Pfade mit `*` oder `?` werden automatisch aufgelöst.
* 🟣 **Existenzprüfung:** Trennt vorhandene von fehlenden Pfaden.
* 🔒 **Berechtigungsprüfung:** Prüft Lesbarkeit (`r`), Schreibbarkeit (`w`) und Ausführbarkeit (`x`) sowie Kombinationen (`rw`, `rx`, `wx`, `rwx`).
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

### 🗂️ Pfade normalisieren und auflösen

Normalisiert Eingabepfade, teilt sie auf und wandelt sie in absolute Pfade um.

```bash
declare -a alle_pfade

# Beispiel: Eine Eingabe mit mehreren Pfaden
resolve_paths -i "file1.txt file2.txt,/tmp/file3" -o-all alle_pfade

# Ausgabe prüfen
printf "%s\n" "${alle_pfade[@]}"
```

**Erklärung:** Alle Pfade werden absolut und getrennt in das Array `alle_pfade` geschrieben.

---

### ⚙️ Benutzerdefinierte Trennzeichen

```bash
declare -a alle_pfade

# Beispiel: Komma, Semikolon oder Pipe als Trenner
resolve_paths \
  -i "file1.txt,file2.txt;/tmp/file3|/var/log/syslog" \
  -s ",;|" \
  -o-all alle_pfade

printf "%s\n" "${alle_pfade[@]}"
```

**Erklärung:** Trennzeichen können beliebig angegeben werden; hier werden mehrere Separatoren gleichzeitig genutzt.

>  Standardmäßig trennt die Funktion `normalize_list` Pfade anhand von Leerzeichen (` `), Komma (`,`) und Pipe (`|`). Daher ist die Angabe von -s|--separator meist nicht erforderlich.

---

### 🔍 Pfade klassifizieren

```bash
declare -a exist missing r not_r w not_w x not_x rw not_rw rx not_rx wx not_wx rwx not_rwx

# Beispiel: Prüfen von Existenz und Berechtigungen
resolve_paths \
  -i "file1.txt file2.txt /tmp/file3" \
  -o-exist exist -o-missing missing \
  -o-r r -o-not-r not_r \
  -o-w w -o-not-w not_w \
  -o-x x -o-not-x not_x \
  -o-rw rw -o-not-rw not_rw \
  -o-rx rx -o-not-rx not_rx \
  -o-wx wx -o-not-wx not_wx \
  -o-rwx rwx -o-not-rwx not_rwx
```

**Erklärung:** Trennt vorhandene/fehlende Pfade sowie lesbare, schreibbare, ausführbare Pfade und alle Kombis (`rw`, `rx`, `wx`, `rwx`).

---

### 📝 Ausgabe in benannte Arrays

```bash
declare -a ALL EXIST MISSING RW NOT_RW

# Beispiel: Ergebnisse in eigene Arrays mappen
resolve_paths \
  -i "file1.txt,file2.txt,/tmp/file3" \
  -o-all ALL \
  -o-exist EXIST \
  -o-missing MISSING \
  -o-rw RW \
  -o-not-rw NOT_RW

echo "ALL:     ${ALL[*]}"
echo "EXIST:   ${EXIST[*]}"
echo "MISSING: ${MISSING[*]}"
echo "RW:      ${RW[*]}"
echo "NOT_RW:  ${NOT_RW[*]}"
```

**Erklärung:** Beliebige interne Arrays können in eigene benannte Arrays geschrieben werden.

---

### ✨ Wildcards verwenden

```bash
declare -a ALL EXIST RX NOT_RX

# Beispiel: Alle .sh-Dateien im aktuellen Verzeichnis
resolve_paths \
  -i "./*.sh" \
  -o-all ALL \
  -o-exist EXIST \
  -o-rx RX \
  -o-not-rx NOT_RX

echo "ALL:    ${ALL[*]}"
echo "EXIST:  ${EXIST[*]}"
echo "RX:     ${RX[*]}"
echo "NOT_RX: ${NOT_RX[*]}"
```

**Erklärung:** Wildcards `*` und `?` werden automatisch aufgelöst; Kombinationen von Berechtigungen können direkt geprüft werden.

---

### 🔄 Kombination von mehreren Eingaben

```bash
declare -a ALL

# Mehrere -i Parameter gleichzeitig
resolve_paths -i "file1.txt file2.txt" -i "/tmp/file3 /var/log/syslog" -o-all ALL
echo "${ALL[*]}"
```

**Erklärung:** Mehrere Eingabearrays werden zusammen normalisiert und in ein Array geschrieben.

---

### 🔑 Prüfen nur nach Schreibbarkeit

```bash
declare -a W WRITEABLE_NOT

resolve_paths -i "/tmp/*" -o-w W -o-not-w WRITEABLE_NOT
echo "Writable: ${W[*]}"
echo "Not writable: ${WRITEABLE_NOT[*]}"
```

**Erklärung:** Nur Schreibrechte prüfen, alle anderen Permissions ignorieren.

---

### 📛 Fehlende Dateien ermitteln

```bash
declare -a MISSING

resolve_paths -i "file1.txt file2.txt /nonexistent/file" -o-missing MISSING
echo "Missing files: ${MISSING[*]}"
```

**Erklärung:** Schnell ermitteln, welche Pfade noch erstellt werden müssen.

---

### ▶️ Prüfen auf ausführbare Skripte

```bash
declare -a RX RX_NOT

resolve_paths -i "/usr/bin/*" -o-rx RX -o-not-rx RX_NOT
echo "Executable: ${RX[*]}"
echo "Not executable: ${RX_NOT[*]}"
```

**Erklärung:** Kombination aus lesbar + ausführbar filtern (z.B. Skripte).

---

### 🔒 Alle Berechtigungen prüfen

```bash
declare -a ALL RWX NOT_RWX

resolve_paths -i "./*" -o-rwx RWX -o-not-rwx NOT_RWX
echo "All rwx: ${RWX[*]}"
echo "Not rwx: ${NOT_RWX[*]}"
```

**Erklärung:** Prüft in einem Schritt, welche Dateien **vollständige Lese-/Schreib-/Ausführrechte** haben.

---

## 📌 API-Referenz

| Beschreibung                                         | Argument / Alias                            | Optional | Mehrfach | Typ       |
| ---------------------------------------------------- | ------------------------------------------- | ------- | -------- | ---------- |
| 🟢📂 Eingabepfade                                   | `-i` / `--input`                            | ❌      | ✅      | String     |
| 🔹📂 Trennzeichen                                   | `-s` / `--separator`                        | ✅      | ❌      | String     |
| 🟣📂 Alle normalisierten Pfade                      | `-o-all`                                    | ✅      | ❌      | Array-Name |
| 🟣✅ Existierende Pfade                             | `-o-exist`                                  | ✅      | ❌      | Array-Name |
| 🟣❌ Fehlende Pfade                                 | `-o-missing`                                | ✅      | ❌      | Array-Name |
| 🔒👀 Lesbar                                         | `-o-r`                                      | ✅      | ❌      | Array-Name |
| 🔒🚫 Nicht-lesbar                                   | `-o-not-r`                                  | ✅      | ❌      | Array-Name |
| 🔒✍️ Schreibbar                                     | `-o-w`                                      | ✅      | ❌      | Array-Name |
| 🔒🚫 Nicht-schreibbar                               | `-o-not-w`                                  | ✅      | ❌      | Array-Name |
| 🔒▶️ Ausführbar                                     | `-o-x`                                      | ✅      | ❌      | Array-Name |
| 🔒🚫 Nicht-ausführbar                               | `-o-not-x`                                  | ✅      | ❌      | Array-Name |
| 🔒⚡ Kombinierte Berechtigungen (rw)                | `-o-rw` / `-o-wr`                           | ✅      | ❌      | Array-Name |
| 🔒❌ Negation kombinierter Berechtigungen (rw)      | `-o-not-rw` / `-o-not-wr`                   | ✅      | ❌      | Array-Name |
| 🔒⚡ Kombinierte Berechtigungen (rx)                | `-o-rx` / `-o-xr`                           | ✅      | ❌      | Array-Name |
| 🔒❌ Negation kombinierter Berechtigungen (rx)      | `-o-not-rx` / `-o-not-xr`                   | ✅      | ❌      | Array-Name |
| 🔒⚡ Kombinierte Berechtigungen (wx)                | `-o-wx` / `-o-xw`                           | ✅      | ❌      | Array-Name |
| 🔒❌ Negation kombinierter Berechtigungen (wx)      | `-o-not-wx` / `-o-not-xw`                   | ✅      | ❌      | Array-Name |
| 1️⃣🔒⚡💡 Kombinierte Berechtigungen (rwx)          | `-o-rwx` / `-o-rxw` / `-o-wrx`              | ✅      | ❌      | Array-Name |
| 2️⃣🔒⚡💡 Kombinierte Berechtigungen (rwx)          |  `-o-wxr` / `-o-xrw` / `-o-xwr`             | ✅      | ❌      | Array-Name |
| 1️⃣🔒❌💡 Negation kombinierter Berechtigungen (rwx)| `-o-not-rwx` / `-o-not-rxw` / `-o-not-wrx`  | ✅      | ❌      | Array-Name |
| 2️⃣🔒⚡💡 Negation kombinierter Berechtigungen (rwx)| `-o-not-wxr` / `-o-not-xrw` / `-o-not-xwr`  | ✅      | ❌      | Array-Name |

**Rückgabewerte:**

* `0` bei Erfolg
* `2` bei Fehler

---

## 🗂️ Changelog

**Version 1.0.0-Beta.03 – Verbesserungen gegenüber 1.0.0-Beta.02**

* 🆕 **Berechtigungsprüfung erweitert:** Prüft jetzt zusätzlich `r`, `w`, `x` und alle Kombinationen (`rw`, `rx`, `wx`, `rwx`) mit Negationen
* ⚡ **Klassifizierung optimiert:** Nur Berechtigungen, die als Output angefragt werden, werden geprüft
* 🟢 **API erweitert:** Neue Optionen `-o-r`, `-o-w`, `-o-x`, `-o-rw`, `-o-rx`, `-o-wx`, `-o-rwx` sowie ihre `-o-not-*` Varianten
* 📝 **Dokumentation aktualisiert:** README an neue Optionen angepasst

### Unterschiede zur Beta.02

| Feature / Änderung                                     | 03 | 01 |
| ------------------------------------------------------ | -- | -- |
| 🔒 Berechtigungsprüfung (r/w/x)                       | ✅ | ❌ |
| 🔒 Kombinierte Berechtigungen rw/rx/wx/rwx            | ✅ | ❌ |
| ⚡ Klassifizierung nur bei angefragten Berechtigungen | ✅ | ❌ |
| 📝 API Referenz aktualisiert                          | ✅ | ❌ |

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
