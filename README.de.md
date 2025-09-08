# 📂 Bash Functions Collection

[![Englich](https://img.shields.io/badge/Sprache-Englich-blue)](./README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Willkommen zur **Bash Functions Collection**!
Dieses Repository enthält eine Sammlung nützlicher Bash-Funktionen, die modular, dokumentiert und direkt in eigene Skripte integrierbar sind.

---

## 📌 Kurze Zusammenfassung

Dieses Repository enthält modulare Bash-Funktionen, die direkt in Skripte eingebunden werden können:

* [⚙️ Normalize List](#-normalize-list) – Zerlegt Eingabe-Strings anhand von Leerzeichen, Kommas, Pipes oder eigenen Trennzeichen und gibt ein sauberes Array zurück. [🔗 Vollständige Dokumentation](Normalize_List/README.de.md)
* [📋 Display Table](#-display-table) – Zeigt formatierte Tabellen im Terminal an, berechnet Spaltenbreiten automatisch und zentriert den Header. Unterstützt mehrere Zeilen und benutzerdefinierte Separatoren. [🔗 Vollständige Dokumentation](Display_Table/README.de.md)
* [✅ Check Requirements](#-check-requirements) – Prüft Bash-Version, benötigte Funktionen, Programme, alternative Programmgruppen und optional Root-Rechte. [🔗 Vollständige Dokumentation](Check_Requirements/README.de.md)
* [📂 Resolve Paths](#-resolve-paths) – Normalisiert Eingabepfade und wandelt sie in absolute Pfade um. [🔗 Vollständige Dokumentation](Resolve_Paths/README.de.md)
* [📋 Classify Paths](#-classify-paths) – Klassifiziert Pfade nach **Existenz** und **Berechtigungen**, unterstützt Wildcards (`*`, `**`) und speichert Ergebnisse in benannte Arrays. [🔗 Vollständige Dokumentation](Classify_Paths/README.de.md)
* [📋 Log Call Chain](#-log-call-chain) – Zeichnet **verschachtelte Funktions- und Skriptaufrufe** auf, erzeugt ASCII-Bäume, unterstützt mehrere Log-Dateien, Details, Fehlermeldungen und Unterdrückungen. [🔗 Vollständige Dokumentation](Log_Call_Chain/README.de.md)
* [📋 Parse Case Flags](#-parse-case-flags) – Parsen, Validieren und Zuweisen von Kommandozeilen-Flags innerhalb eines case-Blocks. [🔗 Vollständige Dokumentation](Parse_Case_Flags/README.de.md)
* [📂 Format Message Line](#-format-message-line) – Formatiert Nachrichten in dekorative Linien mit Klammern, Füllzeichen, Padding und Mindestlänge. [🔗 Vollständige Dokumentation](Format_Message_Line/README.de.md)
* [🤖 Generierungshinweis](#-generierungshinweis)
* [👤 Autor & Kontakt](#-autor--kontakt)

---

## ⚙️ Normalize List

### Flexible Bash-Funktion zum Normalisieren von Eingabe-Strings in Arrays

* 🟢 **Flexible Eingabe:** Akzeptiert einen oder mehrere Strings.
* 🔹 **Benutzerdefinierte Trennzeichen:** Regex-ähnlich, z. B. Leerzeichen, Komma, Pipe oder eigene Zeichen.
* 🟣 **Array-Ausgabe:** Befüllt ein Bash-Array über Nameref (`--out|--output`).
* 🔒 **Robustes Fehlerhandling:** Fehlende Parameter werden erkannt.
* ⚡ **Einfache Integration:** Direkt einbindbar, keine externen Abhängigkeiten.
* 💡 **Return-Werte:** 0 bei Erfolg, 2 bei Fehler.

**Beispiel:**

```bash
declare -a my_array
normalize_list -i "apple orange,banana|kiwi" --out my_array
printf "%s\n" "${my_array[@]}"
```

**Ausgabe:**

```
apple
orange
banana
kiwi
```

[🔗 Vollständige Dokumentation](Normalize_List/README.de.md)

---

## 📋 Display Table

### Zeigt formatierte Tabellen im Terminal an

* 🟢 **Flexible Zeilen & Spalten**
* 🔹 **Automatische Spaltenbreite**
* 🟣 **Header-Zentrierung**
* 🔒 **Robuste Fehlerprüfung**
* ⚡ **Einfache Integration**
* 💡 **Return-Werte:** 0 bei Erfolg, 2 bei fehlenden Funktionen

**Beispiel:**

```bash
display_table -H "My Table" \
  -v "Value1,Value2,Value3" \
  -v "A,B,C"
```

**Ausgabe:**

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

### Prüft Skriptanforderungen: Bash-Version, Funktionen, Programme, Root-Rechte

**Beispiel:**

```bash
check_requirements --major 4 --funcs "normalize_list" --programs "awk" --programs-alternative "git svn" --root
```

[🔗 Vollständige Dokumentation](Check_Requirements/README.de.md)

---

## 📂 Resolve Paths

### Normalisiert Eingabepfade und wandelt sie in absolute Pfade um

**Beispiel:**

```bash
declare -a all exist
resolve_paths -i "file1.txt,file2.txt,/tmp/file3" --out-all all --out-exist exist
printf "All: %s\nExist: %s\n" "${all[*]}" "${exist[*]}"
```

[🔗 Vollständige Dokumentation](Resolve_Paths/README.de.md)

---

## 📋 Classify Paths

### Klassifiziert Pfade nach Existenz und Berechtigungen

**Beispiel:**

```bash
declare -A Hallo
classify_paths -i "/tmp/file1 /tmp/file2 /tmp/nonexistent" -o Hallo -p "r w x rwx"
echo "All files: ${Hallo[all]}"
echo "Existing files: ${Hallo[file]}"
echo "Missing files: ${Hallo[missing]}"
```

[🔗 Vollständige Dokumentation](Classify_Paths/README.de.md)

---

## 📋 Log Call Chain

### Zeichnet verschachtelte Funktions- und Skriptaufrufe auf

**Beispiel:**

```bash
log_call_chain -s INFO -m "Starting process" -d "/tmp" -f "process.log"
```

[🔗 Vollständige Dokumentation](Log_Call_Chain/README.de.md)

---

## 📋 Parse Case Flags

### Parsen, Validieren und Zuweisen von Kommandozeilen-Flags

**Beispiel:**

```bash
parse_case_flags --tags tags_array --array Dev Ops QA -i "$@" || return 1
```

[🔗 Vollständige Dokumentation](Parse_Case_Flags/README.de.md)

---

## 📂 Format Message Line

### Formatiert Nachrichten in dekorative Linien mit Klammern, Füllzeichen, Padding und Mindestlänge

**Beispiel:**

```bash
format_message_line -m "Hello World"
```

**Ausgabe via `echo`:**

```
=================[Hello World]=================
```

[🔗 Vollständige Dokumentation](Format_Message_Line/README.de.md)

---

## 🤖 Generierungshinweis

Dieses Projekt wurde mithilfe einer Künstlichen Intelligenz (KI) erstellt.
Skripte, Kommentare und Dokumentation wurden final geprüft und angepasst.

---

## 👤 Autor & Kontakt

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)
* 📄 [MIT Lizenz](LICENSE)
