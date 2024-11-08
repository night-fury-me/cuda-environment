#!/usr/bin/env fish

# Constants
set IMAGE_NAME "gpu-jupyter"

# Usage function
function usage
    echo "Usage:"
    echo "  $0 CONTAINER_ID [CONTAINER_ID2 ...] [--force]"
    echo "  $0 --all"
    exit 1
end

# Check if the container is running
function is_container_running
    set container_id $argv[1]
    set result (docker inspect -f '{{.State.Running}}' $container_id ^/dev/null)
    if test "$result" = "true"
        echo "true"
    else
        echo "false"
    end
end

# Remove containers function
function remove_containers
    set force_flag false
    set all_flag false
    set containers
    set running_containers

    # Parse command-line arguments
    for arg in $argv
        switch $arg
            case "--force"
                set force_flag true
            case "--all"
                set all_flag true
            case '*'
                set containers $containers $arg
        end
    end

    # Handle case where --all is provided
    if test "$all_flag" = "true"
        set containers (docker ps -a --filter ancestor=$IMAGE_NAME --format "{{.ID}}")
    end

    # Remove containers
    for container_id in $containers
        if test "$force_flag" = "false"
            set running (is_container_running $container_id)
            if test "$running" = "false"
                docker rm $container_id > /dev/null 2>&1
            else
                set running_containers $running_containers $container_id
            end
        else
            docker rm -f $container_id > /dev/null 2>&1
        end
    end

    # Print guideline for --force command if any containers were not removed
    if test "$force_flag" = "false" -a (count $running_containers) -gt 0
        echo "Some containers were not removed because they are still in a running state."
        echo "To force remove, use the following command:"
        echo "cuda-env remove [CONTAINER_NAME_1 CONTAINER_NAME_2 ...] OR [--all] --force"
        echo "You can deactivate first using: cuda-env deactivate [CONTAINER_NAME] and then try remove."
    end
end

# Main script logic
if test (count $argv) -lt 1
    usage
end

remove_containers $argv
