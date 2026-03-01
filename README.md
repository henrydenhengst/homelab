# 🚀 Henry's Lean & Mean Homelab
> **"Waar anderen resources verspillen, bouw ik efficiëntie. Homelab architect met een passie voor minimalisme."**

[![Ansible](https://img.shields.io/badge/Ansible-2.10+-black.svg?style=for-the-badge&logo=ansible)](https://www.ansible.com/)
[![Docker](https://img.shields.io/badge/Docker-CE-blue.svg?style=for-the-badge&logo=docker)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

Dit project bevat mijn persoonlijke **Infrastructure as Code (IaC)** suite. Het is ontworpen om een Linux-server volledig te strippen van ballast (GUI, X11, LaTeX) en om te toveren tot een gestroomlijnde, headless Docker-host.



---

## 🎯 De Filosofie
Waarom moeilijk doen als het efficiënt kan? Dit project volgt drie kernprincipes:
1.  **Headless by Default:** Geen schermen, geen verspilde RAM. Alles via SSH en Web-UI.
2.  **OS-Agnostisch:** Of je nu **Debian**, **RedHat** of **Arch Linux** draait; de "Henry-standaard" wordt overal afgedwongen.
3.  **Idempotentie:** Je kunt het playbook op elk moment draaien om je systeem terug te brengen naar de perfecte staat.

## 🛡️ Privacy & Open Source Statement
* **Zero Tracking:** Geen Google Analytics of externe scripts.
* **Local First:** Data blijft binnen de muren van mijn homelab.
* **Open Source:** Alle gebruikte rollen (Caddy, Home Assistant, Mosquitto) zijn 100% transparant en auditeerbaar.

---

## 🌍 Duurzaam & Toegankelijk
High-end privacy hoeft niet duur te zijn. Dit project bewijst dat je met:
* **Hardware van 15 jaar oud:** Geef die oude laptop of desktop een tweede leven.
* **Betaalbare 'Goodies':** Slimme uitbreidingen via Amazon of AliExpress (Zigbee, Bluetooth).
* **Open Source Software:** Geen licentiekosten, geen abonnementen.

...een systeem kunt bouwen dat veiliger en krachtiger is dan de gemiddelde commerciële 'smart home' hub. **Privacy is voor iedereen binnen bereik.** ✊

---

## 🏗️ Project Structuur

### 🛠️ Basis & Hardening
| Rol | Taak | Status |
| :--- | :--- | :--- |
| `common` | **De Bezem:** Verwijdert GUI/X11/LaTeX ballast & stelt `multi-user.target` in. | ✅ Actief |
| `security` | Systeem-updates en SSH-hardening. | ✅ Actief |
| `fail2ban` | Bescherming tegen brute-force aanvallen. | ✅ Actief |

### 🐳 Container Stack
| Rol | Functionaliteit |
| :--- | :--- |
| `docker` | Installatie van de officiële Docker-CE engine. |
| `portainer` | Visueel beheer van al je containers. |
| `caddy` | **De Poortwachter:** Reverse proxy met automatische SSL via Let's Encrypt. |

### 🏠 Home Automation
| Rol | Doel |
| :--- | :--- |
| `homeassistant` | Het centrale brein van de woning. |
| `zigbee2mqtt` | Communicatie met Zigbee hardware (incl. Bluetooth ondersteuning). |
| `mosquitto` | De MQTT-broker voor alle sensorinformatie. |

---

## 📺 Media, YouTube & Websites

### 🐳 Containers & Automatisering
* **[Sven's Tech Corner (YouTube)](https://www.youtube.com/@SvensTechCorner)** - Uitstekende uitleg over **Docker** en containers. Ideaal voor wie wil begrijpen hoe software 'verpakt' wordt.
* **[Ansible voor Beginners](https://www.computable.nl/artikel/achtergrond/beheer/6910620/5241036/wat-is-ansible-eigenlijk.html)** - Een heldere introductie in de kracht van automatisering zonder typefouten.

### 🏠 Home Assistant & Smarthome
* **[HW-Install (YouTube)](https://www.youtube.com/@HWInstall)** - Dé plek voor diepgaande video's over Home Assistant installaties en hardware-tips.
* **[Tweakers.net - Home Automation Forum](https://gathering.tweakers.net/forum/list_topics/82)** - De grootste en meest behulpzame Nederlandstalige community voor al je vragen.
* **[Home Assistant Community (NL sectie)](https://community.home-assistant.io/c/non-english/nederlands-dutch/27)** - Directe hulp van mede-gebruikers in je eigen taal.


---

## 🚀 Snel aan de slag

### 1. Repository Clonen

git clone [https://github.com/henrydenhengst/homelab.git](https://github.com/henrydenhengst/homelab.git)

```bash
cd homelab
ansible-playbook -i inventory.yml site.yml
