#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "--- ${GREEN}Starten van Pre-Flight Check${NC} ---\n"

echo -n "1. Check Caddy netwerk modus: "
if grep -q "network_mode: host" roles/caddy/tasks/main.yml; then echo -e "${RED}FOUT${NC}"; else echo -e "${GREEN}OK${NC}"; fi

echo -n "2. Check Caddy netwerk koppeling: "
if grep -Eiq "t2_network|docker_network_name" roles/caddy/tasks/main.yml; then echo -e "${GREEN}OK${NC}"; else echo -e "${RED}FOUT${NC}"; fi

echo -n "3. Check Caddyfile targets: "
if grep -q "flame:5005" roles/caddy/templates/Caddyfile.j2 && grep -q "172.17.0.1:8123" roles/caddy/templates/Caddyfile.j2; then echo -e "${GREEN}OK${NC}"; else echo -e "${RED}FOUT${NC}"; fi

echo -n "4. Check site.yml volgorde: "
if tail -n 5 site.yml | grep -q "role: caddy"; then echo -e "${GREEN}OK${NC}"; else echo -e "${RED}FOUT${NC}"; fi

echo -n "5. Ansible YAML syntax check: "
ansible-playbook site.yml --syntax-check > /dev/null 2>&1
if [ $? -eq 0 ]; then echo -e "${GREEN}OK${NC}"; else echo -e "${RED}FOUT${NC}"; ansible-playbook site.yml --syntax-check; fi

echo -e "\n--- ${GREEN}Check voltooid${NC} ---"
