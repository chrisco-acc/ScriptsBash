#!/bin/bash

# Récupérer les processus Chrome
chrome_processes=$(ps aux | grep chrome)

# Date et heure actuelles
now=$(date '+%s')

# Variable pour indiquer si des processus ont été trouvés
process_found=0

# Parcourir chaque ligne du résultat de la commande
while IFS= read -r line; do
    # Vérifier si la ligne correspond à un processus Chrome
    if [[ "$line" =~ .*chrome.* ]]; then
        # Récupérer le PID du processus
        pid=$(echo "$line" | awk '{print $2}')

        # Récupérer la date de démarrage du processus (colonne 9)
        start_time=$(echo "$line" | awk '{print $9}')

        # Convertir la date de démarrage en timestamp
        start_timestamp=$(date -d "$start_time" '+%s')

        # Calculer le temps écoulé en secondes depuis le démarrage du processus
        elapsed_time=$((now - start_timestamp))

        # Convertir le temps écoulé en heures
        elapsed_hours=$((elapsed_time / 3600))

        # Vérifier si le processus a plus de 4 heures
        if [[ $elapsed_hours -ge 4 ]]; then
            echo "Processus Chrome de plus de 4 heures trouvé et tué avec PID $pid."
            kill "$pid"
            process_found=1
        fi
    fi
done <<< "$chrome_processes"

# Vérifier si aucun processus n'a été trouvé
if [[ $process_found -eq 0 ]]; then
    echo "Aucun processus Chrome de plus de 4 heures trouvé."
fi
