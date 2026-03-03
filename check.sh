#!/bin/bash
REPO="$HOME/git/homelab"
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}--- Homelab Enterprise Audit ---${NC}"

# 1. Bestands-integriteit
FILES=(
  "roles/mosquitto/templates/mosquitto.conf.j2"
  "roles/mosquitto/tasks/main.yml"
  "roles/zigbee2mqtt/tasks/main.yml"
  "roles/portainer/tasks/main.yml"
  "roles/flame/tasks/main.yml"
)

echo -e "\n[Stap 1: De Kornuiten Check]"
for f in "${FILES[@]}"; do
    if [ -f "$REPO/$f" ]; then
        echo -e "[${GREEN}OK${NC}] Gevonden: $f"
    else
        echo -e "[${RED}FAIL${NC}] Ontbreekt: $f"
    fi
done

# 2. Netwerk-isolatie Check
echo -e "\n[Stap 2: Netwerk & DNS Check]"
ROLES_TO_CHECK=("homeassistant" "postgres" "mosquitto" "zigbee2mqtt" "portainer")
for role in "${ROLES_TO_CHECK[@]}"; do
    if grep -q "networks:" "$REPO/roles/$role/tasks/main.yml" && grep -q "docker_network_name" "$REPO/roles/$role/tasks/main.yml"; then
        echo -e "[${GREEN}OK${NC}] $role is gekoppeld aan t2_network."
    else
        echo -e "[${RED}FAIL${NC}] $role mist netwerk-koppeling!"
    fi
done

# 3. Home Assistant x Mosquitto koppeling
echo -e "\n[Stap 3: Service Koppeling Check]"
HA_TEMPLATE="$REPO/roles/homeassistant/templates/configuration.yaml.j2"
if grep -q "broker: mosquitto" "$HA_TEMPLATE"; then
    echo -e "[${GREEN}OK${NC}] Home Assistant weet de MQTT Broker (mosquitto) te vinden."
else
    echo -e "[${RED}FAIL${NC}] Home Assistant MQTT configuratie wijst niet naar 'mosquitto'!"
fi

# 4. Volume Persistentie Check (Gaan we data verliezen?)
echo -e "\n[Stap 4: Data Persistentie Check]"
if grep -q "{{ docker_base_path }}" "$REPO/roles/mosquitto/tasks/main.yml"; then
    echo -e "[${GREEN}OK${NC}] Mosquitto data staat op /opt/docker."
else
    echo -e "[${RED}FAIL${NC}] Mosquitto volumes lijken niet correct geconfigureerd!"
fi

echo -e "\n${GREEN}--- Audit Voltooid ---${NC}"
