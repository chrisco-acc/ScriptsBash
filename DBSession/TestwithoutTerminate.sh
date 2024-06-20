#!/bin/bash

# enter the connection information.
read -p "Server Address : " db_host
read -p "DB Port: " db_port
read -p "Database Name: " db_name
read -p "User Name : " db_user
read -s -p "Password: " db_password
echo

# Idle threshold in seconds.
IDLE_THRESHOLD=1

# Calculation of current timestamp and time threshold.
CURRENT_TIMESTAMP=$(date +%s)
TIME_THRESHOLD=$((CURRENT_TIMESTAMP - IDLE_THRESHOLD))

# SQL query to retrieve and terminate inactive sessions.
QUERY="SELECT pid, query FROM pg_stat_activity WHERE state = 'idle in transaction' AND state_change < now() - interval '$IDLE_THRESHOLD seconds';"

# Exécution 
SESSIONS_TO_TERMINATE=$(PGPASSWORD="$db_password" psql -U "$db_user" -d "$db_name" -h "$db_host" -p "$db_port" -t -c "$QUERY")

# Display of sessions to terminate.
echo "$SESSIONS_TO_TERMINATE"