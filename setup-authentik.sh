#!/bin/bash

# ==============================================================================
# Authentik toevoegen aan Homelab - Setup Script
# ==============================================================================
# Dit script maakt de benodigde directories en bestanden aan in:
# /home/henry/git/homelab/roles/authentik/
#
# GEBRUIK:
# 1. Sla dit script op als ~/setup-authentik.sh
# 2. Maak het uitvoerbaar: chmod +x ~/setup-authentik.sh
# 3. Voer het uit: ./setup-authentik.sh
#
# LET OP: Dit script overschrijft bestaande bestanden!
# ==============================================================================

set -e  # Stop bij fouten

# Kleuren voor output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================================================${NC}"
echo -e "${GREEN}Authentik toevoegen aan Homelab${NC}"
echo -e "${BLUE}================================================================================${NC}"

# ------------------------------------------------------------------------------
# 1. Base directory bepalen
# ------------------------------------------------------------------------------
BASE_DIR="/home/henry/git/homelab"
if [ ! -d "$BASE_DIR" ]; then
    echo -e "${RED}FOUT: Directory $BASE_DIR bestaat niet!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Base directory gevonden: $BASE_DIR${NC}"

# ------------------------------------------------------------------------------
# 2. Authentik directories aanmaken
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}📁 Authentik directories aanmaken...${NC}"

mkdir -p "$BASE_DIR/roles/authentik"/{tasks,defaults,templates,vars}

echo -e "${GREEN}✓ Authentik directories aangemaakt${NC}"

# ------------------------------------------------------------------------------
# 3. Authentik defaults/main.yml
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}📝 Authentik defaults/main.yml aanmaken...${NC}"

cat > "$BASE_DIR/roles/authentik/defaults/main.yml" << 'EOF'
---
# Authentik configuratie
image_authentik_server: "ghcr.io/goauthentik/server:latest"
image_authentik_worker: "ghcr.io/goauthentik/server:latest"
image_authentik_redis: "redis:alpine"

authentik_container_name_server: "authentik-server"
authentik_container_name_worker: "authentik-worker"
authentik_container_name_redis: "authentik-redis"

authentik_subdomain: "auth"
authentik_port_http: 9000
authentik_port_https: 9443

# Geheimen (moeten in secret.yml!)
authentik_secret_key: "{{ vault_authentik_secret_key }}"
authentik_database_password: "{{ vault_authentik_database_password }}"
authentik_redis_password: "{{ vault_authentik_redis_password }}"
authentik_bootstrap_token: "{{ vault_authentik_bootstrap_token }}"
authentik_bootstrap_email: "{{ vault_authentik_bootstrap_email }}"
authentik_bootstrap_password: "{{ vault_authentik_bootstrap_password }}"
EOF

echo -e "${GREEN}  ✓ roles/authentik/defaults/main.yml${NC}"

# ------------------------------------------------------------------------------
# 4. Authentik tasks/main.yml
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}📝 Authentik tasks/main.yml aanmaken...${NC}"

cat > "$BASE_DIR/roles/authentik/tasks/main.yml" << 'EOF'
---
- name: Maak Authentik data directories
  ansible.builtin.file:
    path: "{{ docker_base_path }}/authentik/{{ item }}"
    state: directory
    mode: '0755'
  loop:
    - "certs"
    - "media"
    - "templates"
    - "redis"

- name: Maak Authentik database aan in PostgreSQL
  community.postgresql.postgresql_db:
    name: authentik
    login_host: postgres
    login_user: "{{ vault_postgres_user }}"
    login_password: "{{ vault_postgres_password }}"
    state: present
  delegate_to: localhost
  ignore_errors: yes

- name: Maak Authentik database user aan
  community.postgresql.postgresql_user:
    db: authentik
    name: authentik
    password: "{{ authentik_database_password }}"
    priv: ALL
    login_host: postgres
    login_user: "{{ vault_postgres_user }}"
    login_password: "{{ vault_postgres_password }}"
    state: present
  delegate_to: localhost
  ignore_errors: yes

