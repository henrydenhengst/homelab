#!/bin/bash
REPO="$HOME/git/homelab/roles"

echo "Schoonmaken van Mosquitto..."
cat << 'INNER' > "$REPO/mosquitto/tasks/main.yml"
---
- name: Maak Mosquitto directories
  file:
    path: "{{ item }}"
    state: directory
    mode: '0755'
  with_items:
    - "{{ docker_base_path }}/mosquitto/config"
    - "{{ docker_base_path }}/mosquitto/data"
    - "{{ docker_base_path }}/mosquitto/log"

- name: Kopieer mosquitto.conf
  template:
    src: mosquitto.conf.j2
    dest: "{{ docker_base_path }}/mosquitto/config/mosquitto.conf"
    mode: '0644'

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
      - "9001:9001"
    volumes:
      - "{{ docker_base_path }}/mosquitto/config/mosquitto.conf:/mosquitto/config/mosquitto.conf"
      - "{{ docker_base_path }}/mosquitto/data:/mosquitto/data"
      - "{{ docker_base_path }}/mosquitto/log:/mosquitto/log"
INNER

echo "Schoonmaken van Zigbee2MQTT..."
cat << 'INNER' > "$REPO/zigbee2mqtt/tasks/main.yml"
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

echo "Schoonmaken van Portainer..."
cat << 'INNER' > "$REPO/portainer/tasks/main.yml"
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

echo "Klaar! Alle dubbele keys zijn verwijderd."
