#!/usr/bin/env fish

function error_exit
    echo "Error: $argv" >&2
    exit 1
end

function clone_repository
    set temp_dir $argv[1]
    set repo_url $argv[2]

    echo "Cloning repository into $temp_dir..."
    git clone $repo_url $temp_dir; or error_exit "Failed to clone repository."
end

function checkout_branch
    set temp_dir $argv[1]
    set branch_name $argv[2]

    echo "Checking out branch $branch_name..."
    cd $temp_dir; or error_exit "Failed to change directory to $temp_dir."
    git checkout -b $branch_name; or error_exit "Failed to checkout branch $branch_name."
end

function generate_dockerfile
    set temp_dir $argv[1]

    echo "Generating Dockerfile with python-only option..."
    ./generate-Dockerfile.sh --python-only; or error_exit "Failed to generate Dockerfile."
end

function build_docker_image
    set temp_dir $argv[1]

    echo "Building Docker image. This may take a while..."
    docker build -t gpu-jupyter $temp_dir/.build/; or error_exit "Failed to build Docker image."
end

function cleanup_temp_dir
    set temp_dir $argv[1]

    echo "Removing temporary directory $temp_dir..."
    rm -rf $temp_dir; or error_exit "Failed to remove temporary directory $temp_dir."
end

function main
    set temp_dir (mktemp -d); or error_exit "Failed to create temporary directory."

    set repo_url "https://github.com/night-fury-me/gpu-jupyter.git"
    set branch_name "v1.7_cuda-12.2_ubuntu-22.04"

    clone_repository $temp_dir/gpu-jupyter $repo_url
    checkout_branch $temp_dir/gpu-jupyter $branch_name
    generate_dockerfile $temp_dir/gpu-jupyter
    build_docker_image $temp_dir/gpu-jupyter
    cleanup_temp_dir $temp_dir

    echo "gpu-jupyter image build complete."
end

# Run the main function
main
