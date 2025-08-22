## 1️⃣ Testplan für `classify_paths()` / `prepare_paths_for_classify_paths()`

### **A. Allgemeine Prüfungen**

| Testfall                            | Erwartetes Ergebnis                                               |
| ----------------------------------- | ----------------------------------------------------------------- |
| Kein Parameter                      | Fehler `No parameters provided`                                   |
| Nur Output gesetzt, kein Input      | Fehler `No input paths`                                           |
| Nur Input gesetzt, kein Output      | Fehler `Output not set`                                           |
| Input enthält `/`\*\*`**/`\*\`      | Fehler `Leading '/**/' is not allowed`                            |
| Separator enthält `/`, `*` oder `.` | Fehler `Separator cannot contain /, * or .`                       |
| Ungültige Berechtigungsmasken       | Fehler `All permission masks invalid` oder Warnung bei Teilmasken |

---

### **B. Argument Parsing**

* `-i` / `--input` korrekt: Eingaben landen im Array `inputs`.
* `-d` / `--dir` oder `-f` / `--file` korrekt: wie `-i`.
* `-o` / `--output` korrekt: Name wird für das assoziative Array gesetzt.
* `-s` / `--separator` korrekt: Separator wird übernommen.
* `-p` / `--perm` korrekt: Masken werden übernommen, ungültige Masken werden ignoriert.

---

### **C. Wildcard & Normalisierung**

* Wildcards `*`, `?`, `**` expandieren korrekt.
* Doppelte Pfade werden entfernt.
* `realpath -m` liefert absolute Pfade.

---

### **D. Pfadklassifizierung**

* Existierende Dateien → `file`, Verzeichnisse → `dir`.
* Fehlende Pfade → `file,missing` oder `dir,missing`.
* `all` enthält alles.
* `all,missing` enthält alles, was nicht existiert.

---

### **E. Berechtigungsprüfung**

* Prüft alle möglichen Masken:

  * `r`, `w`, `x`, `rw`, `rx`, `wx`, `rwx`, `r--`, `rw-`, `r-x`, `-w-`, `-wx`, `--x`, `---`
* Prüft existierende und nicht existierende Pfade.
* Prüft gemischte gültige/ungültige Masken.

---

### **F. Fehlerfälle absichtlich triggern**

1. Ungültiger Parameter: `-z` → `Unknown option -z`.
2. Kein Wert nach Flag: `-i` → `requires a value`.
3. Value ist Flag: `-i -o` → `requires a value, got a flag instead`.
4. Ungültige Masken: `aaa`, `rwxx` → Fehler.
5. Separator enthält `*`, `/` oder `.` → Fehler.
6. Input startet mit `/**/` → Fehler.
7. Private-Funktion direkt aufrufen → Fehler.

---

### **G. Spezielle Fälle**

* Eingabe enthält Pfade mit Leerzeichen → prüfen, dass alles korrekt normalisiert und expanded wird.
* Pfade mit versteckten Dateien (dotfiles) → `dotglob` prüft korrekt.
* Pfade mit Mix aus Dateien, Verzeichnissen, fehlenden → alles korrekt klassifiziert.
* Alle Arrays (`file`, `dir`, `file,missing`, etc.) korrekt initialisiert, auch bei leeren Gruppen.

---

## 2️⃣ Vorschlag: Bash-Testskript

```bash
#!/usr/bin/env bash

set -euo pipefail

# --- Hilfsfunktionen ---
mock_log_msg() {
  echo "$1: $2"
}

# Überschreibe log_msg
log_msg() { mock_log_msg "$@"; }

# Temporäre Dateien/Verzeichnisse für Tests
mkdir -p /tmp/test_classify_paths/dir1
touch /tmp/test_classify_paths/file1
rm -f /tmp/test_classify_paths/missing_file

# --- Tests ---
declare -A out

echo "Test 1: Kein Parameter"
if classify_paths -o out; then
    echo "❌ Fehler: sollte fehl schlagen"
else
    echo "✅ OK"
fi

echo "Test 2: Ungültige Berechtigung"
if classify_paths -i /tmp/test_classify_paths/file1 -p aaa -o out; then
    echo "❌ Fehler: ungültige Maske sollte Fehler"
else
    echo "✅ OK"
fi

echo "Test 3: Wildcard Expansion"
classify_paths -i "/tmp/test_classify_paths/*" -o out
echo "Gefundene Pfade: ${out[all]}"

echo "Test 4: Separieren existierende/fehlende"
classify_paths -i /tmp/test_classify_paths/file1 -i /tmp/test_classify_paths/missing_file -o out
echo "file: ${out[file]}"
echo "file,missing: ${out[file,missing]}"

echo "Test 5: Berechtigungen"
classify_paths -i /tmp/test_classify_paths/file1 -p r -p w -o out
echo "file,r: ${out[file,r]}"
echo "file,r,not: ${out[file,r,not]}"
echo "file,w: ${out[file,w]}"
echo "file,w,not: ${out[file,w,not]}"

# Cleanup
rm -rf /tmp/test_classify_paths
```
