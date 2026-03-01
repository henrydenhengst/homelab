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

## 🚀 Snel aan de slag

### 1. Repository Clonen
```bash
git clone [https://github.com/henrydenhengst/homelab.git](https://github.com/henrydenhengst/homelab.git)
cd homelab
