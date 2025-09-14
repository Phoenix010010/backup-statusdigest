#!/bin/bash

# Basisverzeichnis: aktuelles Arbeitsverzeichnis
BASE_DIR="$(pwd)"

# IP laden
RAPI_IP="$(cat "$BASE_DIR/last-ip.txt")"

# Verzeichnisse
LOG_DIR="$BASE_DIR/log"
STATUS_DIR="$BASE_DIR/status"
BACKUP_DIR="$BASE_DIR/backuperstellen"
REPO_PATH="$BASE_DIR/restic-repo"
STATUSFILE="$STATUS_DIR/backup-$RAPI_IP-status.txt"
LOGFILE="$LOG_DIR/backup-$RAPI_IP.log"

# Startzeit
echo "🟢 Backupstart $RAPI_IP: $(date)" > "$LOGFILE"
START_TIME=$(date +%s)

# Docker stoppen
echo "🚦 Docker stoppen..." >> "$LOGFILE"
docker compose -f "$BASE_DIR/paperless/docker-compose.yml" down || echo "⚠️ Docker konnte nicht gestoppt werden" >> "$LOGFILE"
sync
sleep 1
sudo pkill -f restic || true
sleep 5

# Restic vorbereiten
export RESTIC_PASSWORD_FILE="$BASE_DIR/.restic-passwort"
mkdir -p "$REPO_PATH"

# Backup starten
echo "📀 Starte restic-Backup lokal..." >> "$LOGFILE"
restic --no-cache --limit-upload 4194304 -r "$REPO_PATH" backup / \
  --exclude /proc --exclude /sys --exclude /dev \
  --exclude /run --exclude /tmp --exclude /mnt --exclude /media \
  --exclude /var/tmp --exclude /var/cache \
  --exclude "$BASE_DIR/.cache" \
  --exclude "$REPO_PATH" \
  --exclude /swapfile || echo "❌ restic Backup fehlgeschlagen" >> "$LOGFILE"
echo "✅ restic Backup abgeschlossen" >> "$LOGFILE"

# Snapshots bereinigen
restic -r "$REPO_PATH" forget --keep-within 7d --prune || echo "⚠️ Snapshot-Bereinigung fehlgeschlagen" >> "$LOGFILE"
echo "🧹 Alte Snapshots bereinigt" >> "$LOGFILE"

# Docker neu starten
echo "🐳 Docker-Container neu starten..." >> "$LOGFILE"
docker compose -f "$BASE_DIR/paperless/docker-compose.yml" up -d || echo "⚠️ Docker konnte nicht neu gestartet werden" >> "$LOGFILE"
echo "✅ Docker wieder aktiv" >> "$LOGFILE"

# Speicherinfos
USED_SPACE=$(du -sh "$REPO_PATH" 2>/dev/null | awk '{print $1}')
AVAILABLE_SPACE=$(df -h "$REPO_PATH" 2>/dev/null | awk 'NR==2 {print $4}')
SNAP_ID=$(restic -r "$REPO_PATH" snapshots --last --json 2>/dev/null | jq -r '.[0].short_id')
END_TIME=$(date +%s)
DELTA_TIME=$((END_TIME - START_TIME))

# Statusdatei schreiben
cat > "$STATUSFILE" <<EOF
📦 Backup $RAPI_IP abgeschlossen am $(date)
Snapshot-ID: ${SNAP_ID:-nicht verfügbar}
Startzeit: $(date -d @$START_TIME)
Dauer: $DELTA_TIME Sekunden
Genutzter Speicher: ${USED_SPACE:-nicht ermittelt}
Freier Speicher: ${AVAILABLE_SPACE:-nicht ermittelt}
EOF

echo "✅ $STATUSFILE wurde geschrieben" >> "$LOGFILE"
echo "✅ backup-$RAPI_IP.sh vollständig abgeschlossen: $(date)" >> "$LOGFILE"

# Ausgabe im Terminal
cat "$STATUSFILE"

