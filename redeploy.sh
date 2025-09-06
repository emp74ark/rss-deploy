#!/bin/bash

RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
NC='\e[0m'

if [ "$1" == "dev" ]; then
  COMPOSE_FILE="compose.dev.yaml"
elif [ "$1" == "prod" ]; then
  COMPOSE_FILE="compose.prod.yaml"
else
  echo -e "${RED}Error: Incorrect environment name. Currently supported: dev, prod${NC}"
  echo -e "${YELLOW}Usage: $0 <dev|prod>${NC}"
  exit 1
fi

echo -e "${CYAN}Starting deployment for '$1' environment using Docker Compose file: ${BLUE}$COMPOSE_FILE${NC}"

echo -e "${YELLOW}Step 1: Backup database...${NS}"
bash ./backup.sh backup || { echo -e "${RED}Error: Failed to stop backup the database.${NC}"; exit 1; }

echo -e "${YELLOW}Step 2: Removing dangling volumes...${NC}"
docker volume ls -f dangling=true -q | xargs docker volume rm || true

echo -e "${YELLOW}Step 3: Stopping running containers defined in ${BLUE}$COMPOSE_FILE${NC}..."
docker compose -f "$COMPOSE_FILE" down || { echo -e "${RED}Error: Failed to stop Docker containers.${NC}"; exit 1; }

echo -e "${YELLOW}Step 4: Cleaning up unused Docker images, containers, and networks...${NC}"
docker system prune -af || { echo -e "${RED}Error: Failed to clean up Docker system.${NC}"; exit 1; }

echo -e "${YELLOW}Step 5: Bringing up new images and containers defined in ${BLUE}$COMPOSE_FILE${NC}..."
docker compose -f "$COMPOSE_FILE" up -d || { echo -e "${RED}Error: Failed to start Docker containers.${NC}"; exit 1; }

echo -e "${GREEN}Deployment for '$1' environment complete successfully!${NC}"
