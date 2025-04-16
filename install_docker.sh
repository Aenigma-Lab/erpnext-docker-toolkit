#!/usr/bin/env bash
set -e  # Exit on any error

##############################################################################
#                PART 1: Docker Installation and Setup                       #
##############################################################################
echo "[1/9] Removing old Docker versions (if any)..."
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

echo "[2/9] Updating system packages..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

echo "[3/9] Adding Docker’s official GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor --output /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "[4/9] Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "[5/9] Installing Docker Engine, CLI, and plugins..."
sudo apt-get update
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

echo "[6/9] Starting and enabling Docker..."
sudo systemctl start docker
sudo systemctl enable docker

echo "Adding current user '$USER' to 'docker' group..."
sudo usermod -aG docker "$USER"

echo "================================================================"
echo " Docker Installation Complete!"
echo "   - Log out and back in (or run 'newgrp docker') to use Docker"
echo "     without sudo."
echo "   - Test with: docker run hello-world"
echo "================================================================"

echo "[7/9] Running Docker test and cleanup commands..."
docker run hello-world || true

# 'docker image' by itself just shows subcommands; 
# if you meant to list images, change this to "docker images".
docker image  || true

sudo docker ps || true
sudo docker system prune --all --force --volumes || true

##############################################################################
#    PART 2: Prompt for Username and Run Compose in builds/docker/erp_docker #
##############################################################################
echo "[8/9] Prompting for username to build ERPNext in home directory..."
read -p "Enter the username: " MYUSER
HOMEFOLDER="/home/$MYUSER"

# Verify the user’s home directory exists
if [ ! -d "$HOMEFOLDER" ]; then
  echo "ERROR: The directory $HOMEFOLDER does not exist."
  echo "Make sure the user '$MYUSER' has a valid home directory."
  exit 1
fi

echo "Switching to $HOMEFOLDER..."
cd "$HOMEFOLDER"

echo "Ensuring the build folder structure exists..."
mkdir -p builds/docker/erp_docker

# Copy docker_compose1.yml from shubham_script_docker to erp_docker
# Adjust paths as needed to match your actual file locations
echo "Copying 'docker_compose1.yml' to erp_docker..."
cp "$HOMEFOLDER/shubham_script_docker/docker_compose1.yml" "$HOMEFOLDER/builds/docker/erp_docker/"

echo "[9/9] Bringing up Docker Compose project in 'erp_docker'..."
cd "$HOMEFOLDER/builds/docker/erp_docker"

# Ensure the file was copied successfully
if [ ! -f "docker_compose1.yml" ]; then
  echo "ERROR: 'docker_compose1.yml' is not found in 'erp_docker'!"
  exit 1
fi

# Use '-p erpnext_docker' or any name you prefer for the Compose project
sudo docker compose -p erpnext_docker -f docker_compose.yml up

echo "================================================================"
echo " Script finished! The Docker containers are now running in the foreground."
echo "================================================================"

