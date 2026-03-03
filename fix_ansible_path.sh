#!/bin/bash

# Pad naar de audit taak
AUDIT_TASK="roles/audit/tasks/main.yml"

echo "--- Ansible Python Interpreter Fix ---"

# We overschrijven de taak met de {{ ansible_playbook_python }} variabele.
# Deze variabele wijst ALTIJD naar de actieve venv waarin je het playbook start.
cat << 'TASK' > $AUDIT_TASK
---
- name: PDF Genereren op Desktop van gebruiker
  shell: |
    {{ ansible_playbook_python }} -m weasyprint /tmp/audit_{{ inventory_hostname.split('.')[0] }}.html ~/Desktop/Audit_{{ inventory_hostname.split('.')[0] }}_{{ ansible_date_time.date }}.pdf
  delegate_to: localhost
  register: pdf_result
  ignore_errors: yes

- name: Toon resultaat van PDF generatie
  debug:
    msg: "Rapport succesvol op Desktop gezet met: {{ ansible_playbook_python }}"
  when: pdf_result.rc == 0
  delegate_to: localhost

- name: Foutmelding bij ontbrekende module
  debug:
    msg: "FOUT: WeasyPrint niet gevonden in {{ ansible_playbook_python }}. Draai 'pip install weasyprint' IN je venv."
  when: pdf_result.rc != 0
  delegate_to: localhost
TASK

echo "[OK] Ansible taak is nu gekoppeld aan je actieve venv."
echo "Draai nu: ansible-playbook -i inventory/hosts site.yml --ask-vault-pass"
