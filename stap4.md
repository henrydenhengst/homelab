# FASE 4: Je eerste automatisering maken

## Wat je nu gaat doen:
Je gaat een eenvoudige maar krachtige automatisering bouwen: een lamp die aangaat bij beweging. Dit is de "Hallo Wereld" van het smart home en laat meteen zien hoe krachtig Home Assistant is.

## Stap 1: Open de automatisering editor
- Open Home Assistant (https://yyy.zzz.duckdns.org)
- Klik links in het menu op **Instellingen** (tandwiel icoon)
- Klik op **Automatiseringen & Scènes**
- Klik rechtsonder op de blauwe knop **➕ AUTOMATISERING TOEVOEGEN**
- Kies **Nieuwe automatisering** (niet "Lege automatisering" - die is voor gevorderden)

## Stap 2: Kies een trigger (wat moet er gebeuren?)
- Bij "Trigger type" selecteer je **Apparaat**
- Klik op het veld "Apparaat" en zoek je bewegingssensor
- Selecteer je bewegingssensor (bijv. "woonkamer_beweging")
- Bij "Trigger" selecteer je **Beweging gedetecteerd**
- Klik op **Opslaan**

## Stap 3: Kies een actie (wat moet er gebeuren?)
- Scroll naar beneden naar "Acties"
- Klik op **➕ ACTIE TOEVOEGEN**
- Bij "Actie type" selecteer je **Apparaat**
- Klik op het veld "Apparaat" en zoek je lamp
- Selecteer je lamp (bijv. "woonkamer_lamp")
- Bij "Actie" selecteer je **Aanzetten**
- Klik op **Opslaan**

## Stap 4: Voeg een wachtactie toe (zodat de lamp later uitgaat)
- Klik opnieuw op **➕ ACTIE TOEVOEGEN**
- Bij "Actie type" selecteer je **Wachten**
- Vul bij "Tijd" in: **2** (minuten)
- Klik op **Opslaan**

## Stap 5: Voeg een uitschakelactie toe
- Klik opnieuw op **➕ ACTIE TOEVOEGEN**
- Bij "Actie type" selecteer je **Apparaat**
- Klik op het veld "Apparaat" en zoek dezelfde lamp
- Selecteer je lamp
- Bij "Actie" selecteer je **Uitzetten**
- Klik op **Opslaan**

## Stap 6: Geef de automatisering een naam
- Klik bovenaan op het veld "Naam"
- Typ een herkenbare naam, bijvoorbeeld:
  - "Lamp aan bij beweging in woonkamer"
  - "Bewegingslicht hal"
  - "Keuken verlichting bij beweging"
- Klik rechtsonder op **AUTOMATISERING OPSLAAN**

## Stap 7: Zet de automatisering aan
- Je ziet nu de automatiseringskaart in het overzicht
- Zet de schakelaar rechtsboven op **AAN**
- De automatisering is nu actief!

## Stap 8: Test de automatisering
- Loop langs je bewegingssensor
- De lamp gaat binnen 1-2 seconden aan
- Blijf uit de buurt van de sensor (of loop weg)
- Na 2 minuten gaat de lamp automatisch uit
- Werkt het? Gefeliciteerd! Je hebt je eerste slimme automatisering!

## Variaties op deze automatisering (als je meer wilt):

### Alleen 's avonds actief:
- Klik op de automatisering om hem te bewerken
- Bij "Trigger" klik je op **➕ VOORWAARDE TOEVOEGEN**
- Kies **Tijdconditie**
- Selecteer "Na zonsondergang" en "Voor zonsopkomst"
- Opslaan - nu werkt de lamp alleen als het donker is

### Met een helderheidssensor (als je die hebt):
- Voeg een voorwaarde toe
- Kies **Apparaat** → je helderheidssensor
- Selecteer "Lager dan" en vul **50** (lux) in
- Alleen bij schemer/donker gaat de lamp aan

### Lamp langzamer uit laten gaan:
- Bij de wachtactie: verander 2 minuten naar 5 minuten
- Of als je een slimme lamp hebt met dimmer: voeg meerdere wachtacties toe met steeds lagere helderheid

## Uitbreiding: meerdere lampen tegelijk

Wil je dat meerdere lampen aangaan bij beweging?
- Bij de eerste actie (Aanzetten) klik je op het pijltje naast "Apparaat"
- Kies **Meerdere apparaten**
- Selecteer alle lampen die aan moeten gaan
- Doe hetzelfde bij de uitschakelactie

## Uitbreiding: alleen als iemand thuis is

- Voeg een voorwaarde toe
- Kies **Personen**
- Selecteer "Jij" (jouw persoon)
- Kies "Thuis"
- Nu werkt de automatisering alleen als jij thuis bent (en niet als je op vakantie bent)

## Mocht de automatisering niet werken:

Check of:
- De bewegingssensor wel beweging registreert (zie in Zigbee2MQTT)
- De lamp handmatig aan kan (test via dashboard)
- De automatisering nog AAN staat (schakelaar rechtsboven)
- Je niet per ongeluk de "wacht" te kort hebt ingesteld

## Gefeliciteerd! 🎉

Je hebt nu een volledig werkend slim huis met:
- ✅ Een MQTT broker (mosquitto)
- ✅ Een Zigbee brug (Zigbee2MQTT)
- ✅ Een Zigbee apparaat (lamp/sensor)
- ✅ Home Assistant als brein
- ✅ Je eerste automatisering

## Wat nu? (vervolgstappen)

Meer apparaten toevoegen:
- Herhaal Fase 3 voor elk nieuw Zigbee apparaat
- Bouw je Zigbee mesh netwerk uit (elk apparaat dat op 230V zit versterkt het signaal)

Meer automatiseringen:
- Deursensor + notificatie (via Gotify)
- Temperatuursensor + thermostaat
- Vakantiemodus (lampen random aan/uit)
- Wakker worden met oplopend licht

Dashboards bouwen:
- Een mooi overzicht voor op je telefoon
- Een tablet dashboard aan de muur
- Energieverbruik inzicht

Spraakbediening:
- Koppel Google Home of Alexa (via Caddy reverse proxy)
- "Hey Google, doe de woonkamer lamp uit"

## Je bent nu een Home Assistant bouwer!

Vanaf hier kun je alle kanten op. De community is enorm, en met jouw infra-achtergrond kun je echt mooie dingen bouwen.