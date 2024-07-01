#!/bin/bash

usage() {
    echo "Usage:"
    echo "cuda-env build-image       # Use it to rebuild the image, if the cuda-env docker image is removed for some reason."
    echo "cuda-env create [--name CONTAINER_NAME] [--port HOST_MACHINE_PORT] [--mount MOUNTING_PATH]"
    echo "cuda-env run [CONTAINER_NAME] [PYTHON_FILE_PATH]"
    echo "cuda-env list-envs"
    echo "cuda-env remove [CONTAINER_NAME_1 CONTAINER_NAME_2 ...] [--force] [--all]"
    echo "cuda-env uninstall         # Uninstall cuda-env and remove all related files and paths."
    exit 1
}

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
        ~/.cuda-env/bin/remove-cuda-env.sh "${container_ids[@]}" --force
    else
        ~/.cuda-env/bin/remove-cuda-env.sh "${container_ids[@]}"
    fi
}

run_python_file() {
    local CONTAINER_NAME="$1"
    local PYTHON_FILE_PATH="$2"

    # Check if CONTAINER_NAME and PYTHON_FILE_PATH are provided
    if [ -z "$CONTAINER_NAME" ] || [ -z "$PYTHON_FILE_PATH" ]; then
        usage
    fi

    # Execute Python file inside the container
    docker exec -it "$CONTAINER_NAME" python "/home/jovyan/work/$PYTHON_FILE_PATH"
}

# Determine which subcommand to execute
case "$1" in
    build-image)
        ~/.cuda-env/bin/cuda-env-image-build.sh
        ;;
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
        ~/.cuda-env/bin/create-cuda-env.sh --name "$CONTAINER_NAME" --port "$HOST_MACHINE_PORT" --mount "$MOUNTING_PATH"
        ;;
    list-envs)
        ~/.cuda-env/bin/list-cuda-env.sh
        ;;
    remove)
        shift
        remove_containers "$@"
        ;;
    run)
        CONTAINER_NAME="$2"
        PYTHON_FILE_PATH="$3"
        run_python_file "$CONTAINER_NAME" "$PYTHON_FILE_PATH"
        ;;
    uninstall)
        ~/.cuda-env/bin/uninstall.sh
        ;;
    *)
        usage
        ;;
esac
