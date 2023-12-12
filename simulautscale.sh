#!/bin/bash

# Récupère la liste de tous les DeploymentConfigs
readarray -t deployment_configs < <(oc get dc | awk 'NR>1 {print $1}')

# Fonction pour afficher la commande de scale sans l'exécuter
simulate_scale_deployment_config() {
    local dc_name=$1
    local replicas=$2

    # Affiche la commande plutôt que de l'exécuter
    echo "Simulate: Scaling $dc_name à $replicas réplicas..."
}

selected_indices=()
while true; do
    clear
    echo "Sélectionnez les DeploymentConfigs (Entrez le numéro du DeploymentConfig ou 'q' pour terminer) :"
    for i in "${!deployment_configs[@]}"; do
        if [[ " ${selected_indices[@]} " =~ " ${i} " ]]; then
            echo -e "\e[32m$i) [X] ${deployment_configs[$i]}\e[0m"
        else
            echo -e "\e[31m$i) [ ] ${deployment_configs[$i]}\e[0m"
        fi
    done

    read -p "Choix : " choice
    if [[ $choice =~ ^[0-9]+$ ]] && [ $choice -ge 0 ] && [ $choice -lt ${#deployment_configs[@]} ]; then
        if [[ " ${selected_indices[@]} " =~ " ${choice} " ]]; then
            new_selected_indices=()
            for index in "${selected_indices[@]}"; do
                if [ "$index" != "$choice" ]; then
                    new_selected_indices+=("$index")
                fi
            done
            selected_indices=("${new_selected_indices[@]}")
        else
            selected_indices+=("$choice")
        fi
    elif [ "$choice" = "q" ]; then
        break
    else
        echo "Entrée invalide."
    fi
done

echo "DeploymentConfigs sélectionnés :"
for i in "${selected_indices[@]}"; do
    echo "${deployment_configs[i]}"
done

# Simule le scale des DeploymentConfigs sélectionnés
for index in "${selected_indices[@]}"; do
    dc_name=${deployment_configs[index]}
    echo "Entrez le nombre de réplicas pour le DeploymentConfig $dc_name (0 pour arrêter) :"
    read replicas
    while [[ ! $replicas =~ ^[0-9]+$ ]]; do
        echo "Entrée invalide. Veuillez entrer un nombre."
        read replicas
    done
    simulate_scale_deployment_config "$dc_name" "$replicas"
done

echo "Opérations simulées terminées."
