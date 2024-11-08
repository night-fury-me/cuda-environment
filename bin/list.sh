#!/usr/bin/env fish

# Constants
set IMAGE_NAME "gpu-jupyter"

# Usage function
function usage
    echo "Usage: $0"
    echo "This script lists all running Docker containers based on the image '${IMAGE_NAME}'."
    exit 1
end

# Get containers function
function get_containers
    docker ps -a --filter ancestor="$IMAGE_NAME" --format "table {{.Names}}\t{{.ID}}" | tail -n +2
end

# Print containers function
function print_containers
    set containers $argv
    for container_info in (string split "\n" $containers)
        set container_name (echo $container_info | awk '{print $1}')
        set container_id (echo $container_info | awk '{print $2}')
        printf "%-30s | %s\n" $container_name $container_id
    end
end

# Main function
function main
    set CONTAINERS (get_containers)

    if test -z "$CONTAINERS"
        echo "No running environment found based on image $IMAGE_NAME."
    else
        echo "----------------------------------------------"
        printf "%-30s | %s\n" "Name" "Id"
        echo "----------------------------------------------"
        print_containers "$CONTAINERS"
        echo "----------------------------------------------"
    end
end

# Check if the script has been executed with arguments
if test (count $argv) -gt 0
    usage
end

# Run main function
main
