#!/bin/bash

usage() {
    echo "Usage:"
    echo "  $0 CONTAINER_ID [CONTAINER_ID2 ...] [--force]"
    echo "  $0 --all"
    exit 1
}

IMAGE_NAME="gpu-jupyter"

is_container_running() {
    local container_id="$1"
    docker inspect -f '{{.State.Running}}' "$container_id" 2>/dev/null || echo "false"
}

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

    # Remove containers
    for container_id in "${containers[@]}"; do
        if [ "$force_flag" == false ]; then
            running=$(is_container_running "$container_id")
            if [ "$running" == "false" ]; then
                docker rm "$container_id" > /dev/null 2>&1
            else
                running_containers+=("$container_id")
            fi
        else
            docker rm -f "$container_id" > /dev/null 2>&1
        fi
    done

    # Print guideline for --force command if any containers were not removed
    if [ "$force_flag" == false ] && [ ${#running_containers[@]} -gt 0 ]; then
        echo "Some containers were not removed because they are still in a running state."
        echo "To force remove, use the following command:"
        echo "cuda-env remove [CONTAINER_NAME_1 CONTAINER_NAME_2 ...] OR [--all] --force"
        echo "You can deactivate first using: cuda-env deactivate [CONTAINER_NAME] and then try remove."
    fi
}

# Main script logic
if [ "$#" -lt 1 ]; then
    usage
fi

remove_containers "$@"
