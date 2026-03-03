#!/bin/bash
VARS_FILE="$HOME/git/homelab/group_vars/all.yml"
ZIGBEE_TASKS="$HOME/git/homelab/roles/zigbee2mqtt/tasks/main.yml"

# 1. Voeg timezone toe aan de globale variabelen als deze nog niet bestaat
if ! grep -q "timezone:" "$VARS_FILE"; then
    echo "timezone: \"Europe/Amsterdam\"" >> "$VARS_FILE"
    echo "Tijdzone toegevoegd aan $VARS_FILE"
else
    sed -i 's|timezone:.*|timezone: "Europe/Amsterdam"|' "$VARS_FILE"
    echo "Tijdzone bijgewerkt in $VARS_FILE"
fi

# 2. Zorg dat de Zigbee2MQTT taak de variabele correct gebruikt
# We herschrijven hem even strak om zeker te weten dat er geen typo's zitten
cat << 'INNER' > "$ZIGBEE_TASKS"
---
- name: Maak Zigbee2MQTT directory
  file:
    path: "{{ docker_base_path }}/zigbee2mqtt/data"
    state: directory
    mode: '0755'

- name: Start Zigbee2MQTT container
  docker_container:
    name: zigbee2mqtt
    image: koenkk/zigbee2mqtt:latest
    state: started
    restart_policy: unless-stopped
    networks:
      - name: "{{ docker_network_name }}"
    volumes:
      - "{{ docker_base_path }}/zigbee2mqtt/data:/app/data"
      - /run/udev:/run/udev:ro
    devices:
      - "{{ zigbee_device }}:{{ zigbee_device }}"
    env:
      TZ: "{{ timezone }}"
INNER

echo "Zigbee2MQTT taken zijn nu synchroon met de tijdzone."
