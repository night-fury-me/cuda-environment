# CUDA Environment Manager

This cli-tool helps to manage CUDA-enabled Docker containers easily. It provides functionality to build-image, create, list, and remove Docker containers based on the "gpu-jupyter" image.

## Pre-requisites

Before using this tool, ensure the following pre-requisites are met:

1. **CUDA Device Availability**: Ensure CUDA-compatible GPU drivers are installed and a CUDA-capable device is available.
2. **Docker Installed**: Docker needs to be installed and configured properly on your system.
3. **Build GPU-Jupyter Image**: Follow the instructions to build the "gpu-jupyter" image from [GPU-Jupyter GitHub Repository](https://github.com/iot-salzburg/gpu-jupyter)
4. **netstat:** To check port availability of the host machine. use - [`sudo apt install net-tools`]
5. **xclip:** To automatically copy the jupyter lab url in the clipboard. use - [`sudo apt-get install xclip`]

**NOTE:** Pre-requisites `2` to `5` will be handled as a part of the pre installation process during `cuda-env` cli-tool installation using `install.sh`. So, you do not need to handle those pre-requisites seperately.

## Usage

### Script Usage

```bash
cuda-env build    # To rebuild cuda-env image, if for some reason it is removed
cuda-env create [--name CONTAINER_NAME] [--port HOST_MACHINE_PORT] [--mount MOUNTING_PATH]
cuda-env run [CONTAINER_NAME] [PYTHON_FILE_PATH]
cuda-env list
cuda-env deactivate [CONTAINER_NAME]
cuda-env remove [CONTAINER_NAME_1 CONTAINER_NAME_2 ...] [--all] [--force]
cuda-env uninstall      # Uninstall cuda-env and remove all related files and paths.
```

### Installation Instructions

**Method-01: Install in a `single-command`**

Run the following commands:

```bash
temp_dir=$(mktemp -d) && \
curl -L https://github.com/night-fury-me/cuda-environment/archive/main.tar.gz | tar -xz -C "$temp_dir" && \
cd "$temp_dir/cuda-environment-main" && \
bash install.sh && \
rm -rf "$temp_dir"

```

---

**Method-02: Manually install from git repository**

1. **Create a Folder in Home Directory:**
    - Create the following directory `~/.cuda-env/bin/` under the home directory (`~/`).
    - Place all six bash scripts (`main.sh`, `create.sh`, `list.sh`, `remove.sh`, `build.sh, uninstall.sh`) located in `bin` folder inside `~/.cuda-env/bin/`.
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
        alias cuda-env="~/.cuda-env/bin/main.sh"
        # <<< cuda-env scripts <<<
        ```
        
3. **Source .bashrc:**
    - To apply the changes made to `.bashrc`, run:
        
        ```bash
        source ~/.bashrc
        ```
        

---

### Uninstallation Instruction

To uninstall the `cuda-env` cli-tool follow the below instruction.

- Method-01: If installed in a `single-command`
    Run the following command - 

    ```bash
    cuda-env uninstall
    ```
- Method-02: Manually remove the `cuda-env` cli-tool
    1. Remove `~/.cuda-env` directory
    2. Remove the following environment path from .bashrc -
        ```bash
        # >>> cuda-env scripts >>>
        export PATH="$PATH:~/.cuda-env/bin"
        alias cuda-env="~/.cuda-env/bin/cuda-env.sh"
        # <<< cuda-env scripts <<<
        ```
---

### Command Details

### `cuda-env`

Main command to manage CUDA-enabled Docker containers.

### `build`

Use this command to rebuild the cuda-env image if it is removed from your local docker repository. The cuda-env image is mandatory to `create` any new cuda environment using the cli-tool. 

### `create`

Creates a new Docker container based on the "gpu-jupyter" image and copies the jupyter lab url in the clipboard. The url is also printed in the terminal as output.

Optional Parameters:

- `--name CONTAINER_NAME`: Specify a custom name for the container. (default: set by Docker)
- `--port HOST_MACHINE_PORT`: Specify the port on the host machine to map to Jupyter. (default: 8848 or a random port if 8848 is already in use)
- `--mount MOUNTING_PATH`: Specify a custom directory path to mount into the container. (default: present working directory, in which the command was executed)


### `run`
Using this you can run python files in the specified cuda-env

- `CONTAINER_NAME`: Name of the cuda-env/docker container in which your environment is executing
- `PYTHON_FILE_PATH`: Path of the python file in your host machine

### `deactivate`

Deactivate/stop cuda-env/docker container.
- `CONTAINER_NAME`: Name of the cuda-env/docker container you want to stop/deactivate 


### `list`

Lists all cuda environments (docker containers) created based on the `gpu-jupyter` image.

### `remove`

Removes Docker containers based on the provided environment (docker container) names or ids.

Optional Parameters:

- `--force`: Forcefully remove containers that are in a running state.
- `--all`: Remove all containers based on the "gpu-jupyter" image.

### `uninstall`

If you want to remove all files and commands of the `cuda-env` cli tool all together you can use this command.
It will remove `~/.cuda-env` directory and the added path variable in the `.bashrc`

---

### Notes

- Replace `CONTAINER_NAME`, `HOST_MACHINE_PORT`, and `MOUNTING_PATH` with appropriate values as per your setup.
- Adjust the image name (`gpu-jupyter`) in scripts to match your actual Docker image name.

