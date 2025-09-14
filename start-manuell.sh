#!/bin/bash

# Manuelles Startskript für Backupprozess mit Auswahlmenü und Logging

BACKUP_DIR="$HOME/Backup"
LOGFILE="$BACKUP_DIR/backup.log.$(date +%Y-%m-%d)"

echo "Was soll gesichert werden?"
echo "1) Nur ein Raspberry Pi sichern"
echo "2) Abbrechen"
read -p "Bitte Auswahl eingeben [1-2]: " auswahl

case "$auswahl" in
  1)
    read -p "Bitte IP-Nr. eingeben (z. B. 192.168.178.32): " rapi
    echo "Starte Backup von $rapi..."
    "$BACKUP_DIR/backuperstellen.sh" -a "$rapi" | tee -a "$LOGFILE"
    ;;
  2)
    echo "Abbruch durch Benutzer."
    exit 1
    ;;
  *)
    echo "Ungültige Eingabe."
    exit 1
    ;;
esac

# Status Digest E-Mail
echo "Die Status Digest E-Mail wird erstellt und der Versand wird vorbereitet..."
STEP_START=$(date +%s)
"$home/statusdigest/statusdigest.sh"
STEP_END=$(date +%s)
echo "⏱️ Dauer Mailversand: $((STEP_END - STEP_START))s" >> "$LOGFILE"

exit 0
