#!/usr/bin/env bash
# /home/henry/nixos/containers/predictive-monitoring/install.sh

set -e

# ========== CONFIGURATIE ==========
GOTIFY_TOKEN="HIER_JOUW_TOKEN"
DOCKER_NETWORK="homelab_network"
TIMEZONE="Europe/Amsterdam"
WEB_PORT="6789"                    # Obscure poort (aanpasbaar!)
# =================================

echo "🚀 Predictive Monitoring installatie"
echo "====================================="
echo "🌐 Netwerk: $DOCKER_NETWORK"
echo "⏰ Tijdzone: $TIMEZONE"
echo "🔌 Web poort: $WEB_PORT (obscuur)"
echo ""

# Maak directory structuur
echo "📁 Mappen aanmaken..."
mkdir -p /home/henry/nixos/containers/predictive-monitoring/{data,web-config,history,logs}
mkdir -p /home/henry/nixos/containers/predictive-monitoring/data/history

echo "✅ Mappenstructuur klaar"

# ========== 1. NIX BUILD BESTAND ==========
echo "📝 predictive-helper.nix aanmaken..."
cat > /home/henry/nixos/containers/predictive-monitoring/predictive-helper.nix << 'EOF'
{ pkgs ? import <nixpkgs> { } }:

let
  mainScript = pkgs.writeShellScriptBin "predictive-helper" ''
    #!/usr/bin/env bash
    
    DATA_DIR="/data"
    HISTORY_DIR="$DATA_DIR/history"
    LOG_FILE="$DATA_DIR/predictive.log"
    GOTIFY_URL="http://gotify:8088"
    
    mkdir -p "$DATA_DIR" "$HISTORY_DIR"
    
    CONTAINERS=(
      "zigbee2mqtt" "homeassistant" "postgres_db"
      "authentik-worker" "authentik-redis" "authentik-server"
      "vaultwarden" "mosquitto" "caddy" "gotify"
      "dozzle" "uptime-kuma" "loggifly" "flame" "esphome" "portainer"
    )
    
    declare -A WARN_THRESHOLDS CRIT_THRESHOLDS
    
    WARN_THRESHOLDS["zigbee2mqtt"]=2; CRIT_THRESHOLDS["zigbee2mqtt"]=4
    WARN_THRESHOLDS["homeassistant"]=2; CRIT_THRESHOLDS["homeassistant"]=3
    WARN_THRESHOLDS["postgres_db"]=1; CRIT_THRESHOLDS["postgres_db"]=2
    WARN_THRESHOLDS["authentik-worker"]=2; CRIT_THRESHOLDS["authentik-worker"]=4
    WARN_THRESHOLDS["authentik-server"]=2; CRIT_THRESHOLDS["authentik-server"]=4
    WARN_THRESHOLDS["vaultwarden"]=2; CRIT_THRESHOLDS["vaultwarden"]=4
    
    for c in mosquitto caddy gotify dozzle uptime-kuma loggifly flame esphome portainer; do
      WARN_THRESHOLDS[$c]=3; CRIT_THRESHOLDS[$c]=6
    done
    
    log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }
    
    send_alert() {
      [ -f "/run/secrets/gotify-token" ] && GOTIFY_TOKEN=$(cat /run/secrets/gotify-token)
      [ -n "$GOTIFY_TOKEN" ] && curl -s -X POST "$GOTIFY_URL/message" \
        -H "X-Gotify-Key: $GOTIFY_TOKEN" \
        -F "title=$1" -F "message=$2" -F "priority=$3" > /dev/null && log "Alert: $1"
    }
    
    collect_metrics() {
      timestamp=$(date +%s)
      disk_used=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
      mem_percent=$(( $(free -m | awk 'NR==2 {print $3}') * 100 / $(free -m | awk 'NR==2 {print $2}') ))
      load_1min=$(uptime | awk '{print $10}' | sed 's/,//')
      
      echo "$timestamp,$disk_used,$mem_percent,$load_1min" >> "$HISTORY_DIR/metrics.csv"
      tail -n 720 "$HISTORY_DIR/metrics.csv" > "$HISTORY_DIR/metrics.tmp"
      mv "$HISTORY_DIR/metrics.tmp" "$HISTORY_DIR/metrics.csv"
      
      echo "{\"timestamp\":$timestamp,\"disk\":$disk_used,\"memory\":$mem_percent,\"load_1min\":$load_1min}"
    }
    
    get_container_stats() {
      local c="$1"
      docker ps -a --format '{{.Names}}' | grep -q "^$c$" || return 1
      
      status=$(docker inspect --format='{{.State.Status}}' "$c" 2>/dev/null)
      restarts=$(docker inspect --format='{{.RestartCount}}' "$c" 2>/dev/null || echo "0")
      
      if [ -f "$HISTORY_DIR/${c}_restarts" ]; then
        new_restarts=$((restarts - $(cat "$HISTORY_DIR/${c}_restarts")))
      else
        new_restarts=0
      fi
      echo "$restarts" > "$HISTORY_DIR/${c}_restarts"
      
      if [ "$status" = "running" ]; then
        stats=$(docker stats --no-stream --format "{{.CPUPerc}},{{.MemPerc}}" "$c" 2>/dev/null | tail -1)
        cpu=$(echo "$stats" | cut -d',' -f1 | sed 's/%//')
        mem=$(echo "$stats" | cut -d',' -f2 | sed 's/%//')
      else
        cpu=0; mem=0
      fi
      
      echo "{\"name\":\"$c\",\"status\":\"$status\",\"restarts_last_hour\":$new_restarts,\"cpu\":${cpu:-0},\"memory\":${mem:-0}}"
    }
    
    analyze_disk_trend() {
      [ ! -f "$HISTORY_DIR/metrics.csv" ] && return
      [ $(wc -l < "$HISTORY_DIR/metrics.csv") -lt 7 ] && return
      
      growth=$(tail -n 7 "$HISTORY_DIR/metrics.csv" | awk -F',' 'BEGIN{l=0;s=0;c=0}{if(l>0){s+=$2-l;c++} l=$2}END{if(c>0)print s/c;else print 0}')
      if (( $(echo "$growth > 0" | bc -l) )); then
        days_left=$(echo "scale=0; (100 - $1) / $growth" | bc)
        [ "$days_left" -lt 14 ] 2>/dev/null && send_alert "⚠️ Disk vol over $days_left dagen" "Groeit $growth%/dag. Gebruik: $1%" 5
        [ "$days_left" -lt 7 ] 2>/dev/null && send_alert "🔴 KRITIEK: Disk vol over $days_left dagen!" "Direct actie nodig!" 8
      fi
    }
    
    analyze_memory_trend() {
      [ ! -f "$HISTORY_DIR/metrics.csv" ] && return
      [ $(wc -l < "$HISTORY_DIR/metrics.csv") -lt 24 ] && return
      
      rising=$(tail -n 24 "$HISTORY_DIR/metrics.csv" | awk -F',' 'BEGIN{c=0}{if(NR>1&&$3>p)c++; p=$3}END{print c}')
      [ "$rising" -gt 20 ] && [ "$1" -gt 70 ] && send_alert "🔄 Mogelijke memory leak" "Geheugen stijgt gestaag: $1%" 6
    }
    
    analyze_container_restarts() {
      local name="$1" restarts="$2"
      [ "$restarts" -ge "${CRIT_THRESHOLDS[$name]:-10}" ] && send_alert "🔴 $name: $restarts herstarts/uur" "Container instabiel!" 9 && return
      [ "$restarts" -ge "${WARN_THRESHOLDS[$name]:-5}" ] && send_alert "⚠️ $name: $restarts herstarts/uur" "Container vertoont instabiliteit" 5
    }
    
    generate_status() {
      local sys="$1" containers_json="" first=true
      for c in "${CONTAINERS[@]}"; do
        stats=$(get_container_stats "$c") || continue
        if $first; then first=false; else containers_json="$containers_json,"; fi
        containers_json="$containers_json$stats"
      done
      
      if [ -f "$HISTORY_DIR/metrics.csv" ] && [ $(wc -l < "$HISTORY_DIR/metrics.csv") -ge 7 ]; then
        current=$(echo "$sys" | jq -r '.disk')
        growth=$(tail -n 7 "$HISTORY_DIR/metrics.csv" | awk -F',' 'BEGIN{s=0;c=0}{if(NR>1){s+=$2-p;c++} p=$2}END{if(c>0)print s/c;else print 0}')
        days_left=$(echo "$growth > 0" | bc -l) && days_left=$(echo "scale=1; (100 - $current) / $growth" | bc) || days_left="null"
      else
        days_left="null"
      fi
      
      leak_detected="false"
      [ -f "$HISTORY_DIR/metrics.csv" ] && [ $(wc -l < "$HISTORY_DIR/metrics.csv") -ge 24 ] && \
        [ $(tail -n 24 "$HISTORY_DIR/metrics.csv" | awk -F',' 'BEGIN{c=0}{if(NR>1&&$3>p)c++; p=$3}END{print c}') -gt 20 ] && leak_detected="true"
      
      cat > "$DATA_DIR/status.json" << EOF2
{"timestamp":$(date +%s),"system":$sys,"containers":[$containers_json],"predictions":{"disk_days_left":$days_left,"memory_leak":"$leak_detected"}}
EOF2
    }
    
    main() {
      log "🚀 Gestart voor ${#CONTAINERS[@]} containers"
      while true; do
        sys=$(collect_metrics)
        disk=$(echo "$sys" | jq -r '.disk')
        mem=$(echo "$sys" | jq -r '.memory')
        log "Disk ${disk}%, Memory ${mem}%"
        
        analyze_disk_trend "$disk"
        analyze_memory_trend "$mem"
        
        for c in "${CONTAINERS[@]}"; do
          stats=$(get_container_stats "$c") || continue
          [ "$(echo "$stats" | jq -r '.status')" != "running" ] && send_alert "🔴 $c is down" "Container draait niet!" 8
          analyze_container_restarts "$c" "$(echo "$stats" | jq -r '.restarts_last_hour')"
        done
        
        generate_status "$sys"
        log "Wachten ${CHECK_INTERVAL}s..."
        sleep "${CHECK_INTERVAL:-3600}"
      done
    }
    
    main
  '';
