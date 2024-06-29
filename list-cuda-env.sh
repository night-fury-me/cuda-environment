#!/bin/bash

IMAGE_NAME="gpu-jupyter"

# Get list of containers based on the image name
CONTAINERS=$(docker ps -a --filter ancestor=${IMAGE_NAME} --format "table {{.Names}}\t{{.ID}}" | tail -n +2)

# Check if any containers were found
if [ -z "$CONTAINERS" ]; then
    echo "No environment found based on image ${IMAGE_NAME}."
else
    # Print header
    echo "----------------------------------------------"
    printf "%-30s | %s\n" "Name" "Id"
    echo "----------------------------------------------"

    # Print container information
    while read -r container_info; do
        container_name=$(echo "$container_info" | awk '{print $1}')
        container_id=$(echo "$container_info" | awk '{print $2}')
        printf "%-30s | %s\n" "$container_name" "$container_id"
    done <<< "$CONTAINERS"
    echo "----------------------------------------------"
fi
