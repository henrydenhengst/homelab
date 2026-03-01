mkdir -p group_vars/all
cat << 'EOF' > group_vars/all/vars.yml
---
# --- Domein Instellingen ---
domain: "duckdns.org"
acme_email: "henrydenhengst@gmail.com"

# --- Subdomein Definities ---
flame_subdomain: "denhengst"
ha_subdomain: "ha"
zigbee_subdomain: "zigbee"
esphome_subdomain: "esphome"
portainer_subdomain: "portainer"

# --- Netwerk Instellingen ---
docker_network_name: "t2_network"
EOF
