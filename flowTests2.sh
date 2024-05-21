#!/bin/bash

# Vérifie si le fichier CSV est fourni en argument
if [ $# -ne 2 ]; then
    echo "Usage: $0 <fichier_csv> <adresse_ip_a_inclure>"
    exit 1
fi

# Arguments
csv_file="$1"
ip_to_include="$2"

# Vérifie si le fichier CSV existe
if [ ! -f "$csv_file" ]; then
    echo "Le fichier CSV n'existe pas."
    exit 1
fi

# Vérifie si l'adresse IP à inclure est présente dans le fichier CSV
if ! grep -q "$ip_to_include" "$csv_file"; then
    echo "L'adresse IP à inclure n'a pas été trouvée dans le fichier CSV."
    exit 1
fi

# Lit le fichier CSV à partir de la ligne où l'adresse IP à inclure est trouvée
start_line=$(awk -v ip="$ip_to_include" '$0 ~ ip {print NR; exit}' "$csv_file")

# Extraction des noms d'hôtes et des adresses IP à partir du fichier CSV à partir de la ligne trouvée
hosts=$(awk -F',' -v start="$start_line" 'NR>=start {print $1}' "$csv_file")
ips=$(awk -F',' -v start="$start_line" 'NR>=start {print $2}' "$csv_file")

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
