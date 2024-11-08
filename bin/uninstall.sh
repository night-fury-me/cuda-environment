#!/usr/bin/env fish

# Function to print error and exit
function error_exit
    echo "Error: $argv[1]" >&2
    exit 1
end

# Function to remove the ~/.cuda-env directory
function remove_cuda_env_directory
    echo "Removing '~/.cuda-env' directory..."
    rm -rf ~/.cuda-env; or error_exit "Failed to remove '~/.cuda-env' directory."
end

# Function to remove entries from .bashrc (or .zshrc in this case)
function remove_from_bashrc
    set pattern_start "# >>> cuda-env scripts >>>"
    set pattern_end "# <<< cuda-env scripts <<<"

    echo "Removing cuda-env path from .zshrc..."
    sed -i "/$pattern_start/,/$pattern_end/d" ~/.zshrc; or error_exit "Failed to remove lines from .zshrc."
end

# Function to reload .zshrc
function reload_bashrc
    echo "Reloading .zshrc..."
    source ~/.zshrc; or error_exit "Failed to reload .zshrc."
end

# Main cleanup function
function cleanup
    echo ">>> Pre-uninstallation cleanup started <<<"
    remove_cuda_env_directory
    remove_from_bashrc
    reload_bashrc
    echo ">>> Pre-uninstallation cleanup complete <<<"
end

# Run the cleanup function
cleanup
