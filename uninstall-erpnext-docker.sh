#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}"
echo "==========================================="
echo "       🔧 Developed by Shubham 🔧"
echo "==========================================="
echo -e "${NC}"

echo -e "${GREEN}Starting the complete uninstallation of ERPNext and related dependencies...${NC}"

echo -e "${YELLOW}Stopping and removing all Docker containers...${NC}"
docker-compose down -v || true
docker ps -aq | xargs -r docker rm -f

echo -e "${YELLOW}Removing ERPNext-specific containers...${NC}"
containers=$(docker ps -a --filter "name=frappe" --format "{{.ID}}")
if [ -n "$containers" ]; then
    docker rm -f $containers
fi

echo -e "${YELLOW}Removing Docker images...${NC}"
docker images -q | xargs -r docker rmi -f

echo -e "${YELLOW}Removing Docker volumes...${NC}"
docker volume ls -q | xargs -r docker volume rm

echo -e "${YELLOW}Removing custom Docker networks...${NC}"
# only list & remove non–built-in networks
docker network ls --filter "type=custom" -q | xargs -r docker network rm

echo -e "${YELLOW}Removing ERPNext-related files and directories...${NC}"
rm -rf ./sites ./assets ./logs mariadb-data redis-data frappe-bench

echo -e "${YELLOW}Cleaning up dangling Docker resources...${NC}"
docker system prune -af
docker volume prune -f
docker network prune -f

echo -e "${YELLOW}Stopping and removing Redis and MariaDB services...${NC}"
sudo systemctl stop redis-server mariadb || true
sudo systemctl disable redis-server mariadb || true

echo -e "${YELLOW}Uninstalling Docker...${NC}"
sudo apt-get purge -y docker docker-engine docker.io containerd runc
sudo apt-get autoremove -y --purge
sudo rm -rf /var/lib/docker /etc/docker

echo -e "${YELLOW}Uninstalling Redis...${NC}"
sudo apt-get purge -y redis-server redis-tools
sudo apt-get autoremove -y --purge
sudo rm -rf /etc/redis /var/lib/redis

echo -e "${YELLOW}Uninstalling MariaDB...${NC}"
sudo apt-get purge -y mariadb-server mariadb-client mariadb-common
sudo apt-get autoremove -y --purge
sudo rm -rf /etc/mysql /var/lib/mysql
sudo rm -rf /etc/mysql*

echo -e "${YELLOW}Performing final cleanup...${NC}"
sudo apt-get autoremove -y
sudo apt-get autoclean
sudo rm -rf ~/frappe_docker

echo -e "${GREEN}Complete uninstallation is done!${NC}"

echo -e "${CYAN}"
echo "==========================================="
echo "     🎉 Thank you 🎉"
echo "==========================================="
echo -e "${NC}"



# Don't exit on error; continue to the next command
set +e

echo "============================================"
echo " Starting COMPLETE Docker Uninstallation..."
echo "============================================"

# 1) Remove/purge Docker packages (various forms)
sudo apt-get purge docker-engine -y || true
sudo apt-get autoremove --purge docker-engine -y || true
sudo rm -rf /var/lib/docker || true
sudo find / -name '*docker*' || true
dpkg -l | grep -i docker || true
sudo apt-get purge -y docker-engine docker docker.io docker-ce docker-ce-cli docker-compose-plugin || true
sudo apt-get autoremove -y --purge docker-engine docker docker.io docker-ce docker-compose-plugin || true

# 2) More Docker purge and directory removal
sudo rm -rf /var/lib/docker /etc/docker || true
sudo rm /etc/apparmor.d/docker || true
sudo apt-get purge -y docker-engine docker docker.io docker-ce || true
sudo apt-get autoremove -y --purge docker-engine docker docker.io docker-ce || true
sudo umount /var/lib/docker/ || true
sudo rm -rf /var/lib/docker /etc/docker || true
sudo rm /etc/apparmor.d/docker || true
sudo groupdel docker || true
sudo rm -rf /var/run/docker.sock || true
sudo rm -rf /usr/bin/docker-compose || true
sudo groupdel docker || true
sudo apt-get purge -y docker-engine docker docker.io docker-ce docker-ce-cli || true
sudo rm -rf /var/run/docker.sock || true

# 3) Remove containerd, Docker config in home, additional Docker packages
sudo rm -rf /var/lib/containerd || true
sudo rm -r ~/.docker || true
sudo apt-get purge docker-ce docker-ce-cli containerd.io -y || true

# 4) Remove Docker libs, final apt remove
sudo rm -rf /var/lib/docker || true
sudo rm -rf /var/lib/containerd || true
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

echo "============================================"
echo " ALL Docker packages & directories removed and ERPNext Uninstalled successfully. "
echo "============================================"
