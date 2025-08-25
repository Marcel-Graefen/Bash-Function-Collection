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
* [✅ Check Requirements](#✅-check-requirements) – Prüft Bash-Version, benötigte Funktionen, Programme, alternative Programmgruppen und optional Root-Rechte. [🔗 Vollständige Dokumentation](Check_Requirements/README.de.md)
* [📂 Resolve Paths](#📂-resolve-paths) – Normalisiert Eingabepfade und wandelt sie in absolute Pfade um. [🔗 Vollständige Dokumentation](Resolve_Paths/README.de.md)
* [📋 Classify Paths](#📋-classify-paths) – Klassifiziert Pfade nach **Existenz** und **Berechtigungen** inkl. Wildcards (`*`, `**`) und speichert Ergebnisse in benannte Arrays. [🔗 Vollständige Dokumentation](Classify_Paths/README.de.md)
* [🤖 Generierungshinweis](#🤖-generierungshinweis)
* [👤 Autor & Kontakt](#👤-autor--kontakt)

---

## ⚙️ Normalize List

### Eine flexible Bash-Funktion zum Normalisieren von Eingabe-Strings in Arrays. Sie zerlegt Strings anhand von Leerzeichen, Kommas, Pipes oder benutzerdefinierten Trennzeichen und gibt ein sauberes Array zurück.

* 🟢 **Flexible Eingabe:** Akzeptiert einen oder mehrere Strings gleichzeitig.
* 🔹 **Benutzerdefinierte Trennzeichen:** Regex-ähnlich, z. B. Leerzeichen, Komma, Pipe oder eigene Zeichen.
* 🟣 **Array-Ausgabe:** Befüllt ein Bash-Array über Nameref (`--out|---output`).
* 🔒 **Robustes Fehlerhandling:** Fehlende Parameter werden erkannt und gemeldet.
* ⚡ **Einfache Integration:** Kann direkt in Skripte eingebunden werden, keine externen Abhängigkeiten.
* 💡 **Return-Wert:** 0 bei Erfolg, 2 bei Fehlern.

**Kurzes Beispiel:**

```bash
declare -a my_array

normalize_list -i "apple orange,banana|kiwi" --out my_array

printf "%s\n" "${my_array[@]}"
```

**Output:**

```
apple
orange
banana
kiwi
```

[🔗 Vollständige Dokumentation](Normalize_List/README.de.md)

---

## 📋 Display Table

### Eine flexible Bash-Funktion zum Anzeigen von formatierten Tabellen im Terminal. Sie berechnet Spaltenbreiten automatisch, zentriert den Header und gibt jede Zeile sauber formatiert aus.

* 🟢 **Flexible Zeilen & Spalten:** Jede Zeile kann mehrere Spalten enthalten.
* 🔹 **Automatische Spaltenbreiten:** Passt Spaltenbreite an längste Inhalte an.
* 🟣 **Header-Zentrierung:** Optionaler Tabellen-Header wird mittig angezeigt.
* 🔒 **Robuste Fehlerprüfung:** Prüft auf fehlende Funktionen.
* ⚡ **Einfache Integration:** Kann direkt in Bash-Skripte eingebunden werden.
* 💡 **Return-Wert:** 0 bei Erfolg, 2 wenn benötigte Funktionen fehlen.

**Kurzes Beispiel:**

```bash
display_table -H "My Table" \
  -v "Value1,Value2,Value3" \
  -v "A,B,C"
```

**Output:**

```
+--------+--------+--------+
|       My Table          |
+--------+--------+--------+
| Value1 | Value2 | Value3 |
+--------+--------+--------+
| A      | B      | C      |
+--------+--------+--------+
```

[🔗 Vollständige Dokumentation](Display_Table/README.de.md)

---

## ✅ Check Requirements

### Eine Bash-Funktion zum Überprüfen von Skriptanforderungen: Bash-Version, Funktionen, Programme und optional Root-Rechte.

* 🟢 **Bash-Version prüfen:** Optional für Major/Minor.
* ⚙️ **Funktionen prüfen:** Über `--funcs/-f` zu prüfende Funktionen.
* 🟣 **Programme prüfen:** Über `--programs/-p` oder Gruppen `--programs-alternative/-a`.
* 🔒 **Root-Rechte prüfen:** Optional via `--root/-r` oder `--sudo/-s`.
* ⚡ **Flexible Fehlerbehandlung:** Mit `--exit/-x` wird entschieden, ob das Skript bei Fehler sofort abbricht.
* 🔍 **Vollständige Prüfung:** Alle Anforderungen werden zuerst geprüft; Rückgabe erfolgt nach Abschluss.
* 💡 **Return-Werte:** 0 bei Erfolg, 2 bei einem oder mehreren Fehlern.

**Kurzes Beispiel:**

```bash
check_requirements --major 4 --funcs "normalize_list" --programs "awk" --programs-alternative "git svn" --root
```

[🔗 Vollständige Dokumentation](Check_Requirements/README.de.md)

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

[🔗 Vollständige Dokumentation](Resolve_Paths/README.de.md)

---

## 📋 Classify Paths

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

[🔗 Vollständige Dokumentation](Classify_Paths/README.de.md)

---

## 🤖 Generierungshinweis

Dieses Projekt wurde mithilfe einer Künstlichen Intelligenz (KI) erstellt. Skripte, Kommentare und Dokumentation wurden final geprüft und angepasst.

---

## 👤 Autor & Kontakt

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)
* 📄 [MIT Lizenz](LICENSE)
