#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 --name CONTAINER_NAME --port HOST_MACHINE_PORT [--mount MOUNTING_PATH]"
    exit 1
}

# Check if the correct number of arguments are provided
if [ "$#" -lt 4 ]; then
    usage
fi

# Function to check if a port is in use
port_in_use() {
    local port="$1"
    netstat -tuln | grep -q ":${port}\s"
}

# Function to generate a random port
generate_random_port() {
    local random_port
    while true; do
        random_port=$((RANDOM % 16383 + 49152))  # Generate random port in range 49152-65535
        ! port_in_use "$random_port" && break
    done
    echo "$random_port"
}

# Default mounting path to the present working directory
CONTAINER_NAME=""
HOST_MACHINE_PORT="8848"
MOUNTING_PATH=$(pwd)

# Parse command-line arguments
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

# Check if the container exists
if [ -n "$CONTAINER_NAME" ] && [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
    echo "Container ${CONTAINER_NAME} exists. Removing it."
    docker rm -f ${CONTAINER_NAME}
fi

# Check if HOST_MACHINE_PORT is already in use
if port_in_use "$HOST_MACHINE_PORT"; then
    echo "Port ${HOST_MACHINE_PORT} is already in use. Generating a random port..."
    HOST_MACHINE_PORT=$(generate_random_port)
    echo "The environment is using a random port: ${HOST_MACHINE_PORT}"
else
    echo "The environment is using port: ${HOST_MACHINE_PORT}"
fi

if [ -z "$MOUNTING_PATH" ]; then
    MOUNTING_PATH=$(pwd)
fi

# Print the mounted path
echo -e "The enviroment is mounted at: ${MOUNTING_PATH}"

# Construct Docker run command
DOCKER_RUN_COMMAND="docker run --gpus all -d -it -p ${HOST_MACHINE_PORT}:8888 -v ${MOUNTING_PATH}:/home/jovyan/work -e GRANT_SUDO=yes -e JUPYTER_ENABLE_LAB=yes -e NB_UID="$(id -u)" -e NB_GID="$(id -g)" --user root --restart always"

# Add --name parameter if provided
if [ -n "$CONTAINER_NAME" ]; then
    DOCKER_RUN_COMMAND+=" --name ${CONTAINER_NAME}"
fi

DOCKER_RUN_COMMAND+=" gpu-jupyter"

# Run the new instance of the container
DOCKER_OUTPUT=$(eval "$DOCKER_RUN_COMMAND")

# Extract container ID from Docker output
CONTAINER_ID=$(echo "$DOCKER_OUTPUT" | awk '{print $NF}' | cut -c 1-12)

# If CONTAINER_NAME was not provided, print the randomly assigned container name
if [ -z "$CONTAINER_NAME" ]; then
    DEFAULT_CONTAINER_NAME=$(docker inspect -f '{{.Name}}' "${CONTAINER_ID}")
    DEFAULT_CONTAINER_NAME=$(echo "${DEFAULT_CONTAINER_NAME}" | sed 's|^/||')
fi

printf "Created environment:\n"

# Print table header
echo "----------------------------------------------"
printf "%-30s | %s\n" "Name" "Id"
echo "----------------------------------------------"

# Print container information
if [ -n "$CONTAINER_NAME" ]; then
    printf "%-30s | %s\n" "${CONTAINER_NAME}" "${CONTAINER_ID}"
else
    printf "%-30s | %s\n" "${DEFAULT_CONTAINER_NAME}" "${CONTAINER_ID}"
fi

echo "----------------------------------------------"

# Wait a few seconds for the container to initialize
sleep 5

# Extract Jupyter token from container logs
if [ -n "$CONTAINER_NAME" ]; then
    JUPYTER_LOGS=$(docker logs ${CONTAINER_NAME} 2>&1)
else
    JUPYTER_LOGS=$(docker ps -lq | xargs docker logs 2>&1)
fi

# Extract last occurrence of token from logs
JUPYTER_TOKEN=$(echo "$JUPYTER_LOGS" | grep -oP 'token=\K\S+' | tail -n 1)

# Check if the token was found
if [ -z "$JUPYTER_TOKEN" ]; then
    echo "Could not retrieve Jupyter token. Check the container logs for details."
    exit 1
fi

# Form the URL
JUPYTER_URL="http://localhost:${HOST_MACHINE_PORT}/lab?token=${JUPYTER_TOKEN}"

# Print the URL in a way that most terminals will recognize as clickable
echo -e "Jupyter URL: \033]8;;${JUPYTER_URL}\033\\${JUPYTER_URL}\033]8;;\033\\"

# Copy the URL to the clipboard using xclip
echo ${JUPYTER_URL} | xclip -selection clipboard

echo "The URL has also been copied to the clipboard."
