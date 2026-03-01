#!/bin/bash

echo "=== 1. CHECKING NETWORK DEFINITIONS ==="
grep -r "network_mode:" roles/ | grep "host"
grep -r "networks:" roles/ -A 1 | grep "name:"

echo -e "\n=== 2. CHECKING CADDY PROXY TARGETS ==="
if [ -f roles/caddy/templates/Caddyfile.j2 ]; then
    grep "reverse_proxy" roles/caddy/templates/Caddyfile.j2
else
    echo "Caddyfile template not found!"
fi

echo -e "\n=== 3. CHECKING CONTAINER NAMES (Internal DNS) ==="
grep -r "container_name:" roles/ | awk '{print $NF}'
grep -r "name:" roles/*/tasks/main.yml | grep "docker_container" -A 1 | grep "name:"

echo -e "\n=== 4. CHECKING PORT CONFLICTS ==="
grep -r "ports:" roles/ -A 1 | grep "-" | sort | uniq -c | grep -v "1 " && echo "Geen dubbele poorten gevonden." || echo "Check de bovenstaande poorten op duplicaten!"
