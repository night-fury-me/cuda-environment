#!/usr/bin/env bash

usage() {
    echo "Usage:"
    echo "cuda-env build        # Use it to rebuild the image, if the cuda-env docker image is removed for some reason."
    echo "cuda-env create [--name CONTAINER_NAME] [--port HOST_MACHINE_PORT] [--mount MOUNTING_PATH]"
    echo "cuda-env run [CONTAINER_NAME] [PYTHON_FILE_PATH] [ARG_1 ARG_2 ARG_3 ...]"
    echo "cuda-env list"
    echo "cuda-env remove [CONTAINER_NAME_1 CONTAINER_NAME_2 ...] [--force] [--all]"
    echo "cuda-env deactivate [CONTAINER_NAME]  # Stop the specified Docker container."
    echo "cuda-env monitor      # Monitor Nvidia GPU status."
    echo "cuda-env uninstall    # Uninstall cuda-env and remove all related files and paths."
    exit 1
}

normalize_path() {
    local base_path="$1"
    local relative_path="$2"

    # If the path is absolute, return it as-is
    if [[ "$relative_path" = /* ]]; then
        echo "$relative_path"
    else
        # Combine and normalize the paths
        echo "$base_path/$relative_path" | sed 's|//|/|g'
    fi
}

build_image() {
    ~/.cuda-env/bin/build.sh
}

create_env() {
    local CONTAINER_NAME=""
    local HOST_MACHINE_PORT=""
    local MOUNTING_PATH=""

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
    ~/.cuda-env/bin/create.sh --name "$CONTAINER_NAME" --port "$HOST_MACHINE_PORT" --mount "$MOUNTING_PATH"
}

list_envs() {
    ~/.cuda-env/bin/list.sh
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
        ~/.cuda-env/bin/remove.sh "${container_ids[@]}" --force
    else
        ~/.cuda-env/bin/remove.sh "${container_ids[@]}"
    fi
}

run_python_file() {
    local CONTAINER_NAME="$1"
    local PYTHON_FILE_PATH="$2"
    shift 2
    local PYTHON_ARGS="$@"
    
    # Check if CONTAINER_NAME and PYTHON_FILE_PATH are provided
    if [ -z "$CONTAINER_NAME" ] || [ -z "$PYTHON_FILE_PATH" ]; then
        usage
    fi
    
    # Normalize the Python file path
    local WORK_DIR="/home/jovyan/work"
    local FULL_PYTHON_FILE_PATH
    FULL_PYTHON_FILE_PATH=$(normalize_path "$WORK_DIR" "$PYTHON_FILE_PATH")
    
    # Execute Python file inside the container
    docker exec -it "$CONTAINER_NAME" python "$FULL_PYTHON_FILE_PATH" $PYTHON_ARGS
}

deactivate_container() {
    local CONTAINER_NAME="$1"
    if [ -z "$CONTAINER_NAME" ]; then
        usage
    fi
    docker stop "$CONTAINER_NAME"
}

uninstall_cuda_env() {
    ~/.cuda-env/bin/uninstall.sh
}

# Main script logic to determine which subcommand to execute
case "$1" in
    build)
        build_image
        ;;
    create)
        shift
        create_env "$@"
        ;;
    list)
        list_envs
        ;;
    monitor)
        watch nvidia-smi
        ;;
    remove)
        shift
        remove_containers "$@"
        ;;
    run)
        shift
        run_python_file "$@"
        ;;
    deactivate)
        deactivate_container "$2"
        ;;
    uninstall)
        uninstall_cuda_env
        ;;
    *)
        usage
        ;;
esac
