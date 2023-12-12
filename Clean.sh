#!/bin/bash

# WARNING: This script will permanently delete data from the database. 
# Please ensure you have a backup or have confirmed that this data can be safely removed.

# Prompt the user to enter connection information
read -p "Server address: " db_host
read -p "Database port: " db_port
read -p "Database name: " db_name
read -p "Username: " db_user
read -s -p "Password: " db_password
echo

export PGPASSWORD=$db_password

# Define the psql command with variables
psql_command="psql --host $db_host --port $db_port --username $db_user --dbname $db_name"

# Execute SQL queries
$psql_command <<EOF
DELETE FROM public.aircraft_history_entry WHERE id IN (
    SELECT x.id FROM public.aircraft_history_entry x
    WHERE history_event_id IN (
        SELECT x.id FROM public.aircraft_history_event x
        WHERE root_id IN (SELECT x.root_id FROM public.aircraft_artifact x)
    )
);

DELETE FROM public.aircraft_history_event WHERE id IN (
    SELECT x.id FROM public.aircraft_history_event x
    WHERE root_id IN (SELECT x.root_id FROM public.aircraft_artifact x)
);

DELETE FROM public.aircraft_updater_node WHERE object_id IN (
    SELECT x.object_id FROM public.aircraft_updater_node x
    WHERE root_id IN (SELECT x.root_id FROM public.aircraft_artifact x)
);

DELETE FROM public.aircraft_revision_node WHERE object_id IN (
    SELECT x.object_id FROM public.aircraft_revision_node x
    WHERE root_id IN (SELECT x.root_id FROM public.aircraft_artifact x)
);

DELETE FROM public.planning_event_node WHERE object_id IN (
    SELECT x.object_id FROM public.planning_event_node x
    WHERE root_id IN (SELECT x.root_id FROM public.aircraft_artifact x)
);

DELETE FROM public.mod_mp_node WHERE object_id IN (
    SELECT x.object_id FROM public.mod_mp_node x
    WHERE root_id IN (SELECT x.root_id FROM public.aircraft_artifact x)
);

DELETE FROM public.aircraft_drawing_validity WHERE ac_root_id IN (
    SELECT x.ac_root_id FROM public.aircraft_drawing_validity x
    WHERE ac_root_id IN (SELECT x.root_id FROM public.aircraft_artifact x)
);

DELETE FROM public.cb_node WHERE root_id IN (
    SELECT x.root_id FROM public.cb_node x
    WHERE root_id IN (SELECT x.root_id FROM public.aircraft_artifact x)
);

DELETE FROM public.r_aircraft_node_cb_node WHERE parent_node_id IN (
    SELECT x.parent_node_id FROM public.r_aircraft_node_cb_node x
    WHERE parent_node_id IN (SELECT x.node_id FROM public.aircraft_node x)
);

DELETE FROM public.r_aircraft_node_ext_spf_prod_site_acmm WHERE node_object_id IN (
    SELECT x.node_object_id FROM public.r_aircraft_node_ext_spf_prod_site_acmm x
    WHERE node_object_id IN (SELECT x.node_id FROM public.aircraft_node x)
);

DELETE FROM public.r_aircraft_node_ext_spf_prod_site_manual WHERE node_object_id IN (
    SELECT x.node_object_id FROM public.r_aircraft_node_ext_spf_prod_site_manual x
    WHERE node_object_id IN (SELECT x.node_id FROM public.aircraft_node x)
);

DELETE FROM public.r_aircraft_node_mod_mp_node WHERE parent_node_id IN (
    SELECT x.parent_node_id FROM public.r_aircraft_node_mod_mp_node x
    WHERE parent_node_id IN (SELECT x.node_id FROM public.aircraft_node x)
);

DELETE FROM public.r_aircraft_node_planning_event_node WHERE parent_node_id IN (
    SELECT x.parent_node_id FROM public.r_aircraft_node_planning_event_node x
    WHERE parent_node_id IN (SELECT x.node_id FROM public.aircraft_node x)
);

DELETE FROM public.r_aircraft_node_updater_node WHERE parent_node_id IN (
    SELECT x.parent_node_id FROM public.r_aircraft_node_updater_node x
    WHERE parent_node_id IN (SELECT x.node_id FROM public.aircraft_node x)
);

DELETE FROM public.aircraft_node WHERE object_id IN (
    SELECT x.object_id FROM public.aircraft_node x
    WHERE root_id IN (SELECT x.root_id FROM public.aircraft_artifact x)
);

DELETE FROM public.aircraft_artifact WHERE root_id IN (
    SELECT x.root_id FROM public.aircraft_artifact x
);

-- Commit la transaction
COMMIT;
EOF

# Destroy the environment variable
unset PGPASSWORD