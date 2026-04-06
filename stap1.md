# MQTT Integratie toevoegen in Home Assistant

## Stap 1: Open Home Assistant
- Ga naar: https://homeassistant.denhengst.duckdns.org
- Log in met je admin account

## Stap 2: Voeg MQTT integratie toe
1. Klik links in het menu op **Instellingen** (tandwiel icoon)
2. Klik op **Apparaten & Diensten** (Devices & Services)
3. Klik rechtsonder op de blauwe knop **➕ INTEGRATIE TOEVOEGEN**
4. Typ in het zoekveld: `MQTT`
5. Klik op **MQTT** in de zoekresultaten

## Stap 3: Vul de verbindingsgegevens in
- **Broker:** `mosquitto`
- **Poort:** `1883` (blijft zoals hij is)
- **Gebruikersnaam:** (laat leeg)
- **Wachtwoord:** (laat leeg)
- **Client ID:** (laat leeg - wordt automatisch gegenereerd)

## Stap 4: Verstuur
- Klik op de knop **VERZENDEN** (of SUBMIT)

## Stap 5: Controleer of het gelukt is
- Je ziet een groene melding: "Succesvol verbonden met MQTT broker"
- Het MQTT kaartje verschijnt in je integraties overzicht

## Stap 6: Test de verbinding (optioneel maar handig)
1. Klik op het **MQTT** kaartje in de integratielijst
2. Klik op het tabje **Instellingen** (of Configureren)
3. Klik op **LUISTER NAAR EEN TOPIC** (Listen to a topic)
4. Vul in het veld: `#`
5. Klik op **START LISTENING**
6. Je ziet nu binnenkomende MQTT berichten verschijnen (als er al apparaten zijn)

## Klaar!
De MQTT broker is nu verbonden met Home Assistant.