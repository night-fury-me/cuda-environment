#!/bin/zsh

usage() {
    echo "Usage: $0 --name CONTAINER_NAME --port HOST_MACHINE_PORT [--mount MOUNTING_PATH]"
    exit 1
}

CONTAINER_NAME=""
HOST_MACHINE_PORT="8848"
MOUNTING_PATH=$(pwd)

port_in_use() {
    local port="$1"
    netstat -tuln | grep -q ":${port}\s"
}

parse_arguments() {
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
    
    # Ensure both mandatory arguments are provided
    if [ -z "$HOST_MACHINE_PORT" ]; then
        HOST_MACHINE_PORT="8848"
    fi

    if [ -z "$MOUNTING_PATH" ]; then
        MOUNTING_PATH=$(pwd)
    fi

    validate_and_adjust_port
}

generate_random_port() {
    local random_port
    while true; do
        random_port=$((RANDOM % 16383 + 49152))  # Generate random port in range 49152-65535
        ! port_in_use "$random_port" && break
    done
    echo "$random_port"
}

remove_existing_container() {
    local container_name="$1"
    if [ -n "$container_name" ] && [ "$(docker ps -aq -f name=${container_name})" ]; then
        echo "Container ${container_name} exists. Removing it."
        docker rm -f "${container_name}"
    fi
}

validate_and_adjust_port() {
    if [ -z "$HOST_MACHINE_PORT" ]; then
        HOST_MACHINE_PORT="8848"
    fi

    if port_in_use "$HOST_MACHINE_PORT"; then
        echo "Port ${HOST_MACHINE_PORT} is already in use. Generating a random port..."
        HOST_MACHINE_PORT=$(generate_random_port)
        echo "The environment is using a random port: ${HOST_MACHINE_PORT}"
    else
        echo "The environment is using port: ${HOST_MACHINE_PORT}"
    fi
}

construct_docker_run_command() {
    DOCKER_RUN_COMMAND="docker run --shm-size=4g --gpus all -d -it -p ${HOST_MACHINE_PORT}:8888 -v ${MOUNTING_PATH}:/home/jovyan/work -e ENVIRONMENT_TYPE=cuda-env -e GRANT_SUDO=yes -e JUPYTER_ENABLE_LAB=yes -e NB_UID=$(id -u) -e NB_GID=$(id -g) --user root --restart always"

    if [ -n "$CONTAINER_NAME" ]; then
        DOCKER_RUN_COMMAND+=" --name ${CONTAINER_NAME}"
    fi

    DOCKER_RUN_COMMAND+=" gpu-jupyter"
}

run_docker_container() {
    DOCKER_OUTPUT=$(eval "$DOCKER_RUN_COMMAND")
    CONTAINER_ID=$(echo "$DOCKER_OUTPUT" | awk '{print $NF}' | cut -c 1-12)
}

print_container_info() {
    printf "Created environment:\n"
    echo "----------------------------------------------"
    printf "%-30s | %s\n" "Name" "Id"
    echo "----------------------------------------------"

    if [ -n "$CONTAINER_NAME" ]; then
        printf "%-30s | %s\n" "${CONTAINER_NAME}" "${CONTAINER_ID}"
    else
        DEFAULT_CONTAINER_NAME=$(docker inspect -f '{{.Name}}' "${CONTAINER_ID}")
        DEFAULT_CONTAINER_NAME=$(echo "${DEFAULT_CONTAINER_NAME}" | sed 's|^/||')
        printf "%-30s | %s\n" "${DEFAULT_CONTAINER_NAME}" "${CONTAINER_ID}"
    fi

    echo "----------------------------------------------"
}

extract_and_print_jupyter_url() {
    sleep 5
    if [ -n "$CONTAINER_NAME" ]; then
        JUPYTER_LOGS=$(docker logs "${CONTAINER_NAME}" 2>&1)
    else
        JUPYTER_LOGS=$(docker ps -lq | xargs docker logs 2>&1)
    fi

    JUPYTER_TOKEN=$(echo "$JUPYTER_LOGS" | grep -oP 'token=\K\S+' | tail -n 1)

    if [ -z "$JUPYTER_TOKEN" ]; then
        echo "Could not retrieve Jupyter token. Check the container logs for details."
        exit 1
    fi

    JUPYTER_URL="http://localhost:${HOST_MACHINE_PORT}/lab?token=${JUPYTER_TOKEN}"
    echo -e "Jupyter URL: \033]8;;${JUPYTER_URL}\033\\${JUPYTER_URL}\033]8;;\033\\"
    # Copy the URL to the clipboard if possible
    if [ -n "$DISPLAY" ]; then
        echo "${JUPYTER_URL}" | xclip -selection clipboard
        echo "The URL has also been copied to the clipboard."
    else
        echo "Clipboard copy not supported in this environment. Please copy the URL manually."
    fi
}

# Main function 
main() {
    parse_arguments "$@"
    remove_existing_container "$CONTAINER_NAME"
    construct_docker_run_command
    run_docker_container
    print_container_info
    extract_and_print_jupyter_url
}

# Check if the correct number of arguments are provided
if [ "$#" -lt 4 ]; then
    usage
fi

main "$@"
