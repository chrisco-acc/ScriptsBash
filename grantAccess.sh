#!/bin/bash

# Demander les informations de connexion
read -p "Server Address: " db_host
read -p "DB Port: " db_port
read -p "User Name: " db_user
read -s -p "Password: " db_password
echo

# Demander le nom de l'utilisateur à qui donner les droits de lecture
read -p "Enter username to grant read access: " grant_user

# Lister les bases de données avec un schéma public
echo "Fetching list of databases..."
databases=$(PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -U "$db_user" --list -t | grep 'public' | cut -d'|' -f1 | sed -e '/^\s*$/d')

echo "List of databases available on the server with public schema:"
echo "$databases"
echo

# Boucler sur chaque base de données et accorder les privilèges de lecture
echo "Granting read access to $grant_user on all databases with a public schema..."
for db in $databases; do
    PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -U "$db_user" -d "$db" -c "GRANT USAGE ON SCHEMA public TO $grant_user;"
    PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -U "$db_user" -d "$db" -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO $grant_user;"
    PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -U "$db_user" -d "$db" -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO $grant_user;"
done

echo "Read permissions granted."