in pkgs.dockerTools.buildImage {
  name = "predictive-helper"; tag = "latest";
  contents = with pkgs; [ bash coreutils curl docker-client jq gnugrep gawk util-linux bc mainScript ];
  config = {
    Cmd = [ "${mainScript}/bin/predictive-helper" ];
    WorkingDir = "/data";
    Volumes = { "/data" = {}; "/var/run/docker.sock" = {}; };
    Env = [ "CHECK_INTERVAL=3600" "GOTIFY_URL=http://gotify:8088" ];
  };
}
EOF
echo "✅ predictive-helper.nix aangemaakt"

# ========== 2. DOCKER COMPOSE ==========
echo "📝 compose.yaml aanmaken..."
cat > /home/henry/nixos/containers/predictive-monitoring/compose.yaml << EOF
name: predictive-monitoring

services:
  helper:
    build:
      context: .
      dockerfile: Dockerfile.nix
    image: predictive-helper:latest
    container_name: predictive-helper
    restart: unless-stopped
    volumes:
      - ./data:/data
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      - CHECK_INTERVAL=3600
      - GOTIFY_URL=http://gotify:8088
      - GOTIFY_TOKEN=${GOTIFY_TOKEN}
      - TZ=${TIMEZONE}
    networks:
      - ${DOCKER_NETWORK}
    logging:
      driver: json-file
      options:
        max-size: 10m
        max-file: "3"
    mem_limit: 128m
    cpu_shares: 256
    security_opt:
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /tmp

  web:
    image: nginx:alpine
    container_name: predictive-web
    restart: unless-stopped
    volumes:
      - ./data:/usr/share/nginx/html/data:ro
      - ./web-config:/etc/nginx/conf.d:ro
    ports:
      - "${WEB_PORT}:80"
    networks:
      - ${DOCKER_NETWORK}
    mem_limit: 16m
    depends_on:
      - helper

