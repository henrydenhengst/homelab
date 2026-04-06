# FASE 5: Geavanceerde automatiseringen & dashboard bouwen

## Wat je nu gaat doen:
Je gaat een professioneel ogend dashboard maken voor op je telefoon of tablet, én je leert een aantal geavanceerdere automatiseringen die je huis écht slim maken.

## Deel A: Een professioneel dashboard bouwen

### Stap 1: Maak een nieuw dashboard aan
- Open Home Assistant
- Klik links op Overzicht
- Klik rechtsboven op de drie puntjes
- Klik op Dashboards beheren
- Klik rechtsonder op Dashboard toevoegen
- Vul bij Naam in: Thuis of Mijn huis
- Kies een pictogram zoals een huisje
- Klik op Aanmaken

### Stap 2: Voeg kaarten toe aan je dashboard
Je nieuwe dashboard is nu leeg. Klik op Kaart toevoegen om de volgende kaarten één voor één toe te voegen.

Kaart 1: Weerkaart
- Kies kaarttype: Weer
- Selecteer je weersensor of gebruik de gratis OpenWeatherMap integratie
- Grootte: Normaal

Kaart 2: Lampen overzicht
- Kies kaarttype: Entiteiten
- Selecteer al je lampen
- Geef het een titeltje: Verlichting
- Kies stijl: Schakelaars

Kaart 3: Temperatuur en vochtigheid
- Kies kaarttype: Entiteiten
- Selecteer je temperatuursensoren
- Titeltje: Klimaat
- Stijl: Sensoren

Kaart 4: Bewegingssensor status
- Kies kaarttype: Entiteiten
- Selecteer je bewegingssensoren
- Titeltje: Beweging
- Stijl: Aan en uit status

Kaart 5: Batterij status
- Kies kaarttype: Entiteiten
- Selecteer alle sensoren met een batterij
- Titeltje: Batterijen
- Stijl: Sensoren

### Stap 3: Maak een sectie voor je tablet aan de muur
- Klik op Kaart toevoegen
- Kies kaarttype: Prent
- Upload een foto van je huisplattegrond
- Klik daarna op Kaart toevoegen en kies Prent met entiteiten
- Plaats knoppen op de plattegrond bij elke lamp

### Stap 4: Zet het dashboard als standaard
- Klik op de drie puntjes rechtsboven
- Kies Dashboards beheren
- Klik bij je nieuwe dashboard op het sterretje
- Dit is nu jouw startscherm

## Deel B: Geavanceerde automatiseringen

### Automatisering 1: Vakantiemodus

Wat doet het? Als je op vakantie gaat, doen lampen random aan en uit zodat het lijkt alsof er iemand thuis is.

Hoe maak je het:
- Ga naar Instellingen → Automatiseringen & Scènes
- Klik op Nieuwe automatisering
- Kies als trigger: Tijdstip, bijvoorbeeld elke dag om 18:00
- Voeg een voorwaarde toe: Helper → Helper aan en uit
- Maak eerst een vakantieschakelaar aan via Instellingen → Helpers → Nieuwe helper
- Kies Aan en uit knop en noem hem Vakantiemodus
- Zet deze schakelaar aan als je weggaat en uit als je terug bent
- Voeg als actie toe: Lamp random aan en uit

### Automatisering 2: Notificatie bij open voordeur als je weg bent

Wat doet het? Je krijgt een bericht op je telefoon als de voordeur opengaat terwijl je niet thuis bent.

Wat heb je nodig:
- Een deursensor
- De Home Assistant app op je telefoon

Hoe maak je het:
- Nieuwe automatisering
- Kies als trigger: Apparaat → je deursensor → Open
- Voeg een voorwaarde toe: Personen → Jij → Niet thuis
- Kies als actie: Notificatie versturen
- Typ het bericht: De voordeur is open terwijl je weg bent
- Stuur het naar jouw telefoon

### Automatisering 3: Wakker worden met licht

Wat doet het? De lamp in je slaapkamer wordt langzaam steeds feller rond je wektijd.

Hoe maak je het:
- Nieuwe automatisering
- Kies als trigger: Tijdstip → 07:00 of jouw wektijd
- Voeg meerdere acties toe:
  - Om 07:00 → helderheid op 1 procent
  - Om 07:05 → helderheid op 25 procent
  - Om 07:10 → helderheid op 50 procent
  - Om 07:15 → helderheid op 75 procent
  - Om 07:20 → helderheid op 100 procent

