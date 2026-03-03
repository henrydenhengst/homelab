#!/bin/bash

# Kleuren voor een duidelijk overzicht
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

SERVER_IP="192.168.178.2"

# Lijst van diensten: "Naam|Poort|Pad"
SERVICES=(
    "Portainer|9000|/"
    "Home Assistant|8123|/"
    "Zigbee2MQTT|8080|/"
    "Flame Dashboard|5005|/"
    "ESPHome|6052|/"
)

echo -e "${BLUE}--- Controleer Homelab Web Interfaces op $SERVER_IP ---${NC}\n"

for service in "${SERVICES[@]}"; do
    IFS="|" read -r NAME PORT PATH <<< "$service"
    URL="http://$SERVER_IP:$PORT$PATH"
    
    # Gebruik curl om de header te checken (max 3 seconden wachten)
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 3 "$URL")

    if [[ "$STATUS" == "200" || "$STATUS" == "302" || "$STATUS" == "301" || "$STATUS" == "307" ]]; then
        echo -e "[${GREEN} PASS ${NC}] $NAME is bereikbaar op $URL (Status: $STATUS)"
    else
        echo -e "[${RED} FAIL ${NC}] $NAME is NIET bereikbaar op $URL (Status: $STATUS)"
    fi
done

echo -e "\n${BLUE}--- Test voltooid ---${NC}"
