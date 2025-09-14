#!/bin/bash

# Manuelles Startskript für Backupprozess mit Auswahlmenü und Logging

echo "Was soll gesichert werden?"
echo "1) Nur ein Raspberry Pi sichern, auf den ich gerade arbeite"
echo "2) Abbrechen"
read -p "Bitte Auswahl eingeben [1-2]: " auswahl

case "$auswahl" in
  1)
    read -p "Bitte IP-Nr. eingeben (z. B. 192.168.178.32): " rapi
    
    # Zielverzeichnis
    LOGDIR="/backup.log"
    if [ -d "$LOGDIR" ]; then
      echo "✅ Verzeichnis $LOGDIR existiert bereits."
    else
      echo "📁 Verzeichnis $LOGDIR fehlt. Versuche es anzulegen..."
      mkdir -p "$LOGDIR"
      
      # Schritt 2: Nach mkdir erneut prüfen
      if [ -d "$LOGDIR" ]; then
        echo "✅ Verzeichnis $LOGDIR erfolgreich angelegt."
        LOGFILE="$LOGDIR/backup.log.$(date +%Y-%m-%d)"
      else
        echo "❌ Fehler: Konnte Verzeichnis $LOGDIR nicht anlegen. Breche ab."
        exit 0
      fi
    fi

    echo "Starte Backup von $rapi..."
    "./backuperstellen.sh" -a "$rapi" | tee -a "$LOGFILE"
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
"/statusdigest/statusdigest.sh"
STEP_END=$(date +%s)
echo "⏱️ Dauer Mailversand: $((STEP_END - STEP_START))s" >> "$LOGFILE"

exit 0
