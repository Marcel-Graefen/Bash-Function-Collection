# 📂 Bash Functions Collection

[![English](https://img.shields.io/badge/Sprache-English-blue)](./README.md)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Willkommen zur **Bash Functions Collection**!
Dieses Repository enthält eine Sammlung nützlicher Bash-Funktionen, die modular, dokumentiert und direkt in eigene Skripte integrierbar sind.

---

## 📌 Kurze Zusammenfassung

* [⚙️ Normalize List](#%EF%B8%8F-normalize-list) – Zerlegt Eingabe-Strings & gibt ein sauberes Array zurück. [Vollständige Dokumentation](Normalize%20List/README.de.md)
* [👤 Autor & Kontakt](#-autor--kontakt)
* [🤖 Generierungshinweis](#-generierungshinweis)
* [📜 Lizenz](#-lizenz)

---

## ⚙️ Normalize List

Zerlegt Eingabe-Strings anhand von Leerzeichen, Kommas, Pipes oder eigenen Trennzeichen und gibt ein sauberes Array zurück.

**Kurzes Beispiel:**

```bash
declare -a my_array

normalize_list -i "apple orange,banana|kiwi" -o my_array

# Ausgabe prüfen
printf "%s\n" "${my_array[@]}"
````

**Output:**

```
apple
orange
banana
kiwi
```

Für die vollständige Dokumentation und weitere Optionen siehe [Vollständige Dokumentation](Normalize%20List/README.de.md).

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
