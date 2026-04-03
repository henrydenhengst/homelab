# MASTERPLAN: METERKAST MIGRATIE & SMART HOME DEPLOYMENT

## 0. SSH & TOEGANGSBEHEER (Ansible Ready)

## 1. OPNsense Router (NIC 3 / Management)
- **System -> Settings -> Administration:**
  - [x] Enable Secure Shell
  - [x] Root Login: Allow Password Login (Tijdelijk, voor de eerste Ansible push)
  - [ ] Password Authentication: Disable (Zodra je SSH-key door Ansible is geplaatst)
  - SSH Port: 22
- **Firewall Rules (Interface NIC 3):**
  - Pass | IPv4 | TCP | Source: Management Net | Port: 22 | Dest: NIC 3 Address

## 2. Homelab Server (NIC 3 / Management)
- **Installatie:** `sudo apt install openssh-server mosh -y`
- **Configuratie (/etc/ssh/sshd_config):**
  - `PermitRootLogin prohibit-password` (Alleen inloggen met keys)
  - `PasswordAuthentication no` (Zodra je keys werken)
- **UFW / Firewall:**
  - `sudo ufw allow 22/tcp`
  - `sudo ufw allow 60000:61000/udp` (Voor Mosh)

## 3. Ansible Control Node (Je werkstation)
- **SSH Key Gen:** `ssh-keygen -t ed25519 -C "ansible-admin"`
- **Keys Verspreiden:**
  - `ssh-copy-id -i ~/.ssh/id_ed25519.pub user@opnsense-ip`
  - `ssh-copy-id -i ~/.ssh/id_ed25519.pub user@server-ip`
- **Inventory File (`hosts.ini`):**
  ```ini
  [network]
  router_opnsense ansible_host=192.168.x.1

  [servers]
  homelab_server ansible_host=192.168.x.10


## FASE 1: PRE-STAGING (Op de werkbank)
1.  **OPNsense Installatie:**
    - NIC 1: WAN (Koppel nog niet aan ONT).
    - NIC 2: LAN/Trunk naar Switch (VLAN 10, 20, 30).
    - NIC 3: Management (Vaste IP-range voor SSH/Mosh/WebGUI).
2.  **Kritieke Router Settings:**
    - **NAT:** Zet Outbound NAT op 'Hybrid' of 'Automatic'.
    - **DHCP:** Activeer DHCP-pools voor elk VLAN (10, 20, 30).
    - **DNS:** Configureer Unbound DNS (luisteren op alle interfaces).
    - **Firewall:** Voeg een tijdelijke 'Allow All' regel toe op alle LAN/VLAN interfaces om buitensluiting te voorkomen.
    - **Mosh:** Open UDP poorten 60000-61000 in de firewall voor NIC 3.
3.  **Switch Config (Netgear GS105E):**
    - Poort 1: Trunk naar OPNsense NIC 2 (VLAN 10, 20, 30 tagged).
    - Poort 2-5: Tagged naar kamers (VLAN 10, 20, 30).
    - Management IP instellen in de range van NIC 3.

## FASE 2: FYSIEKE INSTALLATIE (De Meterkast)
1.  **Internet:** Glasvezel ONT -> OPNsense NIC 1 (Check VLAN 6 indien KPN/Odido).
2.  **Core:** OPNsense NIC 2 -> Netgear Poort 1.
3.  **Server:** Homelab Server -> OPNsense NIC 3 (Management).
4.  **Kamers:** Bestaande wandkabels -> Netgear Poorten 2-5.

## FASE 3: SATELLIET DEPLOYMENT (De Kamers)
1.  **Hardware:**
    - Prik Opal Router in de wandcontactdoos.
    - Verbind ESP32-C6 via 20cm USB A-naar-C kabel met de Opal.
2.  **Provisioning:**
    - Gebruik Ansible om OpenWrt op de Opals te configureren (VLAN aware).
    - Flash ESP32-C6 via ESPHome Dashboard als 'Bluetooth Proxy' en 'Zigbee Router'.
3.  **Zigbee Koppeling:**
    - Prik Zwarte Dongle (Z-Stack) in de server via USB-verlengsnoer.
    - Open Zigbee2MQTT -> Permit Join.
    - Koppel de ESP32-C6's als routers om je mesh te bouwen.

## FASE 4: DOCKER & SECURITY HARDENING
1.  **Netwerk:** Definieer `macvlan` netwerken in Docker op basis van `eth3.20` (IoT).
2.  **Isolatie:** - Verplaats `mosquitto` en `esphome` naar het IoT VLAN.
    - Houd `vaultwarden` en `postgres_db` op de interne `db_internal` bridge.
3.  **Firewall Lockdown:**
    - Verwijder de 'Allow All' regels in OPNsense.
    - Sluis alleen poort 1883 (MQTT) en 5053 (DNS) door van de kamers naar de server.
    - Blokkeer al het overige verkeer tussen VLAN 20 (IoT) en VLAN 10 (Privé).
