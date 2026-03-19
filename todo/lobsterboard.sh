#!/usr/bin/env bash
# /home/henry/alpine/containers/lobsterboard/install.sh

set -e

# ========== CONFIGURATIE ==========
DOCKER_NETWORK="homelab_network"
TIMEZONE="Europe/Amsterdam"
LOBBY_PORT="3456"
INSTALL_DIR="/home/henry/alpine/containers/lobsterboard"
PREDICTIVE_DATA_DIR="/home/henry/alpine/containers/predictive-monitoring/data"
# =================================

echo "🦞 LobsterBoard installatie"
echo "==========================="
echo "📁 Installatie: $INSTALL_DIR"
echo "🌐 Netwerk: $DOCKER_NETWORK"
echo "🔌 Poort: $LOBBY_PORT"
echo ""

# Maak directory
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# ========== 1. DOCKERFILE ==========
echo "📝 Dockerfile aanmaken..."
cat > Dockerfile << 'EOF'
FROM node:20-alpine

WORKDIR /app

# Installeer LobsterBoard
RUN apk add --no-cache git && \
    git clone https://github.com/Curbob/LobsterBoard.git . && \
    npm install && \
    apk del git && \
    npm cache clean --force

# Maak data directory
RUN mkdir -p /app/data

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
EOF

# ========== 2. START SCRIPT ==========
echo "📝 start.sh aanmaken..."
cat > start.sh << 'EOF'
#!/bin/sh

# Configuratie via environment variables
cat > /app/data/config.json << CONFIG
{
  "theme": "terminal",
  "terminalGreen": true,
  "refreshInterval": 30,
  "widgets": [
    {
      "type": "welcome",
      "title": "🦞 henry's homelab",
      "message": "Welkom terug! Alles draait zoals verwacht."
    },
    {
      "type": "system",
      "title": "💾 systeem status"
    },
    {
      "type": "docker",
      "title": "🐳 containers"
    },
    {
      "type": "rss",
      "title": "📰 nixos news",
      "url": "https://nixos.org/rss.xml"
    },
    {
      "type": "links",
      "title": "🔗 homelab services",
      "links": [
        { "name": "gotify", "url": "http://gotify:8088", "icon": "🔔" },
        { "name": "dozzle", "url": "http://dozzle:8080", "icon": "📋" },
        { "name": "uptime-kuma", "url": "http://uptime-kuma:3001", "icon": "📈" },
        { "name": "homeassistant", "url": "http://homeassistant:8123", "icon": "🏠" },
        { "name": "zigbee2mqtt", "url": "http://zigbee2mqtt:8080", "icon": "🪴" },
        { "name": "predictive-helper", "url": "http://predictive-web:8081", "icon": "🔮" },
        { "name": "portainer", "url": "http://portainer:9000", "icon": "🐳" }
      ]
    },
    {
      "type": "custom",
      "title": "🔮 predictive data",
      "content": "<pre id='predictive'>laden...</pre>",
      "refresh": 60,
      "script": "fetch('/data/status.json').then(r=>r.json()).then(d=>{document.getElementById('predictive').innerText=JSON.stringify(d.predictions,null,2)})"
    }
  ]
}
CONFIG

# Start LobsterBoard
cd /app
exec node server.cjs
EOF

# ========== 3. COMPOSE.YAML ==========
echo "📝 compose.yaml aanmaken..."
cat > compose.yaml << EOF
name: lobsterboard

services:
  lobby:
    build: .
    container_name: lobsterboard
    restart: unless-stopped
    ports:
      - "${LOBBY_PORT}:8080"
    volumes:
      - ./data:/app/data
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ${PREDICTIVE_DATA_DIR}:/predictive-data:ro
    environment:
      - TZ=${TIMEZONE}
    networks:
      - ${DOCKER_NETWORK}
    mem_limit: 128m
    cpu_shares: 256
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080"]
      interval: 30s
      timeout: 10s
      retries: 3

networks:
  ${DOCKER_NETWORK}:
    external: true
EOF

