cat << 'EOF' > fix_networks.sh
#!/bin/bash
REPO="$HOME/git/homelab"

# Fix Mosquitto
sed -i '/restart_policy: unless-stopped/a \    networks:\n      - name: "{{ docker_network_name }}"' $REPO/roles/mosquitto/tasks/main.yml

# Fix Zigbee2MQTT
sed -i '/restart_policy: unless-stopped/a \    networks:\n      - name: "{{ docker_network_name }}"' $REPO/roles/zigbee2mqtt/tasks/main.yml

# Fix Portainer
sed -i '/restart_policy: unless-stopped/a \    networks:\n      - name: "{{ docker_network_name }}"' $REPO/roles/portainer/tasks/main.yml

echo "Netwerk-koppelingen zijn toegevoegd aan de tasks."
EOF

bash fix_networks.sh
