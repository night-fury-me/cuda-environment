#!/usr/bin/env fish

# install dependencies
function install_dependencies
    echo "Installing dependencies ..."
    echo ""
    echo "Installing Docker ..."
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm docker docker-compose

    echo ""
    echo "Installing NVIDIA container toolkit ..."
    # Install dependencies for the NVIDIA container toolkit
    sudo pacman -S --noconfirm nvidia-container-toolkit libnvidia-container-tools
    sudo nvidia-container-toolkit configure --runtime=docker

    # Add user to docker group (logout required to take effect)
    sudo usermod -aG docker $USER

    echo ""
    echo "Installing net-tools and xclip..."
    sudo pacman -S --noconfirm net-tools xclip
end

# copy scripts to ~/.cuda-env
function copy_scripts
    echo "Copying scripts to '~/.cuda-env' ..."
    mkdir -p ~/.cuda-env
    cp -r . ~/.cuda-env/
end

# make scripts executable
function make_executable
    echo "Making scripts executable..."
    chmod +x ~/.cuda-env/bin/*.sh
end

# execute cuda-env-image-build.sh
function execute_image_build
    echo "Building cuda-env-image..."
    ~/.cuda-env/bin/build.sh
end

# update config.fish
function update_fish_config
    echo "Updating config.fish..."
    echo "" >> ~/.config/fish/config.fish
    echo "# >>> cuda-env scripts >>>" >> ~/.config/fish/config.fish
    echo 'alias cuda-env="~/.cuda-env/main.sh"' >> ~/.config/fish/config.fish
    echo "# <<< cuda-env scripts <<<" >> ~/.config/fish/config.fish
end

# source config.fish
function source_fish_config
    echo "Sourcing config.fish..."
    source ~/.config/fish/config.fish
end

# close current session
function close_current_session
    echo ""
    echo "Please log out and log back in to apply docker group changes for $USER."
end

# main function to run all steps
function main
    install_dependencies
    copy_scripts
    make_executable
    execute_image_build
    update_fish_config
    source_fish_config
    close_current_session
end

main
