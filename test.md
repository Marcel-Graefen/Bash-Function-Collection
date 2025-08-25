Alles klar! Ich habe **Resolve Paths** und **classify\_paths** wieder getrennt und jeweils eigene Abschnitte mit kurzem Beispiel erstellt. Hier ist die überarbeitete README:

---

# 📂 Bash Functions Collection

[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Willkommen zur **Bash Functions Collection**!
Dieses Repository enthält eine Sammlung nützlicher Bash-Funktionen, die modular, dokumentiert und direkt in eigene Skripte integrierbar sind.

---

## 📌 Kurze Zusammenfassung

Dieses Repository enthält modulare Bash-Funktionen, die direkt in Skripte eingebunden werden können:

* [⚙️ Normalize List](#%EF%B8%8F-normalize-list) – Zerlegt Eingabe-Strings anhand von Leerzeichen, Kommas, Pipes oder eigenen Trennzeichen und gibt ein sauberes Array zurück. [🔗 Vollständige Dokumentation](Normalize_List/README.de.md)
* [📋 Display Table](#-display-table) – Zeigt formatierte Tabellen im Terminal an, berechnet Spaltenbreiten automatisch und zentriert den Header. Unterstützt mehrere Zeilen und benutzerdefinierte Separatoren. [🔗 Vollständige Dokumentation](Display_Table/README.de.md)
* [✅ Check Requirements](#-check-requirements) – Prüft Bash-Version, benötigte Funktionen, Programme, alternative Programmgruppen und optional Root-Rechte. [🔗 Vollständige Dokumentation](Check_Requirements/README.de.md)
* [📂 Resolve Paths](#📂-resolve-paths) – Normalisiert Eingabepfade und wandelt sie in absolute Pfade um. [🔗 Vollständige Dokumentation](Resolve_Paths/README.de.md)
* [📋 classify\_paths](#📋-classify-paths) – Klassifiziert Pfade nach **Existenz** und **Berechtigungen** inkl. Wildcards (`*`, `**`) und speichert Ergebnisse in benannte Arrays. [🔗 Vollständige Dokumentation](classify_paths/README.de.md)
* [👤 Autor & Kontakt](#-autor--kontakt)
* [🤖 Generierungshinweis](#-generierungshinweis)
* [📜 Lizenz](#-lizenz)

---

## ⚙️ Normalize List

*Details unverändert…*

---

## 📋 Display Table

*Details unverändert…*

---

## ✅ Check Requirements

*Details unverändert…*

---

## 📂 Resolve Paths

### Normalisiert Eingabepfade und wandelt sie in absolute Pfade um.

* 🗂️ **Eingaben normalisieren:** Mehrere `-i/--input`, `-d/--dir`, `-f/--file`.
* 🔹 **Absolute Pfade:** Normalisierung via `realpath -m`.
* ✨ **Wildcard-Erweiterung:** `*` und `**` (Globstar) werden unterstützt.
* 🟣 **Existenzprüfung:** Trennt vorhandene Pfade von fehlenden.
* 💡 **Return-Werte:** 0 bei Erfolg, 2 bei Fehler.

**Kurzes Beispiel:**

```bash
declare -a all exist

resolve_paths -i "file1.txt,file2.txt,/tmp/file3" --out-all all --out-exist exist

printf "All: %s\nExist: %s\n" "${all[*]}" "${exist[*]}"
```

---

## 📋 classify\_paths

### Klassifiziert Pfade nach **Existenz** und **Berechtigungen** (r/w/x, rw, rx, wx, rwx) und speichert Ergebnisse in benannte Arrays. Unterstützt Wildcards (`*`, `**`) und flexible Separatoren.

* 🗂️ **Eingaben normalisieren:** Mehrere `-i/--input`, `-d/--dir`, `-f/--file`.
* 🔹 **Absolute Pfade:** Normalisierung via `realpath -m`.
* ✨ **Wildcard-Erweiterung:** `*` und `**` (Globstar), Dotfiles berücksichtigt.
* 🔒 **Berechtigungsprüfung:** r/w/x, Kombinationen (rw, rx, wx, rwx), Negationen (`-` / `not`).
* ⚡ **Flexible Separatoren:** Standard `|`. Sonderzeichen, Leerzeichen oder kein Separator möglich. Ungültige Werte → Warnung.
* 🟣 **Existenzprüfung & Klassifizierung:** `file`, `dir`, `missing`. Berechtigungs-Keys: `file.{mask}`, `dir.{mask}`, `{mask}`, `{mask,not}`.
* ♻️ **Duplikaterkennung:** Doppelte Pfade entfernt; existierende/fehlende getrennt.
* ⚠️ **Logging & Warnungen:** Ungültige Masken oder Separatoren werden gemeldet.
* 💡 **Return-Werte:** 0 bei Erfolg, 2 bei Fehler.

**Kurzes Beispiel:**

```bash
declare -A Hallo

classify_paths -i "/tmp/file1 /tmp/file2 /tmp/nonexistent" -o Hallo -p "r w x rwx"

echo "All files: ${Hallo[all]}"
echo "Existing files: ${Hallo[file]}"
echo "Missing files: ${Hallo[missing]}"
```

---

## 👤 Autor & Kontakt

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)

---

## 🤖 Generierungshinweis

Dieses Projekt wurde mithilfe einer Künstlichen Intelligenz (KI) erstellt. Skripte, Kommentare und Dokumentation wurden final geprüft und angepasst.

---

## 📜 Lizenz

[![MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

Wenn du willst, kann ich als Nächstes die **README auch vollständig auf Englisch übersetzen**, sodass sie zweisprachig wird.

Willst du, dass ich das direkt mache?
