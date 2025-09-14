# Anlegen der Benötigten Unterverzeichnisse

$Verz=./log
  ./backuperstellen
  ./backup-<IP>
  ./status
  ./latest

LOGDIR="./log"
if [ -d "$LOGDIR" ]; then
  echo "✅ Verzeichnis $LOGDIR existiert bereits."
else
  echo "📁 Verzeichnis $LOGDIR fehlt. Versuche es anzulegen..."
  mkdir -p "$LOGDIR"
      
  # Schritt 2: Nach mkdir erneut prüfen
  if [ -d "$LOGDIR" ]; then
    echo "✅ Verzeichnis $LOGDIR erfolgreich angelegt."        
  else
    echo "❌ Fehler: Konnte Verzeichnis $LOGDIR nicht anlegen. Breche ab."
    exit 0
  fi
fi
