#!/bin/bash

# 1. Lokale Git hard resetten naar de laatste commit op de server (GitHub)
echo "--- Stap 1: Lokale bestanden synchroniseren met GitHub ---"
git fetch origin
git reset --hard origin/main

# 2. Server opschonen (Docker containers en netwerken verwijderen)
# Dit voorkomt 'network already exists' of 'container name in use' fouten
echo "--- Stap 2: Server Docker omgeving opschonen ---"
ssh henry@192.168.178.2 << 'EOF'
  echo "Stoppen van alle containers..."
  sudo docker stop $(sudo docker ps -q) 2>/dev/null || true
  echo "Verwijderen van alle containers..."
  sudo docker rm $(sudo docker ps -aq) 2>/dev/null || true
  echo "Verwijderen van ongebruikte netwerken..."
  sudo docker network prune -f
EOF

# 3. Ansible Playbook draaien
echo "--- Stap 3: Alles opnieuw uitrollen via Ansible ---"
ansible-playbook site.yml --ask-vault-pass

echo "--- Klaar! De setup is nu identiek aan de laatste GitHub backup. ---"
