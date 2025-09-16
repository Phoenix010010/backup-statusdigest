#!/bin/bash

# 🔧 Konfiguration
BASE_DIR="$(pwd)"
LOG_DIR="$BASE_DIR/log"
LOGFILE="$LOG_DIR/backup.log"
REPO_DIR="$BASE_DIR/restic-repo"

mkdir -p "$LOG_DIR"

# 🔐 Passwort-Eingabe mit Bestätigungsschleife
while true; do
  echo "🔐 Bitte Passwort für Restic eingeben:"
  read -s PASSWORD1

  if [ -z "$PASSWORD1" ]; then
    echo "❌ Passwort darf nicht leer sein."
    continue
  fi

  echo "🔐 Bitte Passwort erneut eingeben:"
  read -s PASSWORD2

  if [ "$PASSWORD1" != "$PASSWORD2" ]; then
    echo "❌ Passwörter stimmen nicht überein. Bitte erneut versuchen."
    continue
  fi

  export RESTIC_PASSWORD="$PASSWORD1"
  break
done

# 🐳 Docker-Container stoppen
RUNNING_CONTAINERS=$(docker ps -q)

if [ -n "$RUNNING_CONTAINERS" ]; then
  echo "🚦 Stoppe laufende Container..." >> "$LOGFILE"
  for CONTAINER in $RUNNING_CONTAINERS; do
    docker stop "$CONTAINER" >> "$LOGFILE"
  done
else
  echo "ℹ️ Keine laufenden Container gefunden – Backup läuft ohne Docker-Stopp." >> "$LOGFILE"
fi

# 📦 Backup mit restic
if ! command -v restic &> /dev/null; then
  echo "❌ restic ist nicht installiert. Backup wird übersprungen." >> "$LOGFILE"
  exit 1
fi

restic -r "$REPO_DIR" backup "$BASE_DIR" >> "$LOGFILE"

# 🔧 Dos2Unix auf .sh-Dateien
find "$BASE_DIR" -name "*.sh" -type f -exec dos2unix {} \; >> "$LOGFILE"

# 📧 Digest-Mail erstellen (einmalig)
if [ ! -f "$LOG_DIR/digest-sent.flag" ]; then
  ./statusdigest.sh
  touch "$LOG_DIR/digest-sent.flag"
fi

# 📝 Abschluss
echo "✅ Backup abgeschlossen um $(date)" >> "$LOGFILE"
echo "Backup abgeschlossen um $(date)" > "$LOG_DIR/latest.txt"
