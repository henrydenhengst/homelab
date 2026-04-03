# MASTERPLAN: MIKROTIK CORE & SMART HOME DEPLOYMENT (2026)

## 0. DE DEVOPS TOOLKIT (Ansible Ready)
1. **Beheerserver (Docker Host):** Draai je "Setup DevOps Toolkit" playbook op je server.
   - Installeert: `ansible`, `mosh`, `avahi-daemon` (mDNS), `clusterssh`, `tmux`.
   - Genereert SSH-keys voor communicatie met de MikroTik en Opals.
2. **mDNS:** Zorg dat `server.local` bereikbaar is voor eenvoudige toegang.

## FASE 1: MIKROTIK BOOTSTRAP (Op de werkbank)
1. **Basis Toegang:** - Verbind je laptop met Poort 2. Log in via `192.168.88.1` (WinBox of Web).
   - Stel een sterk admin-wachtwoord in en activeer **SSH**.
2. **Interface Config:**
   - Poort 1: WAN (naar Glasvezel ONT).
   - Poort 2-5: Bridge (Switch mode voor Server en Opals).
3. **VLAN Definitie (Ansible Target):**
   - VLAN 10: Trusted (Privé apparaten & Server MGMT).
   - VLAN 20: IoT (Opals & ESP32's).
   - VLAN 30: Guest.
4. **Services:** Activeer DHCP-servers en DNS (met forwarding naar 1.1.1.1) voor elk VLAN.

## FASE 2: FYSIEKE INSTALLATIE (De Meterkast)
1. **Internet:** Glasvezel ONT -> MikroTik Poort 1.
2. **Server:** Homelab Server -> MikroTik Poort 2.
3. **Kamers:** Wandkabels (naar Opals) -> MikroTik Poorten 3, 4 en 5.
   *Tip: Gebruik Poort 5 voor de Opal die het verst weg staat (PoE-out ondersteuning).*

## FASE 3: SATELLIET DEPLOYMENT (De Kamers)
1. **Hardware:** Opal Router + ESP32-C6 (via 20cm USB-kabel).
2. **Provisioning (via Ansible):**
   - Push OpenWrt configs naar de Opals (VLAN 10/20/30 aware).
   - Flash ESP32-C6's via het ESPHome dashboard op de server.
3. **Mesh:** Voeg de ESP32's toe als Zigbee Routers aan je `zigbee2mqtt` stack.

## FASE 4: DOCKER & NETWORK HARDENING
1. **Docker Netwerk:** Gebruik `macvlan` op de server gekoppeld aan de MikroTik VLAN 20 interface.
2. **Firewall Lockdown (MikroTik Filter Rules):**
   - **Isolatie:** Blokkeer verkeer van VLAN 20 (IoT) naar VLAN 10 (Privé).
   - **Pinholes:** Sta alleen MQTT (1883) toe van de Opals naar de server.
   - **Killswitch:** Zorg dat IoT-apparaten niet rechtstreeks naar internet kunnen (optioneel).

## FASE 5: ANSIBLE AUTOMATION
- Gebruik de `community.network.routeros` collectie voor:
  - Backups van je router-config.
  - Snel toevoegen van nieuwe VLAN's of Firewall regels.
  - Port-forwarding voor je Caddy/Home Assistant toegang.
