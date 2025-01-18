#!/bin/bash

API_URL="https://www.api-couleur-tempo.fr/api/jourTempo/tomorrow"
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1329200579859451946/NBuLL9WJksAGy6VwvoGz9vUHx4kLiDzbxPKSMyS_gRpPBULwulfSg3lJMKrZ5RpI8idh"
TIME_ZONE="Europe/Paris"
LOG_FILE="/var/log/proxmox_tempo.log"

log() {
  local message="$1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOG_FILE"
}

send_discord_notification() {
  local color="$1"
  local description="$2"

  curl -X POST "$DISCORD_WEBHOOK_URL" \
    -H "Content-Type: application/json" \
    -d '{
      "embeds": [{
        "title": "Notification de votre serveur Proxmox",
        "description": "'"$description"'",
        "color": '"$color"'
      }]
    }' >> "$LOG_FILE" 2>&1
}

cancel_shutdown_tasks() {
  log "Annulation de toutes les tâches planifiées d'arrêt du serveur."
  atq | awk '{print $1}' | while read task_id; do
    atrm "$task_id" 2>>"$LOG_FILE"
    log "Tâche planifiée ID=$task_id annulée."
  done
}

main() {
  log "Début de l'exécution du script de vérification des couleurs Tempo."

  log "Envoi de la requête à l'API : $API_URL"
  response=$(curl -s -X GET "$API_URL" -H 'accept: application/json' 2>>"$LOG_FILE")

  if [ $? -ne 0 ]; then
    log "Erreur : Impossible de récupérer les données de l'API."
    send_discord_notification 0 "Erreur lors de la récupération des données de l'API."
    exit 1
  fi

  log "Réponse de l'API reçue : $response"

  code_jour=$(echo "$response" | jq -r '.codeJour')

  if [ "$code_jour" == "1" ]; then
    log "Demain est une journée bleue."
    send_discord_notification 3066993 "Demain est une journée bleue. Le serveur restera allumé."
    cancel_shutdown_tasks
  elif [ "$code_jour" == "2" ]; then
    log "Demain est une journée blanche."
    send_discord_notification 16776960 "Demain est une journée blanche. Le serveur restera allumé."
    cancel_shutdown_tasks
  elif [ "$code_jour" == "3" ]; then
    log "Demain est une journée rouge."
    send_discord_notification 15158332 "Demain est une journée rouge. Le serveur s'éteindra automatiquement à 6h du matin."

    log "Planification de l'arrêt du serveur à 6h demain matin."
    echo "sudo shutdown -h 06:00" | at 06:00 tomorrow 2>>"$LOG_FILE"
  else
    log "Erreur : le code de jour est inconnu ($code_jour)."
    send_discord_notification 0 "Erreur : le code de jour est inconnu dans la réponse de l'API."
  fi

  log "Fin de l'exécution du script."
}

export TZ="$TIME_ZONE"

if [ ! -f "$LOG_FILE" ]; then
  touch "$LOG_FILE"
  chmod 644 "$LOG_FILE"
fi

main