networks:
  ${DOCKER_NETWORK}:
    external: true
EOF
echo "✅ compose.yaml aangemaakt (poort ${WEB_PORT})"

# ========== 3. DOCKERFILE ==========
echo "📝 Dockerfile.nix aanmaken..."
cat > /home/henry/nixos/containers/predictive-monitoring/Dockerfile.nix << 'EOF'
FROM nixos/nix:latest
COPY predictive-helper.nix /build/predictive-helper.nix
WORKDIR /build
RUN nix-build predictive-helper.nix -o result
FROM scratch
COPY --from=0 /build/result /helper
COPY --from=0 /nix/store /nix/store
ENTRYPOINT ["/helper/bin/predictive-helper"]
EOF
echo "✅ Dockerfile.nix aangemaakt"

# ========== 4. WEBSITE ==========
echo "📝 Website aanmaken..."
cat > /home/henry/nixos/containers/predictive-monitoring/web-config/default.conf << 'EOF'
server {
    listen 80;
    root /usr/share/nginx/html;
    location / {
        default_type text/html;
        return 200 '<!DOCTYPE html>
<html>
<head><title>predictive-helper</title><meta http-equiv="refresh" content="60">
<style>body{font-family:monospace;background:#000;color:#0f0;margin:20px}pre{margin:0}.warn{color:#ff0}.crit{color:#f00}</style>
<body><pre>
🔮 PREDICTIVE HELPER
===================
<span id="content">Laden...</span>
</pre>
<script>
async function update(){
    const r=await fetch("/data/status.json?"+Date.now());
    const d=await r.json();
    let h=`Tijd: ${new Date().toLocaleString()}\n──────────────\n💾 DISK: ${d.system.disk}% gebruikt`;
    if(d.predictions.disk_days_left){
        const days=d.predictions.disk_days_left;
        h+=`\n   ├─ nog <span class="${days<7?"crit":days<14?"warn":"good"}">${days} dagen</span>`;
    }
    h+=`\n🧠 MEM:  ${d.system.memory}%${d.predictions.memory_leak==="true"?" <span class=crit>(leak!)</span>":""}`;
    h+=`\n⚡ LOAD: ${d.system.load_1min}\n──────────────\n🐳 CONTAINERS (${d.containers.length})\n`;
    d.containers.forEach(c=>{h+=`\n${c.status==="running"?"✅":"❌"} ${c.name}${c.restarts_last_hour>0?" ["+c.restarts_last_hour+"x]":""}`});
    document.getElementById("content").innerHTML=h;
}
update();setInterval(update,60000);
</script></body></html>';
    }
    location /data/ { alias /usr/share/nginx/html/data/; add_header Cache-Control "no-cache"; }
}
EOF
echo "✅ Website aangemaakt"

# ========== 5. README ==========
echo "📝 README.md aanmaken..."
cat > /home/henry/nixos/containers/predictive-monitoring/README.md << EOF
# 🔮 Predictive Helper

Minimale monitoring die problemen voorspelt.

## Installatie
1. **Vul Gotify token in** in \`compose.yaml\`
2. **Bouw**: \`docker build -f Dockerfile.nix -t predictive-helper:latest .\`
3. **Start**: \`docker compose up -d\`
4. **Dashboard**: \`http://[server-ip]:${WEB_PORT}\`

## Notificaties
- 🔴 Disk bijna vol (<7 dagen)
- ⚠️ Disk volgend over 7-14 dagen
- 🔴 Container crashes/herstarts
- 🧠 Memory leak detectie

## Obscure poort
Dashboard draait op poort **${WEB_PORT}** voor extra veiligheid.
EOF
echo "✅ README.md aangemaakt"

# ========== 6. BUILD SCRIPT ==========
echo "📝 build.sh aanmaken..."
cat > /home/henry/nixos/containers/predictive-monitoring/build.sh << 'EOF'
#!/usr/bin/env bash
set -e
echo "🚀 Bouwen met docker buildx..."
docker buildx build -f Dockerfile.nix -t predictive-helper:latest --load .
echo "✅ Klaar! Start met: docker compose up -d"
EOF
chmod +x /home/henry/nixos/containers/predictive-monitoring/build.sh
echo "✅ build.sh aangemaakt"

# ========== 7. CLEANUP ==========
echo "📝 cleanup.sh aanmaken..."
cat > /home/henry/nixos/containers/predictive-monitoring/cleanup.sh << 'EOF'
#!/usr/bin/env bash
echo "🧹 Opschonen..."
docker compose down
read -p "Verwijder data? (j/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Jj]$ ]]; then
    rm -rf data/*
    echo "✅ Data verwijderd"
fi
EOF
chmod +x /home/henry/nixos/containers/predictive-monitoring/cleanup.sh
echo "✅ cleanup.sh aangemaakt"

# ========== 8. CHECK SCRIPT ==========
echo "📝 check.sh aanmaken..."
cat > /home/henry/nixos/containers/predictive-monitoring/check.sh << 'EOF'
#!/usr/bin/env bash
echo "🔍 Predictive Helper status"
echo "=========================="
echo ""
echo "📊 Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep predictive
echo ""
echo "📁 Data:"
ls -la data/ | tail -5
echo ""
echo "📈 Metrics:"
[ -f data/status.json ] && jq '.' data/status.json || echo "Geen data"
EOF
chmod +x /home/henry/nixos/containers/predictive-monitoring/check.sh
echo "✅ check.sh aangemaakt"

# ========== 9. AFsluiting ==========
echo ""
echo "====================================="
echo "✅ INSTALLATIE VOLTOOID!"
echo "====================================="
echo ""
echo "📁 Locatie: /home/henry/nixos/containers/predictive-monitoring/"
echo ""
echo "🔧 Belangrijk:"
echo "   - Open compose.yaml en vervang HIER_JOUW_TOKEN door je Gotify token"
echo ""
echo "🚀 Starten met:"
echo "   cd /home/henry/nixos/containers/predictive-monitoring"
echo "   ./build.sh"
echo "   docker compose up -d"
echo ""
IP=$(hostname -I | awk '{print $1}')
echo "🌐 Dashboard: http://$IP:${WEB_PORT}  (obscure poort)"
echo ""

# Permissies
chown -R henry:users /home/henry/nixos/containers/predictive-monitoring 2>/dev/null || true
chmod +x /home/henry/nixos/containers/predictive-monitoring/*.sh 2>/dev/null || true

echo "🎯 Klaar!"