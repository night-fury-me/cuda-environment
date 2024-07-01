#!/bin/bash

echo ">>> Pre-uninstallation cleanup started <<<"
# Remove the ~/.cuda-env directory
echo "Removing '~/.cuda-env' direcotry ..."
rm -rf ~/.cuda-env

# Remove the lines from .bashrc
echo "Removing cuda-env path from .bashrc ..."
sed -i '/# >>> cuda-env scripts >>>/,/# <<< cuda-env scripts <<</d' ~/.bashrc

# Source the .bashrc to apply changes
echo "Reloading .bashrc ..."
source ~/.bashrc

echo ">>> Pre-uninstallation cleanup complete <<<"

