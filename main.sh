#!/usr/bin/env fish

function usage
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
end

function normalize_path
    set base_path $argv[1]
    set relative_path $argv[2]

    # If the path is absolute, return it as-is
    if string match -q '/*' "$relative_path"
        echo "$relative_path"
    else
        # Combine and normalize the paths
        echo "$base_path/$relative_path" | sed 's|//|/|g'
    end
end

function build_image
    ~/.cuda-env/bin/build.sh
end

function create_env
    set CONTAINER_NAME ""
    set HOST_MACHINE_PORT ""
    set MOUNTING_PATH ""

    # Parse optional parameters for create command
    while set -q argv[1]
        switch $argv[1]
            case '--name'
                set CONTAINER_NAME $argv[2]
                set argv (printf "%s\n" $argv[3..-1])
            case '--port'
                set HOST_MACHINE_PORT $argv[2]
                set argv (printf "%s\n" $argv[3..-1])
            case '--mount'
                set MOUNTING_PATH $argv[2]
                set argv (printf "%s\n" $argv[3..-1])
            case '*'
                usage
        end
    end

    # Run create-cuda-env.sh script with optional parameters
    ~/.cuda-env/bin/create.sh --name "$CONTAINER_NAME" --port "$HOST_MACHINE_PORT" --mount "$MOUNTING_PATH"
end

function list_envs
    ~/.cuda-env/bin/list.sh
end

function remove_containers
    set force_flag ""
    set container_ids

    # Parse command-line arguments
    while set -q argv[1]
        switch $argv[1]
            case '--force'
                set force_flag "--force"
                set argv (printf "%s\n" $argv[2..-1])
            case '*'
                set container_ids $container_ids $argv[1]
                set argv (printf "%s\n" $argv[2..-1])
        end
    end

    # Call remove-cuda-env.sh with all container IDs
    if test "$force_flag" = "--force"
        ~/.cuda-env/bin/remove.sh $container_ids --force
    else
        ~/.cuda-env/bin/remove.sh $container_ids
    end
end

function run_python_file
    set CONTAINER_NAME $argv[1]
    set PYTHON_FILE_PATH $argv[2]
    set PYTHON_ARGS (printf "%s " $argv[3..-1])

    # Check if CONTAINER_NAME and PYTHON_FILE_PATH are provided
    if test -z "$CONTAINER_NAME" -o -z "$PYTHON_FILE_PATH"
        usage
    end

    # Normalize the Python file path
    set WORK_DIR "/home/jovyan/work"
    set FULL_PYTHON_FILE_PATH (normalize_path "$WORK_DIR" "$PYTHON_FILE_PATH")

    # Execute Python file inside the container
    docker exec -it "$CONTAINER_NAME" python "$FULL_PYTHON_FILE_PATH" $PYTHON_ARGS
end

function deactivate_container
    set CONTAINER_NAME $argv[1]
    if test -z "$CONTAINER_NAME"
        usage
    end
    docker stop "$CONTAINER_NAME"
end

function uninstall_cuda_env
    ~/.cuda-env/bin/uninstall.sh
end

# Main script logic to determine which subcommand to execute
switch "$argv[1]"
    case 'build'
        build_image
    case 'create'
        set argv (printf "%s\n" $argv[2..-1])
        create_env $argv
    case 'list'
        list_envs
    case 'monitor'
        watch nvidia-smi
    case 'remove'
        set argv (printf "%s\n" $argv[2..-1])
        remove_containers $argv
    case 'run'
        set argv (printf "%s\n" $argv[2..-1])
        run_python_file $argv
    case 'deactivate'
        deactivate_container $argv[2]
    case 'uninstall'
        uninstall_cuda_env
    case '*'
        usage
end
