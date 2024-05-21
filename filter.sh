#!/bin/bash

# Définir le chemin du fichier CSV d'entrée et de sortie
input_file="test.csv"
output_file="result.csv"


# Utiliser awk pour sélectionner et conserver uniquement les colonnes spécifiées
awk -F"," 'BEGIN {OFS=","} {print $3, $6, $7, $9}' "$input_file" > "$output_file"

echo "Les colonnes ont été sélectionnées et le nouveau fichier est sauvegardé sous: $output_file"


