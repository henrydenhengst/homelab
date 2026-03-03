#!/bin/bash
BASE_DIR="$HOME/git/homelab/roles/docker/tasks"

# 1. Zorg dat de directory bestaat
mkdir -p "$BASE_DIR"

# 2. Maak de installatie-taken aan (als deze leeg was)
# Opmerking: Ik vul hier de basis Docker-installatie in voor Debian/Ubuntu
cat << 'INNER' > "$BASE_DIR/install.yml"
---
- name: Installeer benodigde systeem pakketten
  apt:
    name:
      - apt-transport-https
      - ca-certificates
      - curl
      - gnupg
      - lsb-release
      - python3-pip
    state: present
    update_cache: yes

- name: Installeer Docker SDK voor Python
  pip:
    name: docker
INNER

# 3. Maak de netwerk-taken aan
cat << 'INNER' > "$BASE_DIR/network.yml"
---
- name: "Maak het {{ docker_network_name }} netwerk aan"
  docker_network:
    name: "{{ docker_network_name }}"
    driver: bridge
INNER

# 4. Herstel de main.yml met de juiste relatieve paden
cat << 'INNER' > "$BASE_DIR/main.yml"
---
- name: Installatie van Docker engine
  include_tasks: install.yml

- name: Configuratie van Docker netwerken
  include_tasks: network.yml
INNER

echo "De Docker rol is nu structureel hersteld in $BASE_DIR"
ls -l "$BASE_DIR"
