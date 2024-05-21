#!/bin/bash

# Vérifie si le fichier CSV est fourni en argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <fichier_csv>"
    exit 1
fi

# Récupère l'adresse IP de la machine à partir de laquelle le script est exécuté
source_ip=$(hostname -I | awk '{print $1}')

# Argument
csv_file="$1"

# Vérifie si le fichier CSV existe
if [ ! -f "$csv_file" ]; then
    echo "Le fichier CSV n'existe pas."
    exit 1
fi

# Définir le chemin du fichier CSV de sortie pour les colonnes filtrées
filtered_output_file="filtered_$csv_file"

# Utiliser awk pour sélectionner et conserver uniquement les colonnes spécifiées
awk -F"," 'BEGIN {OFS=","} {print $3, $6, $7, $9}' "$csv_file" > "$filtered_output_file"

echo "Les colonnes ont été sélectionnées et le nouveau fichier est sauvegardé sous: $filtered_output_file"

# Trouve la première ligne contenant un chiffre
start_line=$(awk '$0 ~ /[0-9]/ {print NR; exit}' "$filtered_output_file")

# Extraction des noms d'hôtes, des adresses IP, et des ports à partir du fichier CSV filtré à partir de la ligne trouvée
hosts=$(awk -F',' -v start="$start_line" 'NR>=start && $0 ~ /[0-9]/ {print $1}' "$filtered_output_file")
ips=$(awk -F',' -v start="$start_line" 'NR>=start && $0 ~ /[0-9]/ {print $2}' "$filtered_output_file")
ports=$(awk -F',' -v start="$start_line" 'NR>=start && $0 ~ /[0-9]/ {print $4}' "$filtered_output_file")

# Nombre total d'éléments à tester
num_elements=$(echo "$hosts" | wc -l)

# Initialisation de la liste récapitulative des résultats
results=""

# Parcours chaque élément (nom d'hôte, adresse IP, et port) et teste la connexion avec curl
for ((i=1; i<=num_elements; i++)); do
    host=$(echo "$hosts" | sed -n "${i}p")
    ip=$(echo "$ips" | sed -n "${i}p")
    port=$(echo "$ports" | sed -n "${i}p")

    if [[ "$host" =~ [0-9] || "$ip" =~ [0-9] ]]; then
        # Test de connexion en utilisant curl
        curl --connect-timeout 5 --head --silent "$ip:$port" > /dev/null 2>&1

        # Vérifie le code de retour de curl
        if [ $? -eq 0 ]; then
            results+="\n$host ($ip) sur le port $port est accessible."
        else
            results+="\n$host ($ip) sur le port $port est inaccessible."
        fi
    fi
done

# Affiche la liste récapitulative des résultats
echo -e "Résultats des tests :$results"
