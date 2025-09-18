# 📦 Backup Status Digest – Raspberry Pi & Fritzbox
 
Dieses Projekt bietet ein modulares Backup-System für Raspberry Pi-Geräte und eine Fritzbox-NAS. Es kombiniert Bash-, Batch-, VBS- und PowerShell-Skripte, um Backups lokal und remote durchzuführen – mit Fokus auf Automatisierung, Formatkompatibilität und Benutzerfreundlichkeit.

--------------------------------------------------------

## 🛠️ Voraussetzungen

- Raspberry Pi mit Bash
- Fritzbox mit NAS-Funktion
- Installierte Tools: `restic`, `dos2unix`, `cifs-utils`, `docker`
- Windows-PC mit Robocopy, PowerShell, VBS

---

## 📁 Projektstruktur

| Datei                     | Funktion                                                                 |
|--------------------------|--------------------------------------------------------------------------|
| `start-manuell.sh`       | Startet den Backup-Prozess mit Benutzerabfrage                           |
| `backup-rapi.sh`         | Führt das eigentliche Backup durch (Docker-Stop, Restic, Logging)        |
| `backuperstellen.sh`     | Koordiniert den Ablauf und erstellt Statusmeldungen                      |
| `statusdigest.sh`        | Erstellt eine Digest-E-Mail mit Backup-Status                            |
| `fritzbox-backup.sh`     | Mountet Fritzbox-Laufwerk und kopiert Dateien                            |
| `robocopy-sync-filtered.bat` | Kopiert nur geänderte `.sh`-Dateien zur Fritzbox                     |
| `robocopy-launcher.vbs`  | Startet das Robocopy-Skript im Hintergrund                               |
| `robocopy-gui.ps1`       | GUI zur Steuerung von Robocopy per Button                                |

---

## 🚀 Nutzung

1. `start-manuell.sh` ausführen  
2. IP-Adresse des Ziel-Raspberry eingeben  
3. Backup-Ziel wählen (Standard oder benutzerdefiniert)  
4. Passwort eingeben (für Restic)  
5. Backup wird gestartet, Container gestoppt, Dateien gesichert  
6. Digest-E-Mail wird erstellt

---

## 📧 Statusdigest

Die Status-E-Mail wird als HTML vorbereitet (noch in Entwicklung). Sie enthält:

- Backup-Zeitpunkt und Dauer  
- IP-Adresse und Zielverzeichnis  
- Speicherverbrauch und Restkapazität  
- Erfolg oder Fehlerstatus

---

## 🧠 Erweiterungen geplant

- HTML-Vorlage für Digest-Mail  
- Konfigurationsdatei (`config.sh` oder `.json`)  
- Logging-Verbesserungen  
- Fehlerbehandlung für `restic`, `docker`, `mount`

---

> Dieses Projekt ist Teil einer persönlichen Backup-Strategie für mehrere Raspberry Pis und eine Fritzbox-NAS. Ziel ist maximale Automatisierung bei minimaler Benutzerinteraktion.
