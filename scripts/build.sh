#!/bin/bash

# ----- Colors -----
GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RESET="\033[0m"

echo -e "${BLUE}==> Checking if Docker is running...${RESET}"
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}Docker is not running!${RESET}"
    echo -e "${YELLOW}On macOS: Open Docker Desktop manually.${RESET}"
    echo -e "${YELLOW}On Linux: Try 'sudo systemctl start docker'${RESET}"
    exit 1
fi

echo -e "${BLUE}==> Building Docker image (amd64)...${RESET}"
docker build --platform=linux/amd64 -t myenv .

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Docker image built successfully!${RESET}"
else
    echo -e "${RED}Docker build FAILED!${RESET}"
    exit 1
fi
