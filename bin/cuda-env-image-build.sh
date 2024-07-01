#!/bin/bash

TEMP_DIR=$(mktemp -d)

# Clone the GPU-Jupyter repository into the temporary directory
echo "Cloning the GPU-Jupyter repository..."
git clone https://github.com/night-fury-me/gpu-jupyter.git "$TEMP_DIR/gpu-jupyter"

# Change to the gpu-jupyter directory
cd "$TEMP_DIR/gpu-jupyter"

# Check out the specific branch
echo "Checking out the branch v1.7_cuda-12.2_ubuntu-22.04..."
git checkout v1.7_cuda-12.2_ubuntu-22.04

# Generate the Dockerfile with python-only option
echo "Generating the Dockerfile with the python-only option..."
./generate-Dockerfile.sh --python-only

# Build the Docker image
echo "Building the Docker image. This may take a while..."
docker build -t gpu-jupyter .build/

# Remove the temporary directory
echo "Removing the temporary directory..."
rm -rf "$TEMP_DIR"

echo "gpu-jupyter image build complete."