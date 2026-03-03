#!/bin/bash

# Paden naar de bestanden
Z2M_TEMPLATE="roles/zigbee2mqtt/templates/configuration.yaml.j2"
Z2M_TASKS="roles/zigbee2mqtt/tasks/main.yml"

echo "--- Ansible Fix: Zigbee2MQTT Frontend & Permissions ---"

# 1. Herstel de template (Forceer poort 8080 en frontend)
mkdir -p roles/zigbee2mqtt/templates
cat << 'TEMP' > $Z2M_TEMPLATE
homeassistant: true
permit_join: false
mqtt:
  base_topic: zigbee2mqtt
  server: mqtt://mosquitto:1883
serial:
  port: {{ zigbee_device }}
frontend:
  port: 8080
advanced:
  network_key: GENERATE
  pan_id: GENERATE
  ext_pan_id: GENERATE
TEMP
echo "[OK] Template bijgewerkt: $Z2M_TEMPLATE"

# 2. Herstel de tasks (Forceer config push, privileged mode en auto-restart)
cat << 'TASK' > $Z2M_TASKS
---
- name: Maak Zigbee2MQTT directory
  file:
    path: "{{ docker_base_path }}/zigbee2mqtt/data"
    state: directory
    mode: '0755'

- name: Plaats Zigbee2MQTT configuratie
  template:
    src: configuration.yaml.j2
    dest: "{{ docker_base_path }}/zigbee2mqtt/data/configuration.yaml"
    mode: '0644'
    force: yes
  register: z2m_config

- name: Start Zigbee2MQTT container
  docker_container:
    name: zigbee2mqtt
    image: koenkk/zigbee2mqtt:latest
    state: started
    restart_policy: unless-stopped
    restart: "{{ z2m_config.changed }}"
    privileged: true
    networks:
      - name: "{{ docker_network_name }}"
    volumes:
      - "{{ docker_base_path }}/zigbee2mqtt/data:/app/data"
      - /run/udev:/run/udev:ro
    devices:
      - "{{ zigbee_device }}:{{ zigbee_device }}"
    env:
      TZ: "{{ timezone }}"
TASK
echo "[OK] Tasks bijgewerkt: $Z2M_TASKS"

echo -e "\nFix voltooid. Je kunt nu het playbook draaien:"
echo "ansible-playbook -i inventory/hosts site.yml --ask-vault-pass"
