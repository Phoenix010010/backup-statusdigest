#!/bin/bash

# Manuelles Startskript für Backupprozess mit Auswahlmenü und Logging

echo "Was soll gesichert werden?"
echo "1) Nur ein Raspberry Pi sichern, auf den ich gerade arbeite"
echo "2) Abbrechen"
read -p "Bitte Auswahl eingeben [1-2]: " auswahl

case "$auswahl" in
  1)
    read -p "Bitte IP-Nr. eingeben (z.B. 192.168.178.32): " RAPI_IP
    if [[ ! "$RAPI_IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
      echo "❌ Ungültige IP-Adresse: $RAPI_IP"
      exit 1
    fi
    echo "$RAPI_IP" > ./log/last-ip.txt

    # Arbeitsverzeichnisse anlegen
    ./init.sh "$RAPI_IP"   
    
    LOGFILE="$LOGDIR/backup.log.$(date +%Y-%m-%d)"
    
    echo "Starte Backup von $RAPI_IP..."
    ./backuperstellen.sh "$RAPI_IP" | tee -a "$LOGFILE"
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
./statusdigest.sh
STEP_END=$(date +%s)
echo "⏱️ Dauer Mailversand: $((STEP_END - STEP_START))s" >> "$LOGFILE"

exit 0
