# FASE 2: Zigbee2MQTT configureren

## Wat je nu gaat doen:
Je gaat Zigbee2MQTT vertellen welke MQTT broker hij moet gebruiken (mosquitto) en je zet hem klaar om Zigbee apparaten te ontvangen.

## Stap 1: Open de Zigbee2MQTT interface
- Open je webbrowser
- Ga naar: http://[IP_van_jouw_server]:8081
- (Vervang [IP_van_jouw_server] door het IP-adres van je server, bijvoorbeeld 192.168.1.10)
- Je komt direct op het dashboard - er is standaard geen wachtwoord

## Stap 2: Open de MQTT instellingen
- Klik links in het menu op het tandwiel icoon (Instellingen)
- Klik vervolgens in het linkermenu op "MQTT"

## Stap 3: Vul de MQTT verbindingsgegevens in
Bij MQTT Server vul je in: mqtt://mosquitto:1883
- Let op: het is "mosquitto" zonder hoofdletters of spaties
- De rest laat je leeg (geen gebruikersnaam, geen wachtwoord)
- MQTT Base topic blijft: zigbee2mqtt

## Stap 4: Opslaan en herstarten
- Klik onderaan op de knop "Opslaan" (Save)
- Klik rechtsboven op de rode knop "Stoppen" (Stop)
- Wacht 5 seconden
- Klik op de groene knop "Starten" (Start)

## Stap 5: Controleer of het gelukt is
- Klik links op het tabje "Log"
- Je zou moeten zien: "Connected to MQTT server: mqtt://mosquitto:1883"
- En: "Zigbee2MQTT started"
- Als je een foutmelding ziet zoals "Connection refused", staat Mosquitto niet goed of zit Zigbee2MQTT in een ander netwerk

## Stap 6: Zet Permit Join aan (belangrijk!)
- Klik links op "Dashboard" (of "Home")
- Klik op de knop "Permit join (All)" of zet de schakelaar op AAN
- Er verschijnt een timer van 254 seconden (ongeveer 4 minuten)
- Laat Permit Join AAN staan terwijl je nieuwe Zigbee apparaten gaat toevoegen
- Zet hem later weer UIT om te voorkomen dat onbekende apparaten verbinding maken

## Stap 7: Test of Home Assistant de verbinding ziet
- Open Home Assistant in een ander tabblad
- Ga naar Instellingen → Apparaten & Diensten
- Klik op het MQTT kaartje
- Klik op het tabje Instellingen
- Klik op "Luister naar een topic" (Listen to a topic)
- Vul in: #
- Klik op Start Listening
- Je zou nu berichten moeten zien van zigbee2mqtt/bridge/state en zigbee2mqtt/bridge/devices

## Fase 2 is klaar!
Zigbee2MQTT is nu verbonden met de MQTT broker. Je kunt nu Zigbee apparaten gaan pair-en. Zodra je een apparaat paart, verschijnt het automatisch in Home Assistant.

## Volgende stap:
Ga verder met Fase 3: je eerste Zigbee apparaat toevoegen (lamp, sensor of schakelaar).