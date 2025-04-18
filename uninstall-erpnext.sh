#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}"
echo "==========================================="
echo "       🚀 Developed by Vohala 🚀"
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
