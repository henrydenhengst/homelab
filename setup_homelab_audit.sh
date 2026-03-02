#!/bin/bash
# =================================================================
# Enterprise Homelab Audit Builder v7.0 (Cross-Platform)
# Automatiseert: Mappen, Rollen, Variabelen & PDF-Templates
# Gebruiker: $USER (Dynamisch gedetecteerd)
# =================================================================

# 1. Omgevingsvariabelen bepalen
CURRENT_USER=$(whoami)
OS_TYPE="$(uname -s)"
IS_WSL=$(grep -i microsoft /proc/version 2>/dev/null)
REPO_DIR=$(pwd)
ROLE_DIR="$REPO_DIR/roles/audit"

echo "-----------------------------------------------------"
echo "🚀 Start Setup voor gebruiker: $CURRENT_USER"
echo "💻 Systeem: $OS_TYPE $([[ -n "$IS_WSL" ]] && echo '(Windows WSL2)')"
echo "-----------------------------------------------------"

# 2. Mappenstructuur aanmaken (Forceer de juiste Ansible-standaard)
mkdir -p "$ROLE_DIR"/{tasks,templates,vars}

# 3. Dynamische Variabelen schrijven (vars/main.yml)
# De 'lookup' zorgt dat Ansible altijd de HOME van de laptop/pc pakt.
cat <<EOF > "$ROLE_DIR/vars/main.yml"
---
# De plek waar je PDF's verschijnen op je laptop/pc
audit_base_dir: "{{ lookup('env','HOME') }}/homelab-reports"
audit_owner: "$CURRENT_USER"
# Bestandsnaam timestamp: jjjj-mm-dd_uumi
audit_date: "{{ ansible_date_time.date }}_{{ ansible_date_time.hour }}{{ ansible_date_time.minute }}"
EOF

# 4. De Audit Logica (tasks/main.yml)
cat <<EOF > "$ROLE_DIR/tasks/main.yml"
---
- name: "Remote: Systeemdata verzamelen van server"
  block:
    - name: "Lynis Hardening Score uitlezen"
      ansible.builtin.shell: "grep 'Hardening index' /var/log/lynis-report.dat | cut -d= -f2"
      register: lynis_raw
      failed_when: false
      changed_when: false

    - name: "Lijst met actieve Docker containers ophalen"
      ansible.builtin.command: "docker ps --format '{% raw %}{{.Names}}{% endraw %}'"
      register: docker_names
      changed_when: false
      ignore_errors: true

- name: "Local: Rapportage bouwen op deze machine (\$USER)"
  delegate_to: localhost
  become: no
  block:
    - name: "Zorg dat de rapportagemap bestaat: {{ audit_base_dir }}"
      ansible.builtin.file:
        path: "{{ audit_base_dir }}"
        state: directory
        mode: '0755'

    - name: "HTML rapportage voorbereiden"
      ansible.builtin.template:
        src: server_report.html.j2
        dest: "/tmp/audit_{{ inventory_hostname }}.html"

    - name: "PDF Genereren via WeasyPrint"
      ansible.builtin.shell: "weasyprint /tmp/audit_{{ inventory_hostname }}.html {{ audit_base_dir }}/Audit_{{ inventory_hostname }}_{{ audit_date }}.pdf"
      ignore_errors: true
EOF

# 5. Het Visuele PDF Ontwerp (templates/server_report.html.j2)
cat <<EOF > "$ROLE_DIR/templates/server_report.html.j2"
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: 'Helvetica', sans-serif; color: #2c3e50; padding: 40px; }
        .header { border-bottom: 4px solid #34495e; padding-bottom: 10px; margin-bottom: 30px; }
        .badge { 
            float: right; padding: 20px; border-radius: 8px; color: white; font-weight: bold;
            background: {{ '#27ae60' if (lynis_raw.stdout|default(0)|int > 70) else '#e67e22' if (lynis_raw.stdout|default(0)|int > 50) else '#c0392b' }};
        }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { text-align: left; padding: 12px; border-bottom: 1px solid #ecf0f1; }
        th { background: #f8f9fa; color: #7f8c8d; text-transform: uppercase; font-size: 12px; }
        .footer { margin-top: 60px; font-size: 0.8em; color: #bdc3c7; text-align: center; border-top: 1px solid #eee; padding-top: 20px; }
    </style>
</head>
<body>
    <div class="badge">
        LYNIS SCORE<br>
        <span style="font-size: 28px;">{{ lynis_raw.stdout | default('0') | trim }}%</span>
    </div>
    <div class="header">
        <h1>Server Audit Rapport</h1>
        <p>Beheerder: <strong>{{ audit_owner }}</strong> | Host: <strong>{{ inventory_hostname }}</strong></p>
    </div>
    
    <h3>Systeem Specificaties</h3>
    <table>
        <tr><th>Onderdeel</th><th>Waarde</th></tr>
        <tr><td>Besturingssysteem</td><td>{{ ansible_distribution }} {{ ansible_distribution_version }}</td></tr>
        <tr><td>Kernel</td><td>{{ ansible_kernel }}</td></tr>
        <tr><td>CPU / Cores</td><td>{{ ansible_processor_vcpus }} vCPUs</td></tr>
        <tr><td>Geheugen (RAM)</td><td>{{ (ansible_memtotal_mb / 1024) | round(2) }} GB</td></tr>
        <tr><td>IP Adres</td><td>{{ ansible_default_ipv4.address }}</td></tr>
    </table>

    <h3>Actieve Docker Services</h3>
    <ul>
    {% for name in docker_names.stdout_lines %}
        <li><strong>{{ name }}</strong></li>
    {% else %}
        <li><em>Geen containers actief op dit systeem.</em></li>
    {% endfor %}
    </ul>

    <div class="footer">
        Dit rapport is automatisch gegenereerd voor $CURRENT_USER op {{ ansible_date_time.date }}
    </div>
</body>
</html>
EOF

# 6. Systeem-specifieke instructies
echo "-----------------------------------------------------"
echo -e "\033[0;32m✅ Setup voltooid voor $CURRENT_USER!\033[0m"
echo "-----------------------------------------------------"

if [[ "$OS_TYPE" == "Darwin" ]]; then
    echo "🍎 Mac gedetecteerd. Installeer PDF-support:"
    echo "   brew install pango && pip3 install weasyprint"
elif [[ -n "$IS_WSL" ]]; then
    echo "🪟 Windows (WSL2) gedetecteerd. Installeer PDF-support:"
    echo "   sudo apt update && sudo apt install python3-weasyprint -y"
else
    echo "🐧 Linux gedetecteerd. Installeer PDF-support:"
    echo "   sudo apt update && sudo apt install python3-weasyprint -y"
fi

echo ""
echo "👉 Volgende stappen:"
echo "1. Voeg '- audit' toe aan je site.yml rollen-sectie."
echo "2. Run: ansible-playbook site.yml --ask-vault-pass"
echo "3. Bekijk je PDF in ~/homelab-reports/"
