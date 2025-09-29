Ich möchte ein Bash Script Schreiben das Dateien, und oder Ordner anlegt
Flags:
  - direcory
  - file
  - depth
  - exists "default = der neuen Datei ein suffiy geben"
  - suffix "default = _(count)"

1) "direcory" & "file" sind selbst erklärend
2) Wenn "direcory" oder "file" schon Da sind, soll "exists" bestimmen was passieren soll.
  - 1) Überschreiben
  - 2) Der neunen Datei/Ordner ein "Suffix" anhängen
  - 3) Dem schon Vorhandenen Datei/Ordner ein "Suffix" anhängen
3) Wenn "directory" NICHT Exestiert soll "depth" prüfen wie weit man zurück gehen darf um ihn zu erstellen.
  - z.b. depth=1 Parrent
  - z.b. depth=2 Grand Parrent

4) Standart mäßig bestimmte "direcory" & "file" Sperren z.b. /etc /var
