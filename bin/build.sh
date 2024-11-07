#!/bin/zsh

error_exit() {
    echo "Error: $1" >&2
    exit 1
}

clone_repository() {
    local temp_dir="$1"
    local repo_url="$2"

    echo "Cloning repository into $temp_dir..."
    git clone "$repo_url" "$temp_dir" || error_exit "Failed to clone repository."
}

checkout_branch() {
    local temp_dir="$1"
    local branch_name="$2"

    echo "Checking out branch $branch_name..."
    cd "$temp_dir" || error_exit "Failed to change directory to $temp_dir."
    git checkout -b "$branch_name" || error_exit "Failed to checkout branch $branch_name."
}

generate_dockerfile() {
    local temp_dir="$1"

    echo "Generating Dockerfile with python-only option..."
    ./generate-Dockerfile.sh --python-only || error_exit "Failed to generate Dockerfile."
}

build_docker_image() {
    local temp_dir="$1"

    echo "Building Docker image. This may take a while..."
    docker build -t gpu-jupyter "$temp_dir/.build/" || error_exit "Failed to build Docker image."
}

cleanup_temp_dir() {
    local temp_dir="$1"

    echo "Removing temporary directory $temp_dir..."
    rm -rf "$temp_dir" || error_exit "Failed to remove temporary directory $temp_dir."
}

main() {
    local temp_dir
    temp_dir=$(mktemp -d) || error_exit "Failed to create temporary directory."

    local repo_url="https://github.com/night-fury-me/gpu-jupyter.git"
    local branch_name="v1.7_cuda-12.2_ubuntu-22.04"

    clone_repository "$temp_dir/gpu-jupyter" "$repo_url"
    checkout_branch "$temp_dir/gpu-jupyter" "$branch_name"
    generate_dockerfile "$temp_dir/gpu-jupyter"
    build_docker_image "$temp_dir/gpu-jupyter"
    cleanup_temp_dir "$temp_dir"

    echo "gpu-jupyter image build complete."
}

# Run the main function
main