### Automatisering 4: Energie besparen

Wat doet het? Als de laatste persoon het huis verlaat, gaan alle lampen uit.

Hoe maak je het:
- Nieuwe automatisering
- Kies als trigger: Personen → Alle personen → Niet thuis
- Kies als actie: Meerdere apparaten → Selecteer al je lampen
- Actie type: Uitzetten

### Automatisering 5: Temperatuur alarm

Wat doet het? Je krijgt een waarschuwing als de temperatuur in de kelder of garage te laag wordt.

Hoe maak je het:
- Nieuwe automatisering
- Kies als trigger: Apparaat → temperatuursensor → Onder 2 graden
- Kies als actie: Notificatie versturen
- Bericht: Waarschuwing: temperatuur onder 2 graden. Kans op bevriezing.

## Deel C: Handige integraties om toe te voegen

### Integratie 1: Google Home of Alexa
- Ga naar Instellingen → Apparaten & Diensten
- Klik op de plus knop
- Zoek naar Google Assistant of Amazon Alexa
- Volg de configuratie
- Je hebt een DuckDNS URL en Caddy nodig, die heb je al
- Nu kun je je lampen bedienen met spraak

### Integratie 2: Energy dashboard
- Ga naar Instellingen → Energie
- Voeg je P1 meter toe als je een slimme meter hebt
- Kies welke apparaten je wilt volgen
- Je krijgt inzicht in je stroom en gasverbruik

### Integratie 3: Spotify
- Ga naar Instellingen → Apparaten & Diensten
- Klik op de plus knop
- Zoek naar Spotify
- Koppel je account
- Maak automatiseringen zoals Muziek aan als ik thuiskom

### Integratie 4: OpenWeatherMap
- Maak een gratis account op OpenWeatherMap
- Ga naar Instellingen → Apparaten & Diensten → plus knop
- Zoek naar OpenWeatherMap
- Vul je API key in
- Kies je locatie
- Je hebt nu actueel weer en voorspellingen

## Deel D: Backups maken

### Stap 1: Voeg de backup integratie toe
- Ga naar Instellingen → Apparaten & Diensten
- Klik op de plus knop
- Zoek naar Backup
- Voeg hem toe

### Stap 2: Maak een automatische backup automatisering
- Nieuwe automatisering
- Kies als trigger: Tijdstip → Elke dag om 03:00
- Kies als actie: Backup maken

### Stap 3: Backup naar externe locatie
- Gebruik de Samba Backup integratie
- Backup naar je NAS of Google Drive

## Deel E: Problemen oplossen

MQTT berichten verdwijnen:
- Check of mosquitto nog draait via de terminal
- Bekijk de logs van mosquitto voor fouten

Zigbee apparaat doet raar:
- Check in Zigbee2MQTT of de verbindingskwaliteit goed is
- Verplaats het apparaat dichter naar een lamp die altijd aan staat
- Herstart Zigbee2MQTT

Home Assistant wordt traag:
- Check of je Postgres database gebruikt
- Verwijder oude data via Instellingen → Systeem → Opslag
- Check het geheugengebruik via de terminal

Automatisering werkt niet:
- Check of hij aan staat met de schakelaar rechtsboven
- Kijk in het logboek via Instellingen → Logboek
- Gebruik de trace functie bij de automatisering

## Gefeliciteerd!

Je bent nu een echte Home Assistant expert. Je hebt een professionele Docker setup met reverse proxy, een MQTT broker voor alle communicatie, Zigbee2MQTT voor draadloze sensoren, werkende automatiseringen, een mooi dashboard en backups voor veiligheid.

## Waar kun je meer leren:

Home Assistant officiële documentatie via home-assistant.io
Zigbee2MQTT supported devices lijst via zigbee2mqtt.io
HACS voor custom integraties via hacs.xyz
Blauwdrukken voor kant en klare automatiseringen via Instellingen → Automatiseringen & Scènes → Blauwdrukken

## Jouw volgende uitdagingen:

ESPHome om je eigen sensoren te maken met een ESP8266 of ESP32
Frigate voor camera's met herkenning van mensen en katten
Node-RED voor visuele automatiseringen met complexe logica
Grafana voor professionele dashboards met historische data

## Onthoud:

Je kunt bijna alles doen zonder ingewikkelde configuratiebestanden
Maak regelmatig backups
De community is gigantisch, elke vraag is al eens gesteld.