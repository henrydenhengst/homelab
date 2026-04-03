# MASTERPLAN: METERKAST MIGRATIE 2.0 (MIKROTIK CORE)

## 0. DE DEVOPS TOOLKIT (Beheerstation)
- **FQDN:** `server.home.lan` (Static DNS in MikroTik).
- **Tools:** `ansible`, `mosh`, `tmux`, `clusterssh`, `avahi-daemon`.
- **SSH:** ED25519 keys genereren; SSH-agent forwarding aan voor `cssh`.

## 1. MIKROTIK CORE BOOTSTRAP (hEX S)
- **Toegang:** SSH/WinBox activeren. Keys toevoegen via `/user ssh-keys`.
- **VLAN Tabel:**
  - VLAN 10 (Trusted): Server MGMT, Laptops, Privé devices. (192.168.10.0/24)
  - VLAN 20 (IoT): Opals, ESP32-C6 nodes. (192.168.20.0/24)
  - VLAN 30 (Guest): Bezoekers. (192.168.30.0/24)
- **DNS/DHCP:** - Static DNS: `server.home.lan` -> `192.168.10.10`.
  - DHCP Option 15: Domain name `home.lan`.

## 2. FYSIEKE APPARATUUR & BEKABELING
- **Poort 1 (WAN):** Glasvezel ONT.
- **Poort 2 (Trunk):** Homelab Server (Debian Docker Host).
- **Poort 3-5 (Trunk):** Wandkabels naar Opal Routers in kamers.
- **PoE-out:** Gebruik Poort 5 voor de verst gelegen Opal.

## 3. SATELLIET DEPLOYMENT (Per Kamer)
- **Hardware:** GL.iNet Opal + ESP32-C6 (via 20cm USB).
- **Ansible:** OpenWrt config pushen naar Opals (VLAN aware).
- **ESPHome:** ESP32-C6 flashen als Bluetooth Proxy & Zigbee Router.

## 4. DOCKER STACK & SECURITY
- **Netwerk:** `macvlan` op server interface `eth0.20` voor IoT verkeer.
- **Reverse Proxy:** Caddy voor `vault.home.lan` en `ha.home.lan`.
- **Firewall Rules (MikroTik):**
  - Drop traffic van VLAN 20 naar VLAN 10.
  - Allow poort 1883 (MQTT) van Opals naar Server.
  - Allow poort 22/UDP 60000-61000 (SSH/Mosh) enkel vanaf VLAN 10.

## 5. ANSIBLE INVENTORY (hosts.ini)
```ini
[network]
core_router ansible_host=192.168.10.1

[servers]
main_server ansible_host=server.home.lan

[satellites]
opal_woonkamer ansible_host=192.168.20.11
opal_slaapkamer ansible_host=192.168.20.12
