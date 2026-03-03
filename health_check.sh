#!/bin/bash

# Kleuren voor de output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

SERVER_IP="192.168.178.2"
CONTAINERS=("portainer" "mosquitto" "zigbee2mqtt" "homeassistant" "postgres" "caddy" "esphome" "flame")

echo -e "--- Start Homelab Health Check op $SERVER_IP ---\n"

# 1. Check Docker Containers via SSH
echo "[1/3] Controleren van Docker container status..."
for container in "${CONTAINERS[@]}"; do
    STATUS=$(ssh henry@$SERVER_IP "docker inspect -f '{{.State.Running}}' $container 2>/dev/null")
    if [ "$STATUS" == "true" ]; then
        echo -e "  [${GREEN}OK${NC}] $container draait."
    else
        echo -e "  [${RED}FAIL${NC}] $container is gestopt of bestaat niet."
    fi
done

# 2. Check Web Interfaces (HTTP Response codes)
echo -e "\n[2/3] Controleren van web-interfaces..."
declare -A SERVICES=( ["Portainer"]="9000" ["Home Assistant"]="8123" ["Zigbee2MQTT"]="8080" ["Flame"]="5005" )

for service in "${!SERVICES[@]}"; do
    PORT=${SERVICES[$service]}
    CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "http://$SERVER_IP:$PORT")
    if [[ "$CODE" == "200" || "$CODE" == "302" || "$CODE" == "301" ]]; then
        echo -e "  [${GREEN}OK${NC}] $service bereikbaar op poort $PORT (HTTP $CODE)."
    else
        echo -e "  [${RED}FAIL${NC}] $service NIET bereikbaar op poort $PORT (HTTP $CODE)."
    fi
done

# 3. Check Firewall Status
echo -e "\n[3/3] Controleren van UFW Firewall..."
UFW_STATUS=$(ssh henry@$SERVER_IP "sudo ufw status | grep -i 'active'")
if [[ $UFW_STATUS == *"active"* ]]; then
    echo -e "  [${GREEN}OK${NC}] Firewall is actief."
else
    echo -e "  [${RED}FAIL${NC}] Firewall staat uit!"
fi

echo -e "\n--- Health Check Voltooid ---"
