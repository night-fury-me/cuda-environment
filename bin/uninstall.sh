#!/usr/bin/env bash

error_exit() {
    echo "Error: $1" >&2
    exit 1
}

remove_cuda_env_directory() {
    echo "Removing '~/.cuda-env' directory..."
    rm -rf ~/.cuda-env || error_exit "Failed to remove '~/.cuda-env' directory."
}

remove_from_bashrc() {
    local pattern_start="# >>> cuda-env scripts >>>"
    local pattern_end="# <<< cuda-env scripts <<<"

    echo "Removing cuda-env path from .zshrc..."
    sed -i "/$pattern_start/,/$pattern_end/d" ~/.zshrc || error_exit "Failed to remove lines from .zshrc."
}

reload_bashrc() {
    echo "Reloading .zshrc..."
    source ~/.zshrc || error_exit "Failed to reload .zshrc."
}

# Main cleanup function
cleanup() {
    echo ">>> Pre-uninstallation cleanup started <<<"
    remove_cuda_env_directory
    remove_from_bashrc
    reload_bashrc
    echo ">>> Pre-uninstallation cleanup complete <<<"
}

# Run the cleanup function
cleanup
