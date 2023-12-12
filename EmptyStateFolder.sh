#!/bin/bash

# Retrieve the list of pods containing 'stream'
readarray -t pods < <(oc get pods | grep "stream" | awk '{print $1}')

selected_indices=()
while true; do
    clear
    echo "Select pods (Enter the pod number or 'q' to finish):"
    for i in "${!pods[@]}"; do
        if [[ " ${selected_indices[@]} " =~ " ${i} " ]]; then
            echo -e "\e[32m$i) [X] ${pods[$i]}\e[0m"
        else
            echo -e "\e[31m$i) [ ] ${pods[$i]}\e[0m"
        fi
    done

    read -p "Choice: " choice
    if [[ $choice =~ ^[0-9]+$ ]] && [ $choice -ge 0 ] && [ $choice -lt ${#pods[@]} ]; then
        if [[ " ${selected_indices[@]} " =~ " ${choice} " ]]; then
            # Create a new temporary array
            new_selected_indices=()
            for index in "${selected_indices[@]}"; do
                if [ "$index" != "$choice" ]; then
                    new_selected_indices+=("$index")
                fi
            done
            # Reassign the temporary array to selected_indices
            selected_indices=("${new_selected_indices[@]}")
        else
            selected_indices+=("$choice")
        fi
    elif [ "$choice" = "q" ]; then
        if [ "${#selected_indices[@]}" -lt 2 ]; then
            echo "You must select at least two pods."
            sleep 1
        else
            break
        fi
    else
        echo "Invalid entry."
    fi
done

echo "Selected pods:"
for i in "${selected_indices[@]}"; do
    echo "${pods[i]}"
done

# Execute the command on the selected pods
for index in "${selected_indices[@]}"; do
    pod_name=${pods[index]}
    echo "Executing 'rm -rfv state' on the pod $pod_name..."
    oc exec "$pod_name" -- rm -rfv state

    echo "Checking that the 'state' folder is empty on the pod $pod_name..."
    if oc exec "$pod_name" -- ls state; then
        echo "The 'state' folder is not empty on the pod $pod_name."
    else
        echo "The 'state' folder is empty on the pod $pod_name."
    fi
done

echo "Operations completed."
