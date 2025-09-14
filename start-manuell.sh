#!/bin/bash

# Manuelles Startskript für Backupprozess mit Live-Ausgabe und Logging

BACKUP_DIR="$HOME/Backup"
LOGFILE="$BACKUP_DIR/backup.log.$(date +%Y-%m-%d)"

"$BACKUP_DIR/backuperstellen.sh" | tee -a "$LOGFILE"

exit 0

