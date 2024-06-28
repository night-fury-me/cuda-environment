#!/bin/bash

# Function to display usage
usage() {
    echo "Usage:"
    echo "  $0 create [--name CONTAINER_NAME] [--port HOST_MACHINE_PORT] [--mount MOUNTING_PATH]"
    echo "  $0 list-envs"
    echo "  $0 remove CONTAINER_NAME [CONTAINER_NAME_1 CONTAINER_NAME_2 ...] [--force]"
    exit 1
}

# Check if the correct number of arguments are provided
if [ "$#" -lt 1 ]; then
    usage
fi

remove_containers() {
    local force_flag=""
    local container_ids=()

    # Parse command-line arguments
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --force)
                force_flag="--force"
                shift
                ;;
            *)
                container_ids+=("$1")
                shift
                ;;
        esac
    done

    # Call remove-cuda-env.sh with all container IDs
    if [ "$force_flag" == "--force" ]; then
        ~/.custom-scripts/remove-cuda-env.sh "${container_ids[@]}" --force
    else
        ~/.custom-scripts/remove-cuda-env.sh "${container_ids[@]}"
    fi
}

# Determine which subcommand to execute
case "$1" in
    create)
        shift
        CONTAINER_NAME=""
        HOST_MACHINE_PORT=""
        MOUNTING_PATH=""

        # Parse optional parameters for create command
        while [[ "$#" -gt 0 ]]; do
            case $1 in
                --name)
                    CONTAINER_NAME="$2"
                    shift 2
                    ;;
                --port)
                    HOST_MACHINE_PORT="$2"
                    shift 2
                    ;;
                --mount)
                    MOUNTING_PATH="$2"
                    shift 2
                    ;;
                *)
                    usage
                    ;;
            esac
        done

        # Run create-cuda-env.sh script with optional parameters
        ~/.custom-scripts/create-cuda-env.sh --name "$CONTAINER_NAME" --port "$HOST_MACHINE_PORT" --mount "$MOUNTING_PATH"
        ;;
    list-envs)
        ~/.custom-scripts/list-cuda-env.sh
        ;;
    remove)
        shift
        remove_containers "$@"
        ;;
    *)
        usage
        ;;
esac
