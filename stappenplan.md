# PRE-STAGING & INSTALLATIE PLAN (Meterkast-klaar maken)

## STAP 1: OPNsense Basis Installatie
1. Installeer OPNsense op je hardware (Mini-PC/Server).
2. Configureer de NIC's:
   - Identificeer fysieke poorten voor WAN (Glas), LAN (Switch) en MGMT (Server).
   - Zet de LAN-poort (NIC 2) direct in Trunk-modus (VLAN 10, 20, 30).
3. Stel Firewall-regels in voor SSH/Mosh:
   - Sta SSH (poort 22) en Mosh (UDP 60000-61000) toe op de Management NIC.
   - Test de verbinding vanaf je laptop voordat je de server verplaatst.

## STAP 2: Switch Configuratie (Netgear GS105E)
1. Koppel de switch los van je huidige netwerk en verbind je laptop direct.
2. Gebruik de ProSAFE Plus Utility of de web-interface:
   - Stel een statisch IP in dat binnen je nieuwe OPNsense Management subnet valt.
   - Configureer 802.1Q VLAN's:
     - Poort 1 (naar OPNsense): Trunk (VLAN 10, 20, 30 tagged).
     - Poorten 2-5 (naar kamers): Tagged (VLAN 10, 20, 30).
3. Sla de configuratie op en herstart de switch om te verifiëren.

## STAP 3: Fysieke Migratie naar Meterkast
1. Sluit de Glasvezel ONT aan op de WAN-poort (NIC 1).
2. Sluit NIC 2 aan op Poort 1 van de Netgear Switch.
3. Sluit de bestaande kabels uit de kamers aan op Poorten 2-5 van de switch.
4. Sluit de Homelab-server (NIC 3) aan op je eigen management-poort of direct op de OPNsense MGMT-poort.

## STAP 4: Remote Toegang & Verificatie
1. Start alles op: ONT -> OPNsense -> Switch.
2. Verbind via SSH of Mosh naar het nieuwe Management IP van je server.
3. Controleer via de OPNsense web-GUI of de WAN-interface een IP-adres krijgt van de provider.
4. Ping vanuit je server naar een externe host (bijv. 1.1.1.1) om de verbinding te bevestigen.

## STAP 5: Uitrol naar Kamers
1. Sluit de Opals aan in de kamers.
2. Omdat je OPNsense en Switch al 'VLAN-aware' zijn, zouden de Opals direct hun IP moeten krijgen in het toegewezen VLAN.
3. Gebruik Ansible om de finale OpenWrt-configuratie naar de Opals te pushen via je nieuwe stabiele verbinding.
