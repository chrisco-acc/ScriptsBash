#!/bin/bash

# Vérifie si le fichier CSV est fourni en argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <fichier_csv>"
    exit 1
fi

# Nom du fichier CSV
csv_file="$1"

# Extraction des noms d'hôtes et des adresses IP à partir du fichier CSV
hosts=$(awk -F',' '{print $1}' "$csv_file")
ips=$(awk -F',' '{print $2}' "$csv_file")


# Nombre total d'éléments à tester
num_elements=$(echo "$hosts" | wc -l)

# Initialisation de la liste récapitulative des résultats
results=""

# Parcours chaque élément (nom d'hôte et adresse IP) et teste la connexion avec curl
for ((i=1; i<=num_elements; i++)); do
    host=$(echo "$hosts" | sed -n "${i}p")
    ip=$(echo "$ips" | sed -n "${i}p")

    # Test de connexion en utilisant curl
    curl --connect-timeout 5 --head --silent "$ip" > /dev/null 2>&1

    # Vérifie le code de retour de curl
    if [ $? -eq 0 ]; then
        results+="\n$host ($ip) est accessible."
    else
        results+="\n$host ($ip) est inaccessible."
    fi
done

# Affiche la liste récapitulative des résultats
echo -e "Résultats des tests :$results"
