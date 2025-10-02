#!/bin/bash

RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
NC='\e[0m'

DB_CONTAINER="feedz-db"
DB_NAME="rss"

if [ "$1" ]; then
  BACKUP_ROOT_FOLDER="$1"
else
  BACKUP_ROOT_FOLDER="backup"
fi

echo -e "${CYAN}Starting database backup process...${NC}"

if [ ! -d "$BACKUP_ROOT_FOLDER" ]; then
  echo -e "${YELLOW}Creating main backup folder: '$BACKUP_ROOT_FOLDER'${NC}"
  mkdir "$BACKUP_ROOT_FOLDER" || { echo -e "${RED}Error: Failed to create the main backup folder '$BACKUP_ROOT_FOLDER'.${NC}"; exit 1; }
else
  echo -e "${YELLOW}Main backup folder '$BACKUP_ROOT_FOLDER' already exists.${NC}"
fi

cd "$BACKUP_ROOT_FOLDER" || { echo -e "${RED}Error: Failed to navigate into the main backup folder '$BACKUP_ROOT_FOLDER'.${NC}"; exit 1; }

CURRENT_BACKUP_TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
echo -e "${YELLOW}Creating current backup folder: '$CURRENT_BACKUP_TIMESTAMP'${NC}"
mkdir "$CURRENT_BACKUP_TIMESTAMP" || { echo -e "${RED}Error: Failed to create current backup folder '$CURRENT_BACKUP_TIMESTAMP'.${NC}"; exit 1; }

cd "$CURRENT_BACKUP_TIMESTAMP" || { echo -e "${RED}Error: Failed to navigate into current backup folder '$CURRENT_BACKUP_TIMESTAMP'.${NC}"; exit 1; }

echo -e "${BLUE}Attempting to create DB backup...${NC}"

docker exec -it "$DB_CONTAINER" rm -rf /db || { echo -e "${RED}Error: Failed to clear '/db' in ${DB_CONTAINER} container.${NC}"; exit 1; }

docker exec -it "$DB_CONTAINER" mongodump --db="$DB_NAME" --out=db || { echo -e "${RED}Error: Failed to execute mongodump in ${DB_CONTAINER} container.${NC}"; exit 1; }

docker cp "$DB_CONTAINER":/db . || { echo -e "${RED}Error: Failed to copy database backup from db container.${NC}"; exit 1; }

echo -e "${GREEN}DB backup done! Backup saved to: $(pwd)${NC}"
