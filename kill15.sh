#!/bin/bash

# Récupérer les processus Chrome
chrome_processes=$(ps aux | grep chrome)

# Date actuelle en secondes depuis l'époque Unix
current_time=$(date +%s)

# Initialisation d'une variable pour indiquer si des processus ont été trouvés
process_found=0

# Parcourir chaque ligne du résultat de la commande
while IFS= read -r line; do
    # Vérifier si la ligne correspond à un processus Chrome
    if [[ "$line" =~ .*chrome.* ]]; then
        # Récupérer le PID du processus
        pid=$(echo "$line" | awk '{print $2}')

        # Récupérer le temps écoulé depuis le démarrage du processus en secondes (colonne 10)
        elapsed_seconds=$(echo "$line" | awk '{split($10,a,":"); print a[1]*3600+a[2]*60+a[3]}')

        # Vérifier si le processus est en cours d'exécution depuis plus de 15 minutes (900 secondes)
        if [[ $elapsed_seconds -gt 900 ]]; then
            echo "Processus Chrome de plus de 15 minutes trouvé et tué avec PID $pid."
            kill "$pid"
            process_found=1
        fi
    fi
done <<< "$chrome_processes"

# Vérifier si aucun processus n'a été trouvé
if [[ $process_found -eq 0 ]]; then
    echo "Rien trouvé."
fi
