#!/bin/bash

# En-tête du tableau
printf "%-40s %-10s %-10s\n" "POD" "CPU(cores)" "MEM(MiB)"

# Récupération de la liste des pods dans le namespace actuel
PODS=$(oc get pods --no-headers -o custom-columns=":metadata.name")

# Boucle à travers tous les pods pour obtenir les ressources utilisées
for POD in $PODS; do
    # Récupération de l'utilisation des ressources pour le pod actuel
    CPU_USAGE=$(oc adm top pod $POD --no-headers | awk '{print $2}')
    MEM_USAGE=$(oc adm top pod $POD --no-headers | awk '{print $3}')

    # Affichage des informations dans le tableau
    printf "%-40s %-10s %-10s\n" $POD $CPU_USAGE $MEM_USAGE
done
