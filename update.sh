#!/bin/bash

# --- 1. Variabelen (Inclusief main_user) ---
cat << 'INNER' > ~/git/homelab/group_vars/all/vars.yml
---
main_user: "henry"
docker_base_path: "/opt/docker"
docker_network_name: "t2_network"
domain: "duckdns.org"
acme_email: "henrydenhengst@gmail.com"

# Subdomein Definities
flame_subdomain: "denhengst"
ha_subdomain: "ha"
zigbee_subdomain: "zigbee"
esphome_subdomain: "esphome"
portainer_subdomain: "portainer"
INNER

# --- 2. Home Assistant Template (Het missende stukje) ---
mkdir -p ~/git/homelab/roles/homeassistant/templates
cat << 'INNER' > ~/git/homelab/roles/homeassistant/templates/configuration.yaml.j2
default_config:

# --- Netwerk & Proxy ---
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 127.0.0.1
    - 172.16.0.0/12

# --- Database & MQTT ---
recorder:
  db_url: postgresql://homeassistant:{{ vault_postgres_password }}@postgres_db/homeassistant
  purge_keep_days: 30

mqtt:
  broker: mosquitto
  discovery: true

# --- URLs ---
homeassistant:
  name: "Henry's Homelab"
  time_zone: "Europe/Amsterdam"
  external_url: "https://{{ ha_subdomain }}.{{ domain }}"
  internal_url: "http://homeassistant:8123"
INNER

# --- 3. PostgreSQL Task (Met de juiste user permissies) ---
cat << 'INNER' > ~/git/homelab/roles/postgres/tasks/main.yml
---
- name: Maak directory voor Postgres data
  file:
    path: "{{ docker_base_path }}/postgres/data"
    state: directory
    owner: "{{ main_user }}"
    group: "{{ main_user }}"
    mode: '0755'

- name: Start PostgreSQL container
  docker_container:
    name: postgres_db
    image: postgres:16-alpine
    state: started
    restart_policy: unless-stopped
    networks:
      - name: "{{ docker_network_name }}"
    ports:
      - "5432:5432"
    volumes:
      - "{{ docker_base_path }}/postgres/data:/var/lib/postgresql/data"
    env:
      POSTGRES_USER: homeassistant
      POSTGRES_DB: homeassistant
      POSTGRES_PASSWORD: "{{ vault_postgres_password }}"

- name: Wacht tot PostgreSQL klaar is
  wait_for:
    port: 5432
    host: localhost
    delay: 5
    timeout: 30
INNER

# --- 4. Caddyfile Template ---
cat << 'INNER' > ~/git/homelab/roles/caddy/templates/Caddyfile.j2
{
    email {{ acme_email }}
}

{{ ha_subdomain }}.{{ domain }} {
    reverse_proxy homeassistant:8123
}

{{ flame_subdomain }}.{{ domain }} {
    reverse_proxy flame:5005
}

{{ portainer_subdomain }}.{{ domain }} {
    reverse_proxy portainer:9000
}

{{ esphome_subdomain }}.{{ domain }} {
    reverse_proxy 172.17.0.1:6052
}
INNER

# --- 5. Home Assistant Task ---
cat << 'INNER' > ~/git/homelab/roles/homeassistant/tasks/main.yml
---
- name: Maak directory voor Home Assistant configuratie
  file:
    path: "{{ docker_base_path }}/homeassistant"
    state: directory
    mode: '0755'

- name: Plaats Home Assistant configuratie
  template:
    src: configuration.yaml.j2
    dest: "{{ docker_base_path }}/homeassistant/configuration.yaml"
    mode: '0644'
    force: yes

- name: Start Home Assistant container
  docker_container:
    name: homeassistant
    image: ghcr.io/home-assistant/home-assistant:stable
    state: started
    restart_policy: unless-stopped
    networks:
      - name: "{{ docker_network_name }}"
    privileged: true
    volumes:
      - "{{ docker_base_path }}/homeassistant:/config"
      - /etc/localtime:/etc/localtime:ro
      - /run/dbus:/run/dbus:ro
    env:
      TZ: "Europe/Amsterdam"
    published_ports:
      - "8123:8123"
INNER

echo "Alle Ansible configs zijn hersteld en gesynchroniseerd!"
