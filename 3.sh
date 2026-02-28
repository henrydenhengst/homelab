#!/bin/bash

# 1. Hernoem de role map
echo "Hernoemen van roles/crowdsec naar roles/fail2ban..."
mv roles/crowdsec roles/fail2ban

# 2. Update site.yml (vervang crowdsec door fail2ban)
echo "Update site.yml..."
sed -i 's/- crowdsec/- fail2ban/g' site.yml

# 3. Schrijf de nieuwe Fail2Ban Tasks
echo "Schrijven van nieuwe tasks/main.yml..."
cat > roles/fail2ban/tasks/main.yml <<EOF
---
- name: Installeer Fail2Ban
  apt:
    name: fail2ban
    state: present
    update_cache: yes

- name: Configureer Fail2Ban (Jail voor SSH en Caddy)
  copy:
    dest: /etc/fail2ban/jail.local
    content: |
      [DEFAULT]
      bantime   = 1h
      findtime  = 10m
      maxretry  = 5
      banaction = ufw

      [sshd]
      enabled = true

      [caddy-auth]
      enabled = true
      port    = http,https
      logpath = {{ docker_base_path }}/caddy/access.log
      filter  = caddy-bad-requests
    owner: root
    group: root
    mode: '0644'
  notify: Restart Fail2Ban

- name: Maak Filter voor Caddy
  copy:
    dest: /etc/fail2ban/filter.d/caddy-bad-requests.conf
    content: |
      [Definition]
      failregex = ^.*"remote_ip":"<HOST>".*"status":(401|403|404).*$
      ignoreregex =
    owner: root
    group: root
    mode: '0644'
  notify: Restart Fail2Ban

- name: Zorg dat Fail2Ban draait
  service:
    name: fail2ban
    state: started
    enabled: yes
EOF

# 4. Schrijf de nieuwe Fail2Ban Handlers
echo "Schrijven van nieuwe handlers/main.yml..."
cat > roles/fail2ban/handlers/main.yml <<EOF
---
- name: Restart Fail2Ban
  service:
    name: fail2ban
    state: restarted
EOF

echo "--- Klaar! De Git-repo is nu klaar voor Fail2Ban. ---"
