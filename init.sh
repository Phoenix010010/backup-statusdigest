#!/bin/bash

# 🔧 Basisverzeichnis: aktuelles Arbeitsverzeichnis
BASE_DIR="$(pwd)"

# 🔧 Unterverzeichnisse definieren
RAPI_BACKUP_DIR="$BASE_DIR/backup-$RAPI_IP"
LOG_DIR="$BASE_DIR/log"
BACKUP_DIR="$BASE_DIR/backuperstellen"
STATUS_DIR="$BASE_DIR/status"
LATEST_FILE="$BASE_DIR/latest"

# 🔧 Funktion zur Verzeichnisprüfung und Erstellung
create_dir() {
  local DIR="$1"
  if [ -d "$DIR" ]; then
    echo "✅ Verzeichnis $DIR existiert bereits."
    sleep 2
  else
    echo "📁 Verzeichnis $DIR fehlt. Versuche es anzulegen..."
    mkdir -p "$DIR"
    sleep 2
    if [ -d "$DIR" ]; then
      echo "✅ Verzeichnis $DIR erfolgreich angelegt."
      sleep 2
    else
      echo "❌ Fehler: Konnte Verzeichnis $DIR nicht anlegen. Breche ab."
      exit 0
    fi
  fi
}

# 🔧 Alle benötigten Verzeichnisse prüfen und anlegen
create_dir "$RAPI_BACKUP_DIR"
create_dir "$LOG_DIR"
create_dir "$BACKUP_DIR"
create_dir "$STATUS_DIR"
create_dir "$LATEST_FILE"