# ========== 4. CUSTOM THEMA ==========
echo "📝 Retro terminal thema aanpassen..."
mkdir -p data/themes
cat > data/themes/terminal.css << 'EOF'
/* Terminal theme - groen op zwart zoals jij het wilt! */
body {
  background-color: #000000 !important;
  color: #00ff00 !important;
  font-family: 'Courier New', monospace !important;
}

.navbar {
  background-color: #111111 !important;
  border-bottom: 1px solid #00ff00 !important;
}

.card {
  background-color: #111111 !important;
  border: 1px solid #00ff00 !important;
  border-radius: 0 !important;
}

.card-header {
  background-color: #000000 !important;
  border-bottom: 1px solid #00ff00 !important;
  color: #00ff00 !important;
  font-weight: bold;
}

.btn-primary {
  background-color: #000000 !important;
  border: 1px solid #00ff00 !important;
  color: #00ff00 !important;
  border-radius: 0 !important;
}

.btn-primary:hover {
  background-color: #00ff00 !important;
  color: #000000 !important;
}

.table {
  color: #00ff00 !important;
}

.table td, .table th {
  border-top: 1px solid #00ff00 !important;
}

a {
  color: #00ff00 !important;
  text-decoration: none !important;
}

a:hover {
  text-decoration: underline !important;
  background-color: #00ff00 !important;
  color: #000000 !important;
}

pre, code {
  color: #00ff00 !important;
  background-color: #111111 !important;
  border: none !important;
}

/* Progress bars worden groen */
.progress-bar {
  background-color: #00ff00 !important;
}

/* Status indicators */
.text-success { color: #00ff00 !important; }
.text-warning { color: #ffff00 !important; }
.text-danger { color: #ff0000 !important; }

/* Terminal cursor effect */
.cursor {
  animation: blink 1s infinite;
}

@keyframes blink {
  0%, 50% { opacity: 1; }
  51%, 100% { opacity: 0; }
}
EOF

# ========== 5. README ==========
cat > README.md << EOF
# 🦞 LobsterBoard voor Homelab

Retro terminal-style dashboard voor jouw homelab!

## 📁 Locatie
\`$INSTALL_DIR\`

## 🌐 Toegang
Dashboard: http://$(hostname -I | awk '{print $1}'):${LOBBY_PORT}

## 📊 Widgets
- **Systeem stats**: CPU, memory, disk
- **Docker containers**: Live status
- **Homelab links**: Snel naar al je services
- **RSS feed**: NixOS nieuws
- **Predictive data**: Van je helper container

## 🎨 Thema
Terminal theme met groene letters op zwarte achtergrond

## 🔧 Beheer
\`\`\`bash
cd $INSTALL_DIR
docker compose logs -f   # Live logs
docker compose down      # Stoppen
docker compose up -d     # Herstarten
\`\`\`

## 🤝 Integratie
Predictive data komt uit: \`$PREDICTIVE_DATA_DIR/status.json\`
EOF

# ========== 6. BUILD EN START ==========
echo "📦 Bouwen en starten..."
docker compose build
docker compose up -d

# ========== 7. AFsluiting ==========
IP=$(hostname -I | awk '{print $1}')
echo ""
echo "====================================="
echo "✅ LOBSTERBOARD GESTART!"
echo "====================================="
echo ""
echo "📁 Locatie: $INSTALL_DIR"
echo ""
echo "🌐 Dashboard: http://$IP:${LOBBY_PORT}"
echo "   (retro terminal theme - groen op zwart!)"
echo ""
echo "📊 Widgets actief:"
echo "   - Systeem stats"
echo "   - Docker containers"
echo "   - Homelab links"
echo "   - NixOS RSS"
echo "   - Predictive data integratie"
echo ""
echo "🛠️  Beheer:"
echo "   cd $INSTALL_DIR"
echo "   docker compose logs -f"
echo "   docker compose down"
echo "   docker compose up -d"
echo ""

# Permissies
chown -R henry:users "$INSTALL_DIR" 2>/dev/null || true