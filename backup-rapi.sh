#!/bin/bash

# Basisverzeichnis: aktuelles Arbeitsverzeichnis
BASE_DIR="$(pwd)"

# IP laden
RAPI_IP="$(cat "$BASE_DIR/last-ip.txt")"

# Verzeichnisse
LOG_DIR="$BASE_DIR/log"
USER_DIR="$BASE_DIR/restic-repo"
STATUSFILE="$LOG_DIR/backup-$RAPI_IP-status.txt"
LOGFILE="$LOG_DIR/backup-$RAPI_IP.log"

# Startzeit
echo "🟢 Backupstart $RAPI_IP: $(date)" > "$LOGFILE"
START_TIME=$(date +%s)

# 🔍 Laufende Container sichern
RUNNING_CONTAINERS=$(docker ps -q)

if [ -n "$RUNNING_CONTAINERS" ]; then
  echo "🚦 Stoppe laufende Container..." >> "$logfile"
  for CONTAINER in $RUNNING_CONTAINERS; do
    docker stop "$CONTAINER" >> "$logfile"
  done
else
  echo "ℹ️ Keine laufenden Container gefunden – Backup läuft ohne Docker-Stopp." >> "$logfile"
fi

while true; do
  echo "📁 Wohin soll das Backup gespeichert werden?"
  echo "1) Standardverzeichnis: $BASE_DIR/restic-repo"
  echo "2) Eigenes Verzeichnis angeben"
  read -p "Bitte Auswahl eingeben [1-2]: " zielwahl

  case "$zielwahl" in
    1)
      USER_DIR="$BASE_DIR/restic-repo"
      ;;
    2)
      read -p "Pfad zum Backup-Ziel eingeben: " benutzer_pfad
      USER_DIR="$benutzer_pfad"
      ;;
    *)
      echo "❌ Ungültige Eingabe – Abbruch."
      exit 1
      ;;
  esac

  if [ -d "$USER_DIR" ]; then
    echo "✅ Backup-Ziel $USER_DIR ist vorhanden."
    break
  else
    echo "❌ Verzeichnis $USER_DIR existiert nicht oder ist nicht erreichbar."
    echo "🔁 Bitte Pfad prüfen oder erneut auswählen."
  fi
done

echo " "
echo "Bitte Passwort eingeben! (Sonderzeichen auch möglich!)"
echo "Sollte das PW mit einem gespeicherten Backup übereinstimmen, so werden nur die geänderten Dateien gespeichert!"
echo "Achtung! Falls es ein neues Passwort ist, wird ein neues Backup erstellt! Dauert je nach Größe!"
echo "🔐 Hinweis:"
echo "Achte darauf, dass du es dir SICHER merkst – es kann NICHT wiederhergestellt werden!"
echo "🔐 Bitte Passwort für das neue/gespeicherte Backup eingeben:"
read -s RESTIC_PASSWORD
export RESTIC_PASSWORD

# Prüfen, ob das Repository existiert
if [ ! -d "$USER_DIR" ] || [ ! -f "$USER_DIR/config" ]; then
  INIT_REPO=true
else
  INIT_REPO=false
fi

# Speicherplatz ermitteln
source_space=$(df -BG / | awk 'NR==2 {print $3}' | sed 's/G//')
target_space=$(df -BG "$USER_DIR" | awk 'NR==2 {print $4}' | sed 's/G//')

if [ "$INIT_REPO" = true ]; then
  echo "⚠️ Neues Backup wird erstellt."
  echo "📦 Dein System belegt aktuell ca. ${source_space} GB."
  echo "💾 Zielsystem hat ${target_space} GB freien Speicher."
  if [ "$target_space" -lt "$source_space" ]; then
    echo "❌ Nicht genug Speicherplatz verfügbar: mindestens ${source_space} GB benötigt."
    echo "❓ Backup abbrechen (j/n)?"
    read -r abbrechen
    if [ "$abbrechen" = "j" ]; then
      echo "🚫 Backup abgebrochen."
      exit 1
    fi
  fi
  restic -r "$USER_DIR" init || { echo "❌ Fehler beim Initialisieren des Repositories."; exit 1; }
else
  # Passwortprüfung für bestehendes Repository
  restic -r "$USER_DIR" snapshots > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "❌ Passwort falsch oder Repository beschädigt."
    echo "❓ Nochmal versuchen (j/n)?"
    read -r retry
    if [ "$retry" = "j" ]; then
      exit 1
    else
      echo "🚫 Backup abgebrochen."
      exit 1
    fi
  fi
  echo "📦 Delta-Backup wird ausgeführt."
  echo "📊 Dein System belegt aktuell ca. ${source_space} GB."
  echo "💾 Zielsystem hat ${target_space} GB freien Speicher."
fi

echo "📀 Starte Backup " >> "$logfile"

restic --no-cache --limit-upload 4194304 --verbose=2 -r "$USER_DIR" backup / \
  --exclude /proc \
  --exclude /sys \
  --exclude /dev \
  --exclude /run \
  --exclude /tmp \
  --exclude /mnt \
  --exclude /media \
  --exclude /var/tmp \
  --exclude /var/cache \
  --exclude "$BASE_DIR/.cache" \
  --exclude "$USER_DIR" \
  --exclude /swapfile \
  | tee -a "$logfile"

if [ "${PIPESTATUS[0]}" -ne 0 ]; then
  echo "❌ restic Backup fehlgeschlagen" >> "$logfile"
else
  echo "✅ restic Backup abgeschlossen" >> "$logfile"
fi

# 🐳 Container nach Backup wieder starten
if [ ${#RUNNING_CONTAINERS[@]} -gt 0 ]; then
  echo "🔄 Starte zuvor gestoppte Container..." >> "$logfile"
  docker start "${RUNNING_CONTAINERS[@]}" >> "$logfile"
  echo "✅ Container erfolgreich neu gestartet." >> "$logfile"
else
  echo "ℹ️ Keine Container zum Neustart vorhanden." >> "$logfile"
fi

# Speicherinfos
USED_SPACE=$(du -sh "$USER_DIR" 2>/dev/null | awk '{print $1}')
AVAILABLE_SPACE=$(df -h "$USER_DIR" 2>/dev/null | awk 'NR==2 {print $4}')
SNAP_ID=$(restic -r "$USER_DIR" snapshots --last --json 2>/dev/null | jq -r '.[0].short_id')
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

