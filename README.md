# CUDA Environment Manager

This cli tool helps to manage CUDA-enabled Docker containers easily. It provides functionality to build-image, create, list, and remove Docker containers based on the "gpu-jupyter" image.

## Pre-requisites

Before using this tool, ensure the following pre-requisites are met:

1. **Docker Installed**: Docker needs to be installed and configured properly on your system.
2. **CUDA Device Availability**: Ensure CUDA-compatible GPU drivers are installed and a CUDA-capable device is available.
3. **Build GPU-Jupyter Image**: Follow the instructions to build the "gpu-jupyter" image from [GPU-Jupyter GitHub Repository](https://github.com/iot-salzburg/gpu-jupyter)
4. **netstat:** To check port availability of the host machine. use - [`sudo apt install net-tools`]
5. **xclip:** To automatically copy the jupyter lab url in the clipboard. use - [`sudo apt-get install xclip`]

## Usage

### Script Usage

```bash
cuda-env build-image # To rebuild cuda-env image, if for some reason it is removed
cuda-env create [--name CONTAINER_NAME] [--port HOST_MACHINE_PORT] [--mount MOUNTING_PATH]
cuda-env list-envs
cuda-env remove CONTAINER_NAME [CONTAINER_NAME_1 CONTAINER_NAME_2 ...] [--all] [--force]
```

### Instructions

**Method-01: Install via npm**

Run the following commands:

```bash
npm install -g cuda-env && run-post-installation
```

---

**Method-02: Manually install from git repository**

1. **Create a Folder in Home Directory:**
    - Create the following directory `~/.cuda-env/bin/` under the home directory (`~/`).
    - Place all five bash scripts (`cuda-env.sh`, `create-cuda-env.sh`, `list-cuda-env.sh`, `remove-cuda-env.sh`, `cuda-env-image-build.sh`) located in `bin` folder inside `~/.cuda-env/bin/`.
    - Ensure proper permissions (`chmod +x script_name.sh`) are set for each bash script.
2. **Modify .bashrc:**
    - Open your `.bashrc` file:
        
        ```bash
        nano ~/.bashrc
        ```
        
    - Add the following lines at the end of the file:
        
        ```bash
        # >>> cuda-env scripts >>>
        export PATH="$PATH:~/.cuda-env/bin"
        alias cuda-env="~/.cuda-env/bin/cuda-env.sh"
        # <<< cuda-env scripts <<<
        ```
        
3. **Source .bashrc:**
    - To apply the changes made to `.bashrc`, run:
        
        ```bash
        source ~/.bashrc
        ```
        

---

### Command Details

### `cuda-env`

Main command to manage CUDA-enabled Docker containers.

### `build-image`#

Use this command to rebuild the cuda-env image if it is removed from your local docker repository. The cuda-env image is mandatory to `create` any new cuda environment using the CLI tool. 

### `create`

Creates a new Docker container based on the "gpu-jupyter" image and copies the jupyter lab url in the clipboard. The url is also printed in the terminal as output.

Optional Parameters:

- `--name CONTAINER_NAME`: Specify a custom name for the container. (default: set by Docker)
- `--port HOST_MACHINE_PORT`: Specify the port on the host machine to map to Jupyter. (default: 8848 or a random port if 8848 is already in use)
- `--mount MOUNTING_PATH`: Specify a custom directory path to mount into the container. (default: present working directory, in which the command was executed)

### `list-envs`

Lists all cuda environments (docker containers) created based on the "gpu-jupyter" image.

### `remove`

Removes Docker containers based on the provided environment (docker container) names or ids.

Optional Parameters:

- `--force`: Forcefully remove containers that are in a running state.
- `--all`: Remove all containers based on the "gpu-jupyter" image.

---

### Notes

- Replace `CONTAINER_NAME`, `HOST_MACHINE_PORT`, and `MOUNTING_PATH` with appropriate values as per your setup.
- Adjust the image name (`gpu-jupyter`) in scripts to match your actual Docker image name.

