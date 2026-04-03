# Project: 1Gbps Glasvezel + Multi-Room Zigbee/BLE Proxy Setup (2026)

## Fase 1: De Centrale Hub (Meterkast)
1. **Server Hardware:** Sluit de Glasvezel ONT aan op NIC 1 van je server.
2. **OPNsense Config:** - Wijs NIC 1 toe aan WAN.
   - Wijs NIC 2 toe aan LAN (Trunk poort naar Netgear Switch).
   - Wijs NIC 3 toe aan Management (Directe link naar je Homelab/Docker host).
3. **VLAN Setup:** Maak in OPNsense de volgende VLAN's aan op NIC 2:
   - VLAN 10: Trusted (Privé apparaten)
   - VLAN 20: IoT (Opals + ESP32's)
   - VLAN 30: Guest
4. **Switch:** Configureer de Netgear GS105E:
   - Poort 1: Trunk (naar OPNsense NIC 2)
   - Poorten 2-5: Tagged VLAN 10, 20, 30 (naar de kamers)

## Fase 2: De Satellieten (Per Kamer)
1. **Opal Routers:** - Flash/Configureer de Opals met je Ansible playbook.
   - Stel de WAN-poort in om VLAN-tags te accepteren.
   - Koppel de Wi-Fi SSID's aan de juiste VLAN's.
2. **Hardware Koppeling:** - Gebruik de 20cm USB A-naar-C kabel.
   - Prik het USB-A uiteinde in de Opal.
   - Prik het USB-C uiteinde in de ESP32-C6 Mini.

## Fase 3: ESP32-C6 Flashen (ESPHome)
1. Prik de ESP32-C6 in je laptop/server.
2. Gebruik ESPHome Dashboard om de volgende functies te flashen:
   - **Bluetooth Proxy:** Voor bereik van sensoren/trackers in die kamer.
   - **Zigbee Router:** Om het mesh-netwerk te versterken.
3. Voeg de nodes toe aan Home Assistant via de ESPHome integratie.

## Fase 4: Zigbee Netwerk (Z2M)
1. Prik de zwarte Zigbee Dongle (Z-Stack) in de server (gebruik een USB-verlengkabel!).
2. Start de Zigbee2MQTT container.
3. Zet 'Permit Join' aan in het Z2M dashboard.
4. Druk op de 'Boot' knop op de ESP32-C6's om ze als 'Routers' aan je netwerk toe te voegen.

## Fase 5: Docker & Network Hardening
1. Maak in Docker Macvlan netwerken aan voor `eth3.20` (IoT).
2. Hang `mosquitto` en `esphome` containers aan dit netwerk.
3. Configureer OPNsense Firewall rules:
   - Sta MQTT (1883) toe van VLAN 20 naar de Mosquitto container.
   - Blokkeer al het overige verkeer van VLAN 20 naar je Trusted VLAN 10.

## Onderhoud (Ansible)
- Gebruik je Ansible playbooks voor:
  - Updates van de Opal routers (OpenWrt).
  - Config wijzigingen in de Docker-compose files.
  - Backups van je Z2M en Home Assistant databases.
