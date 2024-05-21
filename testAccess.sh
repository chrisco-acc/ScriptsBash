#!/bin/bash

# Demander les informations de connexion
read -p "Server Address: " db_host
read -p "DB Port: " db_port
read -p "User Name: " db_user
read -s -p "Password: " db_password
echo

# Lister les bases de données avec un schéma public
echo "Fetching list of databases..."
databases=$(PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -U "$db_user" --list -t | grep 'public' | cut -d'|' -f1 | sed -e '/^\s*$/d')

echo "Verifying read access for $db_user on databases with public schema:"
echo

# Boucler sur chaque base de données et vérifier les privilèges de lecture
for db in $databases; do
    echo "Testing access to database: $db"

    # Récupérer la liste des tables du schéma public
    tables=$(PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -U "$db_user" -d "$db" -c "\dt public.*" | awk 'NR > 3 {if ($3 == "table") print $2}')

    if [ -z "$tables" ]; then
        echo "No accessible tables found in $db or no read permissions on public schema."
    else
        # Tenter de lire une ligne de chaque table
        for table in $tables; do
            echo "Fetching one row from table $table:"
            PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -U "$db_user" -d "$db" -c "SELECT * FROM public.$table LIMIT 1;"
            echo
        done
        echo "Read access verified for database $db."
    fi
    echo
done

echo "Verification complete."
