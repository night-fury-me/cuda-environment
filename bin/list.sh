#!/usr/bin/env bash

# Constants
IMAGE_NAME="gpu-jupyter"

usage() {
    echo "Usage: $0"
    echo "This script lists all running Docker containers based on the image '${IMAGE_NAME}'."
    exit 1
}

get_containers() {
    docker ps -a --filter ancestor="${IMAGE_NAME}" --format "table {{.Names}}\t{{.ID}}" | tail -n +2
}

print_containers() {
    local containers="$1"
    while read -r container_info; do
        container_name=$(echo "$container_info" | awk '{print $1}')
        container_id=$(echo "$container_info" | awk '{print $2}')
        printf "%-30s | %s\n" "$container_name" "$container_id"
    done <<< "$containers"
}

# Main script execution
main() {
    CONTAINERS=$(get_containers)

    if [ -z "$CONTAINERS" ]; then
        echo "No running environment found based on image ${IMAGE_NAME}."
    else
        echo "----------------------------------------------"
        printf "%-30s | %s\n" "Name" "Id"
        echo "----------------------------------------------"
        print_containers "$CONTAINERS"
        echo "----------------------------------------------"
    fi
}

# Run main function
main
