#!/bin/bash

# Backuperstellung für Raspberry Pi mit Logging und Dateinamensstruktur

RAPI_IP="$1"
if [ -z "$RAPI_IP" ]; then
  echo "❌ Keine IP-Adresse übergeben. Bitte mit: backuperstellen.sh <IP>"
  exit 1
fi

# Zeitstempel einmalig setzen
TIMESTAMP="$(date +%Y-%m-%d-%H-%M-%S)"
BACKUP_DIR="./"

STATUSFILE="$BACKUP_DIR/backuperstellen-status-$RAPI_IP-$TIMESTAMP.txt"
LOGFILE="$BACKUP_DIR/backup.log-$RAPI_IP-$TIMESTAMP"

log() {
  echo "$1" | tee -a "$STATUSFILE"
}

log "🟢 Backup-Prozess gestartet für $RAPI_IP um $TIMESTAMP"
START_TIME=$(date +%s)

# Lokales Backup
log "📁 Starte lokales Backup von $RAPI_IP"
STEP_START=$(date +%s)
"$BACKUP_DIR/backup-rapi.sh" "$RAPI_IP"
STEP_END=$(date +%s)
echo "⏱️ Dauer Lokales Backup: $((STEP_END - STEP_START))s" >> "$STATUSFILE"

# Digest-Mail
log "✉️ Digest-E-Mail wird erstellt"
STEP_START=$(date +%s)
$home/statusdigest/statusdigest.sh
STEP_END=$(date +%s)
echo "⏱️ Dauer Mailversand: $((STEP_END - STEP_START))s" >> "$STATUSFILE"

#Ende des Backups wird geloggt
END_TIME=$(date +%s)
log "✅ Backup abgeschlossen um $(date +%Y-%m-%d-%H-%M-%S)"
log "🕒 Gesamtzeit: $((END_TIME - START_TIME))s"

# Dateiname in latest.txt speichern
echo "$STATUSFILE" >> "$BACKUP_DIR/latest.txt"

exit 0
