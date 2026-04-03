# MASTERPLAN: METERKAST MIGRATIE & SMART HOME DEPLOYMENT

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
