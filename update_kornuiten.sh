#!/bin/bash
REPO="$HOME/git/homelab"

# --- 1. Mosquitto (De MQTT Broker) ---
mkdir -p $REPO/roles/mosquitto/templates
mkdir -p $REPO/roles/mosquitto/tasks

cat << 'INNER' > $REPO/roles/mosquitto/templates/mosquitto.conf.j2
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log
listener 1883
allow_anonymous true
INNER

cat << 'INNER' > $REPO/roles/mosquitto/tasks/main.yml
---
- name: Maak Mosquitto directories
  file:
    path: "{{ docker_base_path }}/mosquitto/{{ item }}"
    state: directory
    mode: '0755'
  loop: [ 'config', 'data', 'log' ]

- name: Plaats mosquitto.conf
  template:
    src: mosquitto.conf.j2
    dest: "{{ docker_base_path }}/mosquitto/config/mosquitto.conf"

- name: Start Mosquitto container
  docker_container:
    name: mosquitto
    image: eclipse-mosquitto:latest
    state: started
    restart_policy: unless-stopped
    networks:
      - name: "{{ docker_network_name }}"
    ports:
      - "1883:1883"
    volumes:
      - "{{ docker_base_path }}/mosquitto/config/mosquitto.conf:/mosquitto/config/mosquitto.conf"
      - "{{ docker_base_path }}/mosquitto/data:/mosquitto/data"
      - "{{ docker_base_path }}/mosquitto/log:/mosquitto/log"
INNER

# --- 2. Zigbee2MQTT ---
cat << 'INNER' > $REPO/roles/zigbee2mqtt/tasks/main.yml
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
      - "/dev/ttyUSB0:/dev/ttyUSB0"  # PAS DIT AAN als je stick op een andere poort zit!
    env:
      TZ: "Europe/Amsterdam"
INNER

# --- 3. Portainer (De cockpit) ---
cat << 'INNER' > $REPO/roles/portainer/tasks/main.yml
---
- name: Maak Portainer volume directory
  file:
    path: "{{ docker_base_path }}/portainer/data"
    state: directory
    mode: '0755'

- name: Start Portainer container
  docker_container:
    name: portainer
    image: portainer/portainer-ce:latest
    state: started
    restart_policy: unless-stopped
    networks:
      - name: "{{ docker_network_name }}"
    ports:
      - "9000:9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - "{{ docker_base_path }}/portainer/data:/data"
INNER

# --- 4. Flame (Je Dashboard) ---
cat << 'INNER' > $REPO/roles/flame/tasks/main.yml
---
- name: Maak Flame directory
  file:
    path: "{{ docker_base_path }}/flame/data"
    state: directory
    mode: '0755'

- name: Start Flame container
  docker_container:
    name: flame
    image: pawelmalak/flame:latest
    state: started
    restart_policy: unless-stopped
    networks:
      - name: "{{ docker_network_name }}"
    volumes:
      - "{{ docker_base_path }}/flame/data:/app/data"
    env:
      PASSWORD: "{{ vault_flame_password | default('admin') }}"
INNER

echo "Kornuiten zijn ingeregeld en klaar voor het netwerk!"
