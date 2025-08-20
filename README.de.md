# 📂 Bash Functions Collection

[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Willkommen zur **Bash Functions Collection**!
Dieses Repository enthält eine Sammlung nützlicher Bash-Funktionen, die modular, dokumentiert und direkt in eigene Skripte integrierbar sind.

---

## 📌 Kurze Zusammenfassung

Dieses Repository enthält modulare Bash-Funktionen, die direkt in Skripte eingebunden werden können.

* [⚙️ Normalize List](#%EF%B8%8F-normalize-list) – Zerlegt Eingabe-Strings anhand von Leerzeichen, Kommas, Pipes oder eigenen Trennzeichen und gibt ein sauberes Array zurück. [Vollständige Dokumentation](Normalize%20List/README.de.md)
* [📋 Display Table](#%EF%B8%8F-display-table) – Zeigt formatierte Tabellen im Terminal an, berechnet Spaltenbreiten automatisch und zentriert den Header. Unterstützt mehrere Zeilen und benutzerdefinierte Separatoren. [Vollständige Dokumentation](Display%20Table/README.de.md)
* [✅ Check Requirements](#%EF%B8%8F-check-requirements) – Prüft Bash-Version, benötigte Funktionen, Programme, alternative Programmgruppen und optional Root-Rechte. [Vollständige Dokumentation](Check%20Requirements/README.md)
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

Für die vollständige Dokumentation und weitere Optionen siehe [Vollständige Dokumentation](Normalize%20List/README.de.md).

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

Für die vollständige Dokumentation siehe [Vollständige Dokumentation](Display%20Table/README.de.md).

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

Für die vollständige Dokumentation siehe [Vollständige Dokumentation](Check%20Requirements/README.md).

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
