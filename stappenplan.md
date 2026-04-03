# 📂 MASTERPLAN: METERKAST MIGRATIE 2.0 (MIKROTIK CORE)

## 🏗️ 1. DE FUNDERING (Beheer & Strategie)
* **Domeinnaam:** Gebruik overal `server.home.lan` (geen .local).
* **Toegang:** SSH-sleutels (ED25519) op laptop, server en MikroTik hEX S.
* **Tools:** Ansible voor alle configuraties, Mosh voor stabiele sessies.

## 🛡️ 2. DE KERN (MikroTik hEX S)
* **VLAN 10 (Trusted):** Server Management & Privé-apparaten (192.168.10.0/24).
* **VLAN 20 (IoT):** Opal routers & ESP32-nodes (192.168.20.0/24).
* **VLAN 30 (Guest):** Bezoekersnetwerk (192.168.30.0/24).
* **DNS:** Statisch record `server.home.lan` -> 192.168.10.10.
* **DHCP:** Option 15 (`home.lan`) pushen naar alle verbonden apparaten.

## 🔌 3. DE BEKABELING (Fysieke Poorten)
* **Poort 1 (WAN):** Glasvezel ONT (Internet-ingang).
* **Poort 2 (Trunk):** Debian Server (Hoofdverbinding voor VLAN 10/20).
* **Poort 3 & 4:** Wandcontactdozen naar de diverse kamers.
* **Poort 5 (PoE):** Verste kamer (Data + Stroom voor de Opal via PoE-out).

## 🛰️ 4. DE SATELLIETEN (Per Kamer)
* **Opal Router:** Draait OpenWrt als VLAN-aware Access Point.
    * SSID 'Home_WiFi': Gekoppeld aan VLAN 10.
    * SSID 'IoT_WiFi': Gekoppeld aan VLAN 20.
* **ESP32-C6 Node:** Via 20cm USB-kabel aan de Opal.
    * Functie: Bluetooth Proxy & Zigbee Router voor maximale mesh-dekking.

## 🔒 5. DE LOCKDOWN (Security & Docker)
* **Isolatie:** Firewall-rule in MikroTik: Blokkeer VLAN 20 naar VLAN 10.
* **Pinhole:** Sta enkel MQTT (poort 1883) toe van Opals naar de Server.
* **Docker:** Gebruik `macvlan` op de server (eth0.20) voor directe IoT-interactie.
* **Proxy:** Caddy regelt SSL/toegang voor `vault.home.lan` en `ha.home.lan`.

## 🤖 6. DE AUTOMATISERING (Ansible Inventory)
[network]
router.home.lan ansible_host=192.168.10.1

[servers]
server.home.lan ansible_host=192.168.10.10

[satellites]
opal_woonkamer ansible_host=192.168.20.11
opal_slaapkamer ansible_host=192.168.20.12
