# FASE 3: Je eerste Zigbee apparaat toevoegen

## Wat je nu gaat doen:
Je gaat een Zigbee apparaat (lamp, sensor of schakelaar) koppelen aan je Zigbee2MQTT netwerk. Zodra dit gelukt is, verschijnt het apparaat automatisch in Home Assistant.

## Belangrijk voor je begint:
- Zorg dat Permit Join nog AAN staat in Zigbee2MQTT (zie Fase 2, Stap 6)
- Staat hij UIT? Zet hem dan weer kort even AAN (max 10 minuten)
- Zet je apparaat klaar in dezelfde ruimte als je Zigbee coordinator (USB stick)

## Stap 1: Zet je Zigbee apparaat in pairing mode

Elk apparaat heeft zijn eigen manier. Hier zijn de meest voorkomende:

Lamp (Ikea Tradfri, Philips Hue):
- Zet de lamp in een fitting die stroom heeft
- Zet hem uit en aan met de lichtschakelaar
- Herhaal dit 6 keer (aan-uit-aan-uit-aan-uit-aan-uit-aan-uit-aan)
- De lamp knippert of dimt even - dat betekent dat hij in pairing mode is

Bewegingssensor (Aqara, Philips Hue):
- Houd de kleine knop aan de achterkant of binnenkant ingedrukt
- Houd hem 5 seconden ingedrukt tot een LEDje knippert
- Laat los - de sensor is nu in pairing mode

Deursensor (Aqara, Sonoff):
- Houd de resetknop (meestal naast de batterij) 5 seconden ingedrukt
- Het LEDje knippert een paar keer
- Laat los - de sensor is nu in pairing mode

Schakelaar (Ikea, Sonoff):
- Houd de pairknop (soms achter de batterij) 5-10 seconden ingedrukt
- Vaak knippert er een LEDje
- Laat los zodra hij knippert

Temperatuursensor (Xiaomi, Aqara):
- Houd de knop naast de batterij 5 seconden ingedrukt
- Het LEDje knippert blauw
- Laat los - hij is nu in pairing mode

## Stap 2: Kijk in Zigbee2MQTT of het apparaat verschijnt

- Ga terug naar de Zigbee2MQTT interface (http://[IP_van_jouw_server]:8081)
- Klik op het tabje "Kaart" (Map) of "Apparaten" (Devices)
- Binnen 10-30 seconden zie je een nieuw apparaat verschijnen
- Het heeft een technische naam zoals "0x00124b0012345678"

## Stap 3: Geef het apparaat een herkenbare naam

- Klik op het nieuwe apparaat in de lijst
- Klik op de knop "Hernoem" (Rename)
- Typ een duidelijke naam, bijvoorbeeld:
  - "woonkamer_lamp"
  - "voordeur_sensor"
  - "keuken_beweging"
  - "slaapkamer_raam"
- Klik op "Opslaan" (Save)
- De nieuwe naam is nu zichtbaar in zowel Zigbee2MQTT als Home Assistant

## Stap 4: Controleer of het apparaat werkt in Zigbee2MQTT

- Klik op het apparaat om de details te zien
- Je ziet nu informatie zoals:
  - Batterijstatus (bij sensoren)
  - Link quality (hoe goed het signaal is)
  - Bij een lamp: of hij aan of uit staat
  - Bij een sensor: de laatste meting
- Test het apparaat:
  - Lamp: zet hem aan/uit via de interface
  - Sensor: beweeg ervoor of open/close de deur
  - Je ziet de status veranderen in real-time

## Stap 5: Het apparaat verschijnt in Home Assistant

- Open Home Assistant (https://homeassistant.denhengst.duckdns.org)
- Kijk rechtsboven bij het belletje (meldingen)
- Je ziet: "Nieuwe apparaten ontdekt" of "1 nieuwe integratie"
- Het apparaat is nu automatisch toegevoegd - je hoeft niets te doen!

## Stap 6: Vind je apparaat in Home Assistant

- Ga naar Instellingen → Apparaten & Diensten
- Klik op het tabje "Apparaten"
- Zoek de naam die je zojuist hebt gegeven
- Klik erop om alle entiteiten (functionaliteiten) te zien:
  - Lamp: aan/uit schakelaar, helderheid (soms), kleur (soms)
  - Bewegingssensor: binary_sensor (aan/uit), batterij sensor
  - Deursensor: binary_sensor (open/dicht), batterij sensor
  - Temperatuursensor: sensor (temperatuur), sensor (luchtvochtigheid)

## Stap 7: Test het apparaat in Home Assistant

- Ga naar het tabje "Overzicht" (Overview)
- Klik op de lamp - hij gaat aan!
- Of kijk naar de sensor waarden terwijl je beweegt of een deur opent
- Alles werkt zonder extra configuratie!

## Wat nu? Je hebt twee opties:

Optie 1: Meer apparaten toevoegen
- Herhaal Stap 1 tot en met 4 voor elk nieuw Zigbee apparaat
- Vergeet niet Permit Join aan te zetten voordat je paart
- Zet Permit Join uit als je klaar bent met pair-en

Optie 2: Maak je eerste automatisering
- Ga verder met Fase 4 (Eerste automatisering)

## Veelvoorkomende problemen:

Apparaat verschijnt niet:
- Staat Permit Join nog aan? Zet hem opnieuw aan
- Is het apparaat te ver van de coordinator? Zet hem dichterbij
- Moet het apparaat gereset worden? Google "[apparaat] factory reset"

Apparaat paired maar doet niets:
- Sommige apparaten moeten eerst een paar seconden wachten
- Check in Zigbee2MQTT log of er fouten staan
- Reset het apparaat en probeer opnieuw

Apparaat verschijnt niet in Home Assistant:
- Wacht maximaal 1 minuut - het duurt soms even
- Check of MQTT nog werkt (Fase 1)
- Herstart Home Assistant container

## Gefeliciteerd!
Je hebt nu je eerste Zigbee apparaat werkend in Home Assistant. Je slimme huis begint vorm te krijgen!

## Volgende stap:
Wil je een automatisering maken? Ga naar Fase 4.
Wil je meer apparaten toevoegen? Herhaal Fase 3.