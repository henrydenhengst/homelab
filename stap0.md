# Compleet actieplan: Van MQTT naar werkende automatisering

## Fase 1: MQTT verbinden (wat je net hebt gedaan)
✅ MQTT integratie toevoegen in HA
✅ Verbinding maken met mosquitto broker

## Fase 2: Zigbee2MQTT klaarzetten (NU)

### Wat ga je doen?
Zigbee2MQTT is de brug tussen je Zigbee apparaten (lampen, sensoren, schakelaars) en je MQTT broker. Die moet nog weten dat hij via Mosquitto mag praten.

### Stappen:
1. **Open Zigbee2MQTT interface**
   - Ga naar: `http://[IP_van_jouw_server]:8081`
   - (Of check via Portainer welke poort Zigbee2MQTT gebruikt)

2. **Configureer MQTT instellingen in Zigbee2MQTT**
   - Klik op tabje **Instellingen** (Settings)
   - Klik op **MQTT** in het linkermenu
   - Vul bij *MQTT Server*: `mqtt://mosquitto:1883`
   - Klik op **Opslaan** (Save)
   - Herstart Zigbee2MQTT (knopje rechtsboven)

3. **Zet pairing mode aan**
   - Ga naar **Instellingen** → **Zigbee adapter**
   - Zet **Permit join** op AAN (tijdelijk!)
   - Laat dit maar 5-10 minuten aan terwijl je apparaten toevoegt
   - **BELANGRIJK:** Zet hem later weer UIT om ongewenste pairing te voorkomen

## Fase 3: Zigbee apparaat toevoegen (EERSTE LAMP/SENSOR)

### Wat heb je nodig?
- Een Zigbee lamp (Ikea Tradfri, Philips Hue, enz.)
- OF een Zigbee sensor (beweging, deur, temperatuur)

### Stappen:
1. **Zet je apparaat in pairing mode**
   - Lamp: Zet hem 6x aan/uit (knippert)
   - Sensor: Houd de pair-knop 5 seconden ingedrukt (LED knippert)

2. **Kijk in Zigbee2MQTT**
   - Ga naar tabje **Kaart** (Map) of **Apparaten** (Devices)
   - Je ziet een nieuw apparaat verschijnen met een naam zoals "0x00124b0012345678"

3. **Hernoem het apparaat** (handig!)
   - Klik op het apparaat
   - Klik op **Hernoem** (Rename)
   - Geef een naam: "woonkamer_lamp" of "voordeur_sensor"

4. **Zigbee2MQTT stuurt nu automatisch naar MQTT**
   - Je hoeft niets te doen - het werkt direct
   - Het apparaat verschijnt binnen 30 seconden automatisch in Home Assistant

## Fase 4: Apparaat vinden in Home Assistant

### Stappen:
1. **Open Home Assistant**
2. **Check meldingen**
   - Kijk rechtsboven bij het meldingen icoontje (bel)
   - Je ziet: "Nieuwe apparaten ontdekt"

3. **Voeg het apparaat toe**
   - Ga naar **Instellingen** → **Apparaten & Diensten**
   - Klik op **Apparaten** tabje
   - Zoek je nieuwe lamp/sensor (herkenbaar aan de naam die je gaf)
   - Klik op **CONFIGUREREN** (als dat nodig is)

4. **Test of hij werkt**
   - Ga naar **Overzicht** (Overview)
   - Klik op de lamp → hij gaat aan!
   - Bij sensor: beweeg ervoor → status verandert van "clear" naar "detected"

## Fase 5: Eerste automatisering (de kers op de taart)

### Voorbeeld: Bewegingslamp
1. **Instellingen** → **Automatiseringen & Scènes**
2. **Nieuwe automatisering** → **Lege automatisering**
3. **Trigger:** Apparaat → kies je bewegingssensor → "Beweging gedetecteerd"
4. **Actie:** Apparaat → kies je lamp → "Aanzetten"
5. **Aanvullende actie (optioneel):** Wacht 2 minuten → Lamp uitzetten
6. **Opslaan** → **Inschakelen**

### Gefeliciteerd! 🎉
Je hebt nu een werkend slim huis met:
- MQTT broker als postbode
- Zigbee2MQTT als vertaler
- Home Assistant als brein
- Jouw eerste automatisering

## Veelgemaakte foutjes (mocht er iets misgaan)

**Probleem:** Apparaat verschijnt niet in HA
**Oorzaak:** MQTT nog niet verbonden in Zigbee2MQTT
**Oplossing:** Check of Zigbee2MQTT de broker kan bereiken (zie logboek)

**Probleem:** Kan Zigbee apparaat niet pair-en
**Oorzaak:** Permit join staat niet aan
**Oplossing:** Zet Permit join op AAN (max 10 minuten)

**Probleem:** Apparaat paired maar doet niets
**Oorzaak:** Apparaat moet gereset worden
**Oplossing:** Googlen "[apparaatnaam] zigbee2mqtt pairing" voor specifieke reset stappen

## Wat is het eerste apparaat dat je gaat toevoegen?
- [ ] Ikea Tradfri lamp
- [ ] Philips Hue lamp
- [ ] Bewegingssensor
- [ ] Deursensor
- [ ] Temperatuursensor
- [ ] Slimme stekker
- [ ] Anders: ____________