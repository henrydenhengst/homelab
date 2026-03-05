# 🚀 Henry's Lean & Mean Homelab
> **"Waar anderen resources verspillen, bouw ik efficiëntie. Homelab architect met een passie voor minimalisme."**

[![Ansible](https://img.shields.io/badge/Ansible-2.10+-black.svg?style=for-the-badge&logo=ansible)](https://www.ansible.com/)
[![Docker](https://img.shields.io/badge/Docker-CE-blue.svg?style=for-the-badge&logo=docker)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

Dit project bevat mijn persoonlijke **Infrastructure as Code (IaC)** suite. Het is ontworpen om een Linux-server volledig te strippen van ballast (GUI, X11, LaTeX) en om te toveren tot een gestroomlijnde, headless Docker-host.

---

## 🏗️ Systeemvereisten

### 🔌 Hardware (Server)
* **CPU:** Minimaal 2 Cores (Intel N100, Raspberry Pi 4/5 of oude laptop/desktop).
* **RAM:** 4GB minimaal (8GB aanbevolen voor data-analyse & InfluxDB).
* **Opslag:** 32GB+ SSD/NVMe (Vermijd SD-kaarten voor database-stabiliteit).
* **Extra:** Externe USB backup-disk & Zigbee dongle (SkyConnect/Sonoff).

---

## 🎯 De Filosofie
Waarom moeilijk doen als het efficiënt kan? Dit project volgt drie kernprincipes:
1. **Headless by Default:** Geen schermen, geen verspilde RAM. Alles via SSH en Web-UI.
2. **OS-Agnostisch:** Of je nu **Debian**, **Ubuntu** of **RedHat** draait; de "Henry-standaard" wordt overal afgedwongen.
3. **Idempotentie:** Je kunt het playbook op elk moment draaien om je systeem terug te brengen naar de perfecte staat.

---

## 🏗️ Project Structuur

### 🛠️ Basis & Hardening
| Rol | Taak | Status |
| :--- | :--- | :--- |
| `common` | **De Bezem:** Verwijdert GUI/ballast & stelt passwordless sudo in voor `$USER`. | ✅ Actief |
| `security` | Systeem-updates, SSH-hardening en Lynis security scans. | ✅ Actief |
| `fail2ban` | Bescherming tegen brute-force aanvallen. | ✅ Actief |
| `audit` | **De Rapporteur:** Genereert automatische PDF-audits van je hardware & security. | ✅ Actief |

### 🐳 Container Stack
| Rol | Functionaliteit |
| :--- | :--- |
| `docker` | Installatie van de officiële Docker-CE engine. |
| `portainer` | Visueel beheer van al je containers. |
| `caddy` | Reverse proxy met automatische SSL via Let's Encrypt. |
| `vaultwarden` | Jouw eigen lokale wachtwoordmanager. |

---

## 📊 Automatische Rapportage (Audit)
Dit project is zelf-documenterend. Na elke run genereert Ansible een professionele PDF-audit in `~/homelab-reports/`:
* **Security Score:** Gebaseerd op de Lynis Hardening Index.
* **Hardware Specs:** Actueel CPU, RAM en Disk verbruik.
* **Service Check:** Overzicht van alle actieve Docker containers.

---

## 📺 Media, YouTube & Websites

### 🌿 De Basis: Git & Docker
* **[Git Crash Course](https://www.youtube.com/watch?v=mAFoROnOfHs)** *Snelcursus om te begrijpen hoe je code beheert en veilig naar GitHub pusht.*
* **[Docker Roadmap: Beginner to Pro](https://www.youtube.com/watch?v=zFa9_K8BS8I)** *Alles over containers, van je eerste 'hello world' tot complexe omgevingen.*

### 🤖 Automatisering: Ansible
* **[Ansible Quick Start Course](https://www.youtube.com/watch?v=p9bda0-TIRc)** *De snelste manier om te begrijpen hoe Playbooks en Roles samenwerken.*
* **[Ansible Deep Dive - Playlist Deel 1](https://www.youtube.com/playlist?list=PL2_OBreMn7FqZkvMYt6ATmgC0KAGGJNAN)** *Grondige uitleg over de architectuur van Ansible.*
* **[Ansible Deep Dive - Playlist Deel 2](https://www.youtube.com/playlist?list=PLT98CRl2KxKEUHie1m24-wkyHpEsa4Y70)** *Geavanceerde configuraties voor de echte power-user.*

---

## 🚀 Snel aan de slag

### 1. Voorbereiding Laptop/PC
Installeer de PDF-motor op je eigen machine:
* **MacOS:** `brew install pango && pip3 install weasyprint`
* **Windows (WSL2) / Linux:** `sudo apt update && sudo apt install python3-weasyprint -y`

### 2. SSH Handdruk & Rechten
Vergeet de inventory.yml niet aan te passen met jouw server(s)!
Zorg dat je zonder wachtwoord kunt inloggen op je server:
```bash
ssh-keygen -t ed25519
ssh-copy-id $USER@<server-ip>

# Repository Clonen

git clone https://github.com/henrydenhengst/homelab.git
cd homelab

# Setup de omgeving voor jouw gebruiker ($USER)
chmod +x setup_homelab_audit.sh
./setup_homelab_audit.sh

# Geheimen configureren
cp vault.yml.example group_vars/all/vault.yml
ansible-vault encrypt group_vars/all/vault.yml

# Eerste run (inclusief privilege escalation)
ansible-playbook -i inventory/hosts site.yml --ask-vault-pass --ask-become-pass
