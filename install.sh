#!/bin/bash

# install dependencies
install_dependencies() {
    echo "Installing dependencies..."
    # sudo apt-get update
    # sudo apt-get install -y net-tools xclip
}

# copy scripts to ~/.cuda-env
copy_scripts() {
    echo "Copying scripts to '~/.cuda-env' ..."
    mkdir -p ~/.cuda-env
    cp -r bin ~/.cuda-env
}

# make scripts executable
make_executable() {
    echo "Making scripts executable..."
    chmod +x ~/.cuda-env/bin/*.sh
}

# execute cuda-env-image-build.sh
execute_image_build() {
    echo "Building cuda-env-image..."
    ~/.cuda-env/bin/cuda-env-image-build.sh
}

# update .bashrc
update_bashrc() {
    echo "Updating .bashrc..."
    echo "" >> ~/.bashrc
    echo "# >>> cuda-env scripts >>>" >> ~/.bashrc
    echo 'export PATH="$PATH:~/.cuda-env/bin"' >> ~/.bashrc
    echo 'alias cuda-env="~/.cuda-env/bin/cuda-env.sh"' >> ~/.bashrc
    echo "# <<< cuda-env scripts <<<" >> ~/.bashrc
}

# source .bashrc
source_bashrc() {
    echo "Sourcing .bashrc..."
    source ~/.bashrc
}

main() {
    install_dependencies
    copy_scripts
    make_executable
    execute_image_build
    update_bashrc
    source_bashrc
}

main
