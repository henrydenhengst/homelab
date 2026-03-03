#!/bin/bash

# 1. Update de Inventory om de juiste Python te forceren voor localhost
# We voegen 'ansible_python_interpreter' toe aan de localhost definitie
if [ -f "inventory/hosts" ]; then
    sed -i '/localhost/d' inventory/hosts
    echo "localhost ansible_connection=local ansible_python_interpreter=\"{{ ansible_playbook_python }}\"" >> inventory/hosts
    echo "[OK] Inventory aangepast: localhost gebruikt nu de actieve venv Python."
fi

# 2. Update de Audit Task voor de zekerheid
AUDIT_TASK="roles/audit/tasks/main.yml"
mkdir -p roles/audit/tasks
cat << 'TASK' > $AUDIT_TASK
---
- name: PDF Genereren op Desktop van gebruiker
  shell: |
    "{{ ansible_python_interpreter }}" -m weasyprint /tmp/audit_{{ inventory_hostname.split('.')[0] }}.html ~/Desktop/Audit_{{ inventory_hostname.split('.')[0] }}_{{ ansible_date_time.date }}.pdf
  delegate_to: localhost
  register: pdf_result
  ignore_errors: yes

- name: Debug Output
  debug:
    msg: "Gebruikte Python: {{ ansible_python_interpreter }}"
  delegate_to: localhost
TASK

echo "[OK] Ansible taak en Inventory zijn nu synchroon met je venv."
echo "Draai nu: ansible-playbook -i inventory/hosts site.yml --ask-vault-pass"
