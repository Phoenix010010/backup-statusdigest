# backup-statusdigest
Backup- und Status-Digest-System für Raspberry Pi mit HTML-Mailversand

Komplett über KI(Copilot von MS) generiert

## Projektstruktur
- `start-manuell.sh` – Einstiegspunkt für den Backup-Prozess
- `backuperstellen.sh` – erzeugt lokale und remote Backups
- `generate-digest.sh` – erstellt HTML-Statusübersicht
- `send-digest.sh` – versendet HTML-Mail
- `statusdigest.html` – HTML-Vorlage
- `statusdigest.css` – Stylesheet für Digest
- `backup-rapi.sh` – erstellt das Backup auf dem Pi
- `init.sh` – wird benutzt um benötigte Unterverzeichnisse zu erstellen

## Besonderheiten
lfd. Docker Container werden gestoppt und wieder gestartet

Folgende Ordner erhalten kein Backup: 

	/proc /swapfile /sys /dev /run /tmp /mnt /media /var/tmp /var/cache /.cache /"Eigener_Pfad" 

	Für später ist noch eine explizite Ordnerauswahl geplant! 
