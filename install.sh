#!/bin/bash

# install dependencies
install_dependencies() {
    echo "Installing dependencies ..."
    echo ""
    echo "Installing docker ..."
    sudo apt update
    sudo apt install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    echo ""
    echo ""
    echo "Installing nvidia container toolkit ..."
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
        && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
            sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    sudo apt update
    sudo apt install -y nvidia-container-toolkit
    sudo nvidia-ctk runtime configure --runtime=docker
    sudo systemctl restart docker
    sudo usermod -aG docker $USER

    echo ""
    echo ""
    echo "Installing net-tools and xclip... "
    sudo apt install -y net-tools xclip
}

close_current_session() {
    echo ""
    echo ""
    echo "Enter password again to add docker to the usergroup."
    su - ${USER}
}

# copy scripts to ~/.cuda-env
copy_scripts() {
    echo "Copying scripts to '~/.cuda-env' ..."
    mkdir -p ~/.cuda-env
    cp -r ./bin/* ~/.cuda-env/
}

# make scripts executable
make_executable() {
    echo "Making scripts executable..."
    chmod +x ~/.cuda-env/*.sh
}

# execute cuda-env-image-build.sh
execute_image_build() {
    echo "Building cuda-env-image..."
    ~/.cuda-env/cuda-env-image-build.sh
}

# update .bashrc
update_bashrc() {
    echo "Updating .bashrc..."
    echo "" >> ~/.bashrc
    echo "# >>> cuda-env scripts >>>" >> ~/.bashrc
    echo 'export PATH="$PATH:~/.cuda-env"' >> ~/.bashrc
    echo 'alias cuda-env="~/.cuda-env/cuda-env.sh"' >> ~/.bashrc
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
    close_current_session
}

main
