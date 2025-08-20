# 📂 Bash Functions Collection

[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Willkommen zur **Bash Functions Collection**!
Dieses Repository enthält eine Sammlung nützlicher Bash-Funktionen, die modular, dokumentiert und direkt in eigene Skripte integrierbar sind.

---

## 📌 Kurze Zusammenfassung

Dieses Repository enthält modulare Bash-Funktionen, die direkt in Skripte eingebunden werden können.

* [⚙️ Normalize List](#%EF%B8%8F-normalize-list) – Zerlegt Eingabe-Strings anhand von Leerzeichen, Kommas, Pipes oder eigenen Trennzeichen und gibt ein sauberes Array zurück. [🔗 Vollständige Dokumentation](Normalize%20List/README.de.md)
* [📋 Display Table](#-display-table) – Zeigt formatierte Tabellen im Terminal an, berechnet Spaltenbreiten automatisch und zentriert den Header. Unterstützt mehrere Zeilen und benutzerdefinierte Separatoren. [🔗 Vollständige Dokumentation](Display%20Table/README.de.md)
* [✅ Check Requirements](#-check-requirements) – Prüft Bash-Version, benötigte Funktionen, Programme, alternative Programmgruppen und optional Root-Rechte. [🔗 Vollständige Dokumentation](Check%20Requirements/README.de.md)
* [📂 Resolve Paths](#-resolve-paths) - Normalisiert Eingabepfade, wandelt sie in absolute Pfade um und klassifiziert sie anschließend nach Existenz, Lesbarkeit und Schreibberechtigung.[🔗 Vollständige Dokumentation](Resolve%20Paths/README.de.md)
* [👤 Autor & Kontakt](#-autor--kontakt)
* [🤖 Generierungshinweis](#-generierungshinweis)
* [📜 Lizenz](#-lizenz)

---

## ⚙️ Normalize List

### Eine flexible Bash-Funktion zum Normalisieren von Eingabe-Strings in Arrays. Sie zerlegt Strings anhand von Leerzeichen, Kommas, Pipes oder benutzerdefinierten Trennzeichen und gibt ein sauberes Array zurück.

* 🟢 **Flexible Eingabe:** Akzeptiert einen oder mehrere Strings gleichzeitig.
* 🔹 **Benutzerdefinierte Trennzeichen:** Regex-ähnlich, z. B. Leerzeichen, Komma, Pipe oder eigene Zeichen.
* 🟣 **Array-Ausgabe:** Befüllt ein Bash-Array über Nameref (`-o|--output`).
* 🔒 **Robustes Fehlerhandling:** Fehlende Parameter werden erkannt und gemeldet.
* ⚡ **Einfache Integration:** Kann direkt in Skripte eingebunden werden, keine externen Abhängigkeiten.
* 💡 **Return-Wert:** 0 bei Erfolg, 2 bei Fehlern.

**Kurzes Beispiel:**

```bash
declare -a my_array

normalize_list -i "apple orange,banana|kiwi" -o my_array

# Ausgabe prüfen
printf "%s\n" "${my_array[@]}"
```

**Output:**

```
apple
orange
banana
kiwi
```

[🔗 Die vollständige Dokumentation und weitere Optionen findest du hier](Normalize%20List/README.de.md).

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

[🔗 Die vollständige Dokumentation und weitere Optionen findest du hier](Display%20Table/README.de.md).

---

## ✅ Check Requirements

### Eine Bash-Funktion zum Überprüfen von Skriptanforderungen, wie Bash-Version, erforderliche Funktionen und Programme. Optional können Root-Rechte geprüft werden, und alternative Programme können als Gruppe spezifiziert werden.

* 🟢 **Bash-Version prüfen:** Optionale Vorgaben für Major/Minor.
* ⚙️ **Funktionen prüfen:** Über `--funcs/-f` können zu prüfende Funktionen angegeben werden.
* 🟣 **Programme prüfen:** Über `--programs/-p` oder Gruppen `--programs-alternative/-a`.
* 🔒 **Root-Rechte prüfen:** Optional via `--root/-r` oder `--sudo/-s`.
* ⚡ **Flexible Fehlerbehandlung:** Mit `--exit/-x` lässt sich steuern, ob das Skript im Fehlerfall sofort mit `exit` beendet oder lediglich mit `return` zurückkehrt.
* 🔍 **Vollständige Prüfung:** Alle angegebenen Anforderungen werden zuerst geprüft; Rückgabe oder Abbruch erfolgt erst nach Abschluss aller Checks.
* 💡 **Return-Werte:** 0 bei Erfolg, 2 bei einem oder mehreren Fehlern.

**Kurzes Beispiel:**

```bash
# Prüft Bash ≥ 4, Funktion normalize_list, Programm awk, mindestens eines der Programme git oder svn, und Root-Rechte
check_requirements --major 4 --funcs "normalize_list" --programs "awk" --programs-alternative "git svn" --root
```

[🔗 Die vollständige Dokumentation und weitere Optionen findest du hier](Check%20Requirements/README.de.md).

---
## 📂 Resolve Paths

### Eine Bash-Funktion zum Normalisieren und Auflösen von Dateipfaden, Klassifizieren nach Existenz, Lesbarkeit und Schreibbarkeit sowie optionales Mapping der Ergebnisse in benannte Arrays.

* 🟢 **Eingaben normalisieren:** Unterstützt mehrere Pfade und benutzerdefinierte Trennzeichen.
* 🔹 **Absolute Pfade:** Wandelt relative Pfade in absolute Pfade um (`realpath`).
* 🟣 **Existenzprüfung:** Trennt vorhandene von fehlenden Pfaden.
* 🔒 **Lesbar/Schreibbar prüfen:** Trennt lesbare/schreibbare und nicht-lesbare/nicht-schreibbare Pfade.
* ⚡ **Flexible Ausgabe:** Ergebnisse können in ein oder mehrere benannte Arrays geschrieben werden.
* 💡 **Rückgabewerte:** `0` bei Erfolg, `2` bei Fehler (z. B. fehlende Eingabe, unbekannte Option).

**Kurzes Beispiel:**

```bash
declare -a all exist

resolve_paths -i "file1.txt,file2.txt,/tmp/file3" -o-all all -o-exist exist

printf "All: %s\nExist: %s\n" "${all[*]}" "${exist[*]}"
```

Es zeigt **alle Pfade** und **nur existierende Pfade** in zwei Arrays.

**Output:**

```
All: file1.txt file2.txt /tmp/file3
Exist: /tmp/file3
```

[🔗 Die vollständige Dokumentation und weitere Optionen findest du hier](Resolve%20Paths/README.de.md)

---


## 👤 Autor & Kontakt

* **Marcel Gräfen**
* 📧 [info@mgraefen.com](mailto:info@mgraefen.com)

---

## 🤖 Generierungshinweis

Dieses Projekt wurde mithilfe einer Künstlichen Intelligenz (KI) entwickelt.
Die KI hat bei der Erstellung des Skripts, der Kommentare und der Dokumentation (README.md) geholfen.
Das endgültige Ergebnis wurde von mir überprüft und angepasst.

---

## 📜 Lizenz

[MIT Lizenz](LICENSE)
