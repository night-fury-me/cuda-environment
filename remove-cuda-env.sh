#!/bin/bash

# Function to display usage
usage() {
    echo "Usage:"
    echo "  $0 CONTAINER_ID [CONTAINER_ID2 ...] [--force]"
    echo "  $0 --all"
    exit 1
}

IMAGE_NAME="gpu-jupyter"

# Function to check if a container is running
is_container_running() {
    local container_id="$1"
    docker inspect -f '{{.State.Running}}' "$container_id" 2>/dev/null || echo "false"
}

# Function to remove containers
remove_containers() {
    local force_flag=false
    local all_flag=false
    local containers=()
    local not_running_containers=()

    # Parse command-line arguments
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --force)
                force_flag=true
                shift
                ;;
            --all)
                all_flag=true
                shift
                ;;
            *)
                containers+=("$1")
                shift
                ;;
        esac
    done

    # Handle case where --all is provided
    if [ "$all_flag" == true ]; then
        containers=($(docker ps -a --filter ancestor=${IMAGE_NAME} --format "{{.ID}}"))
    fi

    # Remove containers not in running state (only if --force is provided)
    if [ "$force_flag" == false ]; then
        for container_id in "${containers[@]}"; do
            running=$(is_container_running "$container_id")
            if [ "$running" == "false" ]; then
                docker rm "$container_id" > /dev/null 2>&1
                if [ $? -ne 0 ]; then
                    not_running_containers+=("$container_id")
                fi
            fi
        done

        # Print guideline for --force command if any containers were not removed
        if [ ${#not_running_containers[@]} -gt 0 ]; then
            echo "Some containers were not removed because they are still in a running state."
            echo "To force remove, use the following command:"
            echo "$0 --all --force"
        fi
    else
        for container_id in "${containers[@]}"; do
            running=$(is_container_running "$container_id")
            docker rm -f "$container_id" > /dev/null 2>&1
        done
    fi
}

# Main script logic
if [ "$#" -lt 1 ]; then
    usage
fi

remove_containers "$@"

