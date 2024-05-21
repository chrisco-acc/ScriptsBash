#!/bin/bash

echo "Récupération des labels pour le projet actuel."

# Fonction pour récupérer et afficher les labels pour une catégorie de ressources
afficher_labels() {
    local categorie=$1
    local namespace_flag=$2
    echo "Labels pour $categorie:"
    if [ "$namespace_flag" == "no-ns" ]; then
        oc get $categorie -o custom-columns=NAME:.metadata.name,LABELS:.metadata.labels
    else
        oc get $categorie -o custom-columns=NAME:.metadata.name,LABELS:.metadata.labels --all-namespaces
    fi
    echo "" # Ligne vide pour la séparation
}

# Appeler la fonction pour chaque catégorie de ressources
afficher_labels "dc" "ns"
afficher_labels "pods" "ns"
afficher_labels "rc" "ns"
afficher_labels "nodes" "no-ns"
afficher_labels "ns" "no-ns"
