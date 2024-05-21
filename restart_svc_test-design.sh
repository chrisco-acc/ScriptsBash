#!/bin/bash

# Nom du DeploymentConfig
dc_name="svc-test-design"
# Namespace cible
namespace="gggg-v"
# Nombre de réplicas à restaurer après le scaling down
replicas_to_restore=1

# Se connecter au bon namespace
oc project $namespace

# Obtenir le nombre actuel de réplicas
current_replicas=$(oc get dc $dc_name -o jsonpath='{.status.replicas}')

echo "Nombre actuel de réplicas pour $dc_name: $current_replicas"

# Scaling down à 0
echo "Scaling down $dc_name à 0 réplicas..."
oc scale dc/$dc_name --replicas=0

# Attendre que les pods soient complètement arrêtés
echo "Attente de l'arrêt complet des pods..."
oc wait --for=delete pod -l deploymentconfig=$dc_name --timeout=120s

# Scaling up au nombre de réplicas initial ou à un autre nombre prédéfini
echo "Scaling up $dc_name à $replicas_to_restore réplicas..."
oc scale dc/$dc_name --replicas=$replicas_to_restore

echo "Scaling terminé pour $dc_name."
