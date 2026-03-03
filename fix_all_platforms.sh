#!/bin/bash

echo "--- Universele PDF-Tool Fix ---"

# 1. Installeer de basis (voor Linux/WSL gebruikers)
sudo apt update && sudo apt install -y python3-pip libpango-1.0-0 libharfbuzz0b libpangoft2-1.0-0

# 2. Installeer de module direct in de actieve Python omgeving
python3 -m pip install --upgrade pip
python3 -m pip install weasyprint

# 3. Update de Ansible Task (robuuste aanroep naar de module)
AUDIT_TASK="roles/audit/tasks/main.yml"
cat << 'TASK' > $AUDIT_TASK
---
- name: PDF Genereren op Desktop van gebruiker
  shell: |
    python3 -m weasyprint /tmp/audit_{{ inventory_hostname }}.html ~/Desktop/Audit_{{ inventory_hostname }}_{{ ansible_date_time.date }}.pdf
  delegate_to: localhost
  ignore_errors: yes

- name: Check of bestand bestaat op Desktop
  stat:
    path: "~/Desktop/Audit_{
