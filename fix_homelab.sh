#!/bin/bash

echo "--- 1. Zigbee2MQTT Frontend Fix ---"
mkdir -p roles/zigbee2mqtt/templates roles/zigbee2mqtt/tasks
cat << 'Z2M_TEMP' > roles/zigbee2mqtt/templates/configuration.yaml.j2
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
Z2M_TEMP

echo "--- 2. PDF Audit Rol (Cross-Platform) Fix ---"
mkdir -p roles/audit/tasks
cat << 'AUDIT_TASK' > roles/audit/tasks/main.yml
---
- name: PDF Genereren op Desktop van gebruiker
  shell: |
    {{ ansible_playbook_python }} -m weasyprint /tmp/audit_{{ inventory_hostname }}.html ~/Desktop/Audit_{{ inventory_hostname }}_{{ ansible_date_time.date }}.pdf
  delegate_to: localhost
  register: pdf_status
  ignore_errors: yes

- name: Resultaat van de Audit
  debug:
    msg: "Rapport succesvol op je Desktop gezet via Python: {{ ansible_playbook_python }}"
  when: pdf_status.rc == 0
  delegate_to: localhost
AUDIT_TASK

echo "--- 3. Lokale Afhankelijkheden Check ---"
if [[ "$VIRTUAL_ENV" != "" ]]; then
    echo "Gedetecteerd: Je zit in een venv. Installeren van WeasyPrint..."
    pip install --upgrade pip
    pip install weasyprint
else
    echo "WAARSCHUWING: Geen venv actief! Voor de beste resultaten: source venv/bin/activate"
    python3 -m pip install --user weasyprint
fi

echo -e "\n[KLAAR] Alles is ingesteld. Draai nu het playbook:"
echo "ansible-playbook -i inventory/hosts site.yml --ask-vault-pass"
