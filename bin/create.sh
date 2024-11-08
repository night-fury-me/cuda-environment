#!/usr/bin/env fish

function usage
    echo "Usage: $argv[0] --name CONTAINER_NAME --port HOST_MACHINE_PORT [--mount MOUNTING_PATH]"
    exit 1
end

set CONTAINER_NAME ""
set HOST_MACHINE_PORT "8848"
set MOUNTING_PATH (pwd)

function port_in_use
    set port $argv[1]
    netstat -tuln | grep -q ":$port\s"
end

function parse_arguments
    while test (count $argv) -gt 0
        switch $argv[1]
            case --name
                set CONTAINER_NAME $argv[2]
                set argv (remove 1 2 $argv)

            case --port
                set HOST_MACHINE_PORT $argv[2]
                set argv (remove 1 2 $argv)

            case --mount
                set MOUNTING_PATH $argv[2]
                set argv (remove 1 2 $argv)

            case '*'
                usage
        end
    end

    # Ensure both mandatory arguments are provided
    if test -z $HOST_MACHINE_PORT
        set HOST_MACHINE_PORT "8848"
    end

    if test -z $MOUNTING_PATH
        set MOUNTING_PATH (pwd)
    end

    validate_and_adjust_port
end

function generate_random_port
    while true
        set random_port (math (random) % 16383 + 49152)  # Generate random port in range 49152-65535
        if not port_in_use $random_port
            break
        end
    end
    echo $random_port
end

function remove_existing_container
    set container_name $argv[1]
    if test -n $container_name
        set container_exists (docker ps -aq -f name=$container_name)
        if test -n $container_exists
            echo "Container $container_name exists. Removing it."
            docker rm -f $container_name
        end
    end
end

function validate_and_adjust_port
    if test -z $HOST_MACHINE_PORT
        set HOST_MACHINE_PORT "8848"
    end

    if port_in_use $HOST_MACHINE_PORT
        echo "Port $HOST_MACHINE_PORT is already in use. Generating a random port..."
        set HOST_MACHINE_PORT (generate_random_port)
        echo "The environment is using a random port: $HOST_MACHINE_PORT"
    else
        echo "The environment is using port: $HOST_MACHINE_PORT"
    end
end

function construct_docker_run_command
    set DOCKER_RUN_COMMAND "docker run --shm-size=4g --gpus all -d -it -p $HOST_MACHINE_PORT:8888 -v $MOUNTING_PATH:/home/jovyan/work -e ENVIRONMENT_TYPE=cuda-env -e GRANT_SUDO=yes -e JUPYTER_ENABLE_LAB=yes -e NB_UID=(id -u) -e NB_GID=(id -g) --user root --restart always"

    if test -n $CONTAINER_NAME
        set DOCKER_RUN_COMMAND "$DOCKER_RUN_COMMAND --name $CONTAINER_NAME"
    end

    set DOCKER_RUN_COMMAND "$DOCKER_RUN_COMMAND gpu-jupyter"
end

function run_docker_container
    set DOCKER_OUTPUT (eval $DOCKER_RUN_COMMAND)
    set CONTAINER_ID (echo $DOCKER_OUTPUT | awk '{print $NF}' | cut -c 1-12)
end

function print_container_info
    echo "Created environment:"
    echo "----------------------------------------------"
    printf "%-30s | %s\n" "Name" "Id"
    echo "----------------------------------------------"

    if test -n $CONTAINER_NAME
        printf "%-30s | %s\n" $CONTAINER_NAME $CONTAINER_ID
    else
        set DEFAULT_CONTAINER_NAME (docker inspect -f '{{.Name}}' $CONTAINER_ID)
        set DEFAULT_CONTAINER_NAME (string replace -r '^/' '' $DEFAULT_CONTAINER_NAME)
        printf "%-30s | %s\n" $DEFAULT_CONTAINER_NAME $CONTAINER_ID
    end

    echo "----------------------------------------------"
end

function extract_and_print_jupyter_url
    sleep 5
    if test -n $CONTAINER_NAME
        set JUPYTER_LOGS (docker logs $CONTAINER_NAME 2>&1)
    else
        set JUPYTER_LOGS (docker ps -lq | xargs docker logs 2>&1)
    end

    set JUPYTER_TOKEN (echo $JUPYTER_LOGS | grep -oP 'token=\K\S+' | tail -n 1)

    if test -z $JUPYTER_TOKEN
        echo "Could not retrieve Jupyter token. Check the container logs for details."
        exit 1
    end

    set JUPYTER_URL "http://localhost:$HOST_MACHINE_PORT/lab?token=$JUPYTER_TOKEN"
    echo -e "Jupyter URL: \033]8;;$JUPYTER_URL\033\\$JUPYTER_URL\033]8;;\033\\"
    
    # Copy the URL to the clipboard if possible
    if test -n "$DISPLAY"
        echo $JUPYTER_URL | xclip -selection clipboard
        echo "The URL has also been copied to the clipboard."
    else
        echo "Clipboard copy not supported in this environment. Please copy the URL manually."
    end
end

# Main function 
function main
    parse_arguments $argv
    remove_existing_container $CONTAINER_NAME
    construct_docker_run_command
    run_docker_container
    print_container_info
    extract_and_print_jupyter_url
end

# Check if the correct number of arguments are provided
if test (count $argv) -lt 4
    usage
end

main $argv
