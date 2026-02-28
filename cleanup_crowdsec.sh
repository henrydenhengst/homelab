#!/bin/bash

# Controleer op root-rechten
if [ "$EUID" -ne 0 ]; then 
  echo "Voer dit script uit met sudo!"
  exit
fi

echo "--- Start grote schoonmaak van CrowdSec ---"

# 1. Stop en verwijder de Docker container
echo "[1/4] Verwijderen van CrowdSec Docker container..."
docker stop crowdsec 2>/dev/null
docker rm crowdsec 2>/dev/null

# 2. Verwijder de APT bouncer en CrowdSec pakketten
echo "[2/4] Verwijderen van host-pakketten (bouncer & engine)..."
apt-get purge -y crowdsec crowdsec-firewall-bouncer-iptables
apt-get autoremove -y

# 3. Verwijder alle configuratie- en datamappen
echo "[3/4] Verwijderen van mappen op de host..."
rm -rf /etc/crowdsec
rm -rf /var/lib/crowdsec
rm -rf /opt/docker/crowdsec/data

# 4. Opschonen van Iptables (Cruciaal voor je netwerk)
echo "[4/4] Opschonen van achtergebleven firewall chains..."
iptables -F CROWDSEC_CHAIN 2>/dev/null
iptables -X CROWDSEC_CHAIN 2>/dev/null
iptables -D INPUT -p tcp -m tcp --dport 8080 -j CROWDSEC_CHAIN 2>/dev/null

echo "--- Schoonmaak voltooid. De weg is vrij voor Fail2Ban! ---"