- name: START AUTHENTIK REDIS
  community.docker.docker_container:
    name: "{{ authentik_container_name_redis }}"
    image: "{{ image_authentik_redis }}"
    state: started
    restart_policy: always
    pull: yes
    recreate: yes
    container_default_behavior: no_defaults
    networks:
      - name: "db_internal"
    volumes:
      - "{{ docker_base_path }}/authentik/redis:/data"
    env:
      REDIS_PASSWORD: "{{ authentik_redis_password }}"
      REDIS_ARGS: "--requirepass {{ authentik_redis_password }}"
    command: ["redis-server", "--requirepass", "{{ authentik_redis_password }}"]
    labels:
      com.docker.compose.service: "authentik-redis"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 3

- name: START AUTHENTIK SERVER
  community.docker.docker_container:
    name: "{{ authentik_container_name_server }}"
    image: "{{ image_authentik_server }}"
    state: started
    restart_policy: always
    pull: yes
    recreate: yes
    container_default_behavior: no_defaults
    networks:
      - name: "t2_network"
      - name: "db_internal"
    volumes:
      - "{{ docker_base_path }}/authentik/certs:/certs"
      - "{{ docker_base_path }}/authentik/media:/media"
      - "{{ docker_base_path }}/authentik/templates:/templates"
    env:
      AUTHENTIK_SECRET_KEY: "{{ authentik_secret_key }}"
      AUTHENTIK_ERROR_REPORTING__ENABLED: "false"
      AUTHENTIK_POSTGRESQL__HOST: "postgres"
      AUTHENTIK_POSTGRESQL__PORT: "{{ port_postgres }}"
      AUTHENTIK_POSTGRESQL__NAME: "authentik"
      AUTHENTIK_POSTGRESQL__USER: "authentik"
      AUTHENTIK_POSTGRESQL__PASSWORD: "{{ authentik_database_password }}"
      AUTHENTIK_REDIS__HOST: "{{ authentik_container_name_redis }}"
      AUTHENTIK_REDIS__PORT: 6379
      AUTHENTIK_REDIS__PASSWORD: "{{ authentik_redis_password }}"
      AUTHENTIK_BOOTSTRAP_TOKEN: "{{ authentik_bootstrap_token }}"
      AUTHENTIK_BOOTSTRAP_EMAIL: "{{ authentik_bootstrap_email }}"
      AUTHENTIK_BOOTSTRAP_PASSWORD: "{{ authentik_bootstrap_password }}"
      TZ: "{{ timezone }}"
    labels:
      com.docker.compose.service: "authentik-server"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:{{ authentik_port_http }}/-/health/live/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

- name: START AUTHENTIK WORKER
  community.docker.docker_container:
    name: "{{ authentik_container_name_worker }}"
    image: "{{ image_authentik_worker }}"
    state: started
    restart_policy: always
    pull: yes
    recreate: yes
    container_default_behavior: no_defaults
    networks:
      - name: "db_internal"
    volumes:
      - "{{ docker_base_path }}/authentik/certs:/certs"
      - "{{ docker_base_path }}/authentik/media:/media"
      - "{{ docker_base_path }}/authentik/templates:/templates"
    env:
      AUTHENTIK_SECRET_KEY: "{{ authentik_secret_key }}"
      AUTHENTIK_ERROR_REPORTING__ENABLED: "false"
      AUTHENTIK_POSTGRESQL__HOST: "postgres"
      AUTHENTIK_POSTGRESQL__PORT: "{{ port_postgres }}"
      AUTHENTIK_POSTGRESQL__NAME: "authentik"
      AUTHENTIK_POSTGRESQL__USER: "authentik"
      AUTHENTIK_POSTGRESQL__PASSWORD: "{{ authentik_database_password }}"
      AUTHENTIK_REDIS__HOST: "{{ authentik_container_name_redis }}"
      AUTHENTIK_REDIS__PORT: 6379
      AUTHENTIK_REDIS__PASSWORD: "{{ authentik_redis_password }}"
      TZ: "{{ timezone }}"
    labels:
      com.docker.compose.service: "authentik-worker"
    healthcheck:
      test: ["CMD-SHELL", "pgrep -f authentik.worker || exit 1"]
      interval: 30s
      timeout: 5s
      retries: 3

- name: Wacht op Authentik server (eerste keer kan lang duren)
  ansible.builtin.wait_for:
    host: "{{ authentik_container_name_server }}"
    port: "{{ authentik_port_http }}"
    delay: 10
    timeout: 300
  ignore_errors: yes

- name: Bevestig dat Authentik containers draaien
  community.docker.docker_container_info:
    name: "{{ item }}"
  register: authentik_containers_info
  loop:
    - "{{ authentik_container_name_redis }}"
    - "{{ authentik_container_name_server }}"
    - "{{ authentik_container_name_worker }}"
  failed_when: not authentik_containers_info.exists or not authentik_containers_info.container.State.Running
EOF

echo -e "${GREEN}  ✓ roles/authentik/tasks/main.yml${NC}"

# ------------------------------------------------------------------------------
# 5. Authentik vars/main.yml (optioneel, voor role-specifieke variabelen)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}📝 Authentik vars/main.yml aanmaken...${NC}"

cat > "$BASE_DIR/roles/authentik/vars/main.yml" << 'EOF'
---
# Role-specifieke variabelen voor Authentik
# Deze overschrijven defaults indien nodig
EOF

echo -e "${GREEN}  ✓ roles/authentik/vars/main.yml${NC}"

# ------------------------------------------------------------------------------
# 6. Toon instructies voor wat je zelf moet doen
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}================================================================================${NC}"
echo -e "${YELLOW}📋 WAT JE ZELF NOG MOET DOEN${NC}"
echo -e "${BLUE}================================================================================${NC}"

echo -e "\n${GREEN}1. Voeg deze variabelen toe aan:${NC} $BASE_DIR/group_vars/all/vars.yml"
echo -e "${BLUE}Voeg toe bij de andere image variabelen (bijv. na Dozzle):${NC}"
cat << 'EOF'

# --- Authentik SSO ---
image_authentik_server: "ghcr.io/goauthentik/server:latest"
image_authentik_worker: "ghcr.io/goauthentik/server:latest"
image_authentik_redis: "redis:alpine"
authentik_subdomain: "auth"
authentik_port_http: 9000
authentik_port_https: 9443
EOF

echo -e "\n${GREEN}2. Voeg deze geheimen toe aan:${NC} $BASE_DIR/group_vars/all/secret.yml"
echo -e "${RED}💡 GENEREER STERKE WACHTWOORDEN!${NC}"
echo -e "${BLUE}Gebruik bijv: openssl rand -base64 32 voor elk geheim${NC}"
cat << 'EOF'

# --- Authentik SSO ---
vault_authentik_secret_key: "een-lang-en-willekeurig-wachtwoord-minimaal-50-tekens"
vault_authentik_database_password: "StrongPasswordForAuthentikDB"
vault_authentik_redis_password: "StrongPasswordForRedis"
vault_authentik_bootstrap_token: "een-lang-en-willekeurig-token-voor-bootstrap"
vault_authentik_bootstrap_email: "admin@denhengst.duckdns.org"
vault_authentik_bootstrap_password: "StrongAdminPasswordForAuthentik"
EOF

echo -e "\n${GREEN}3. Voeg dit blok toe aan:${NC} $BASE_DIR/roles/caddy/templates/Caddyfile.j2"
echo -e "${BLUE}Voeg toe na Uptime Kuma of als aparte sectie:${NC}"
cat << 'EOF'

# Authentik SSO
{{ authentik_subdomain }}.{{ duckdns_domain }}.{{ domain }} {
    import duckdns_auth
    reverse_proxy {{ authentik_container_name_server }}:{{ authentik_port_http }}
}
EOF

echo -e "\n${GREEN}4. Voeg de role toe aan:${NC} $BASE_DIR/site.yml"
echo -e "${RED}⚠️  BELANGRIJK: Authentik moet NA postgres maar VOOR andere rollen!${NC}"
echo -e "${BLUE}Zorg dat 'authentik' in de roles lijst staat op de juiste plek:${NC}"
cat << 'EOF'

- hosts: all
  roles:
    # ... je bestaande rollen
    - postgres          # Moet vóór authentik
    - authentik         # Voeg hier toe
    - uptime_kuma
    - loggifly
    - dozzle
EOF

echo -e "\n${GREEN}5. Versleutel je secret.yml opnieuw:${NC}"
echo -e "   ${BLUE}ansible-vault encrypt $BASE_DIR/group_vars/all/secret.yml${NC}"

echo -e "\n${GREEN}6. Draai het playbook:${NC}"
echo -e "   ${BLUE}ansible-playbook site.yml --ask-vault-pass${NC}"

# ------------------------------------------------------------------------------
# 7. Check of variabelen al bestaan
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}================================================================================${NC}"
echo -e "${YELLOW}🔍 CONTROLE${NC}"
echo -e "${BLUE}================================================================================${NC}"

# Check of vars.yml al authentik heeft
if grep -q "authentik" "$BASE_DIR/group_vars/all/vars.yml" 2>/dev/null; then
    echo -e "${GREEN}✓ Authentik lijkt al in vars.yml te staan${NC}"
else
    echo -e "${RED}✗ Authentik nog niet in vars.yml (moet je toevoegen)${NC}"
fi

# Check of secret.yml al authentik heeft
if grep -q "authentik" "$BASE_DIR/group_vars/all/secret.yml" 2>/dev/null; then
    echo -e "${GREEN}✓ Authentik lijkt al in secret.yml te staan${NC}"
else
    echo -e "${RED}✗ Authentik nog niet in secret.yml (moet je toevoegen)${NC}"
fi

# Check of Caddyfile.j2 al authentik heeft
if grep -q "authentik" "$BASE_DIR/roles/caddy/templates/Caddyfile.j2" 2>/dev/null; then
    echo -e "${GREEN}✓ Authentik lijkt al in Caddyfile.j2 te staan${NC}"
else
    echo -e "${RED}✗ Authentik nog niet in Caddyfile.j2 (moet je toevoegen)${NC}"
fi

# Check of site.yml al authentik bevat
if grep -q "authentik" "$BASE_DIR/site.yml" 2>/dev/null; then
    echo -e "${GREEN}✓ Authentik lijkt al in site.yml te staan${NC}"
else
    echo -e "${RED}✗ Authentik nog niet in site.yml (moet je toevoegen)${NC}"
fi

# ------------------------------------------------------------------------------
# 8. Generators voor sterke wachtwoorden
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}================================================================================${NC}"
echo -e "${YELLOW}🔑 GENEREER STERKE WACHTWOORDEN${NC}"
echo -e "${BLUE}================================================================================${NC}"
echo -e "Gebruik deze commando's om sterke wachtwoorden te genereren:"
echo -e ""
echo -e "  ${GREEN}vault_authentik_secret_key:${NC} openssl rand -base64 48"
echo -e "  ${GREEN}vault_authentik_database_password:${NC} openssl rand -base64 24"
echo -e "  ${GREEN}vault_authentik_redis_password:${NC} openssl rand -base64 24"
echo -e "  ${GREEN}vault_authentik_bootstrap_token:${NC} openssl rand -base64 32"
echo -e "  ${GREEN}vault_authentik_bootstrap_password:${NC} (kies zelf een sterk wachtwoord)"
echo -e ""
echo -e "${YELLOW}Of installeer 'pwgen' en gebruik: pwgen -s 50 1${NC}"

# ------------------------------------------------------------------------------
# 9. Eerste stappen na installatie
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}================================================================================${NC}"
echo -e "${YELLOW}🎯 NA INSTALLATIE - EERSTE STAPPEN${NC}"
echo -e "${BLUE}================================================================================${NC}"
cat << 'EOF'

1. Open https://auth.denhengst.duckdns.org
2. Log in met:
   - Email: admin@denhengst.duckdns.org
   - Wachtwoord: (wat je in vault_authentik_bootstrap_password hebt gezet)
3. Verander direct het admin wachtwoord
4. Stel TOTP in op je telefoon (Aegis aanbevolen)
5. Voeg je YubiKey toe als extra factor
6. Maak een applicatie aan voor een test-service (bijv. Dozzle)

MIGRATIE VAN BASIC_AUTH NAAR AUTHENTIK:
- Fase 1: Installeer Authentik naast bestaande setup
- Fase 2: Configureer 1 simpele app met forward auth
- Fase 3: Test of het werkt, voeg 2FA toe
- Fase 4: Migreer app voor app
- Fase 5: Verwijder basic_auth uit Caddyfile
EOF

# ------------------------------------------------------------------------------
# 10. Samenvatting
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}================================================================================${NC}"
echo -e "${GREEN}✅ Setup voltooid!${NC}"
echo -e "${BLUE}================================================================================${NC}"
echo -e "${YELLOW}Gemaakte bestanden:${NC}"
find "$BASE_DIR/roles/authentik" -type f 2>/dev/null | sed "s|$BASE_DIR/||" | while read f; do
    echo -e "  ${GREEN}✓${NC} $f"
done

echo -e "\n${YELLOW}Volg de instructies hierboven om Authentik volledig te integreren.${NC}"
echo -e "${BLUE}================================================================================${NC}"