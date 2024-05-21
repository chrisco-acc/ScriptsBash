#!/bin/bash

# List of Namespaces
namespaces=("2h10-v" "2h10-q")

# Loop for each namespace
for namespace in "${namespaces[@]}"; do
    echo "Namespace: $namespace"

    # Retrieve pod names starting with "gtsi-svc-test-design"
    pod_names=$(oc get pods -n "$namespace" | awk '$1 ~ /^gtsi-svc-test-design/{print $1}')

    # Loop through each pod
    for pod in $pod_names; do
        echo "Pod: $pod"

        # Retrieve the ID of the pod
        pod_id=$(oc get pod "$pod" -n "$namespace" -o jsonpath='{.metadata.uid}')

        if [ -z "$pod_id" ]; then
            echo "Le pod $pod n'a pas été trouvé dans le namespace $namespace."
            continue
        fi

        # Retrieve information about Chromium processes in the pod
        chromium_processes=$(oc exec "$pod" -n "$namespace" -- ps aux | grep chromium)

        # Current date and time
        now=$(date '+%s')

        # Variable to indicate if processes were found
        process_found=0

        # Loop through each line of Chromium processes output
        while IFS= read -r line; do
            # Get the PID
            pid=$(echo "$line" | awk '{print $2}')

            # Get the start time (column 9)
            start_time=$(echo "$line" | awk '{print $9}')

            # Convert start time to timestamp
            start_timestamp=$(date -d "$start_time" '+%s')

            # Calculate elapsed time in seconds since process start
            elapsed_time=$((now - start_timestamp))

            # Convert to hours
            elapsed_hours=$((elapsed_time / 3600))

            # Check if the process is older than 4 hours
            if [[ $elapsed_hours -ge 4 ]]; then
                echo "Killing process with PID: $pid (Elapsed time: $elapsed_hours hours)"
                oc exec "$pod" -n "$namespace" -- kill "$pid"
                process_found=1
            fi
        done <<< "$chromium_processes"

        # Check if no processes were found
        if [[ $process_found -eq 0 ]]; then
            echo "No Chromium processes older than 4 hours found in pod $pod."
        fi
    done
done
