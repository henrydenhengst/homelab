#!/bin/bash
# ipfs_local_setup.sh - Lokale IPFS setup voor homelab zonder Swarm
# Inclusief virtuele 50GB schijf, obscure poorten, Docker IPFS en automatische monitoring/GC

# --- Configuratie ---
IPFS_DIR="/home/henry/ipfs"
IMG_FILE="/home/henry/ipfs_disk.img"
IMG_SIZE="50G"

DOCKER_CONTAINER_NAME="ipfs_host"
# Obscure poorten (API en Gateway)
API_PORT=59112
GATEWAY_PORT=82736

# Threshold voor automatische GC
THRESHOLD=85

# Cronjob instellingen
CRON_JOB="0 * * * * $PWD/ipfs_local_setup.sh monitor >> $IPFS_DIR/ipfs_monitor.log 2>&1"

# --- Functie: virtuele schijf aanmaken en mounten ---
setup_disk() {
    mkdir -p "$IPFS_DIR"

    if [ ! -f "$IMG_FILE" ]; then
        echo "Maak virtuele schijf $IMG_FILE van $IMG_SIZE"
        fallocate -l $IMG_SIZE "$IMG_FILE"
        echo "Formateer als ext4"
        mkfs.ext4 "$IMG_FILE"
    else
        echo "Virtuele schijf $IMG_FILE bestaat al, overslaan"
    fi

    MOUNTED=$(mount | grep "$IPFS_DIR")
    if [ -z "$MOUNTED" ]; then
        echo "Mount $IMG_FILE naar $IPFS_DIR"
        sudo mount -o loop "$IMG_FILE" "$IPFS_DIR"
    else
        echo "$IPFS_DIR is al gemount"
    fi

    FSTAB_LINE="$IMG_FILE $IPFS_DIR ext4 loop 0 0"
    if ! grep -qF "$FSTAB_LINE" /etc/fstab; then
        echo "Voeg toe aan /etc/fstab voor automatisch mounten"
        echo "$FSTAB_LINE" | sudo tee -a /etc/fstab
    fi
}

# --- Functie: start Docker IPFS node (zonder Swarm) ---
start_ipfs() {
    docker rm -f "$DOCKER_CONTAINER_NAME" >/dev/null 2>&1
    echo "Start IPFS container (API & Gateway alleen)"
    docker run -d --name "$DOCKER_CONTAINER_NAME" \
      -v "$IPFS_DIR":/data/ipfs \
      -p $API_PORT:5001 \
      -p $GATEWAY_PORT:8080 \
      ipfs/go-ipfs:latest
}

# --- Functie: monitoren en GC uitvoeren ---
monitor_gc() {
    USAGE=$(df "$IPFS_DIR" | awk 'NR==2 {gsub("%",""); print $5}')
    echo "$(date): Huidig gebruik $USAGE%"

    if [ "$USAGE" -ge "$THRESHOLD" ]; then
        echo "$(date): Waarschuwing! IPFS gebruikt $USAGE% van de virtuele schijf."
        echo "Start garbage collection..."
        docker exec "$DOCKER_CONTAINER_NAME" ipfs repo gc
        echo "$(date): GC voltooid"
    else
        echo "$(date): Gebruik onder drempel ($THRESHOLD%)"
    fi
}

# --- Functie: cronjob instellen ---
setup_cron() {
    crontab -l 2>/dev/null | grep -qF "$PWD/ipfs_local_setup.sh monitor"
    if [ $? -ne 0 ]; then
        (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
        echo "Cronjob ingesteld om elk uur te monitoren"
    else
        echo "Cronjob bestaat al"
    fi
}

# --- Script hoofdlogica ---
case "$1" in
    monitor)
        monitor_gc
        ;;
    *)
        echo "=== IPFS Local Setup Start ==="
        setup_disk
        start_ipfs
        monitor_gc
        setup_cron
        echo "=== Setup Klaar ==="
        echo "Schijfgebruik:"
        df -h "$IPFS_DIR"
        echo "IPFS container status:"
        docker ps | grep "$DOCKER_CONTAINER_NAME"
        ;;
esac

# --- Documentatie ---
if [ "$1" != "monitor" ]; then
cat <<EOF

DOCUMENTATIE:

1. Virtuele schijf:
   - File: $IMG_FILE
   - Grootte: $IMG_SIZE
   - Gemount op: $IPFS_DIR
   - Automatisch mount via /etc/fstab

2. IPFS Docker container:
   - Container naam: $DOCKER_CONTAINER_NAME
   - Data folder: $IPFS_DIR
   - API port: $API_PORT
   - Gateway port: $GATEWAY_PORT
   - Geen Swarm: alleen lokaal toegankelijk

3. Monitoring & Garbage Collection:
   - Automatische GC wordt uitgevoerd bij ≥$THRESHOLD% gebruik
   - Logs van monitoring staan in $IPFS_DIR/ipfs_monitor.log
   - Handmatige GC: docker exec $DOCKER_CONTAINER_NAME ipfs repo gc

4. Cronjob:
   - Script draait automatisch elk uur voor monitoring en GC
   - Controleer logs: tail -f $IPFS_DIR/ipfs_monitor.log

5. Herstart Docker container:
   - docker restart $DOCKER_CONTAINER_NAME

EOF
fi