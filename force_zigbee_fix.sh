#!/bin/bash
ZIGBEE_TASKS="$HOME/git/homelab/roles/zigbee2mqtt/tasks/main.yml"

# 1. Update de task naar force: yes
sed -i 's/force: no/force: yes/' "$ZIGBEE_TASKS"

# 2. Voeg een stap toe om de rechten op de host goed te zetten
# We doen dit door de container als 'root' te laten draaien of de groep mee te geven.
# De snelste fix is de 'privileged' mode of de juiste group_add.
sed -i '/devices:/i \    privileged: true' "$ZIGBEE_TASKS"

echo "Zigbee2MQTT task geforceerd en geprivilegieerd."
