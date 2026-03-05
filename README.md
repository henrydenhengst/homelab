# 🚀 Home Assistant Homelab

> Dit project is een Infrastructure-as-Code suite die een Linux-server volledig stript van ballast en inricht als een geoptimaliseerde, headless Docker-host voor o.a. Home Assistant en Vaultwarden.

### 🛠️ Tech Stack & Status

| Categorie | Badges |
| :--- | :--- |
| **Logic** | ![Python](https://img.shields.io/badge/Python-3.9+-3776AB?style=flat-square&logo=python&logoColor=white) ![YAML](https://img.shields.io/badge/YAML-Configuration-red?style=flat-square&logo=yaml&logoColor=white) |
| **Automation** | ![Ansible](https://img.shields.io/badge/Ansible-2.10+-black?style=flat-square&logo=ansible) ![Vault](https://img.shields.io/badge/Ansible_Vault-Encrypted-yellow?style=flat-square&logo=ansible) |
| **Infra** | ![Docker](https://img.shields.io/badge/Docker-CE-2496ED?style=flat-square&logo=docker&logoColor=white) ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-4169E1?style=flat-square&logo=postgresql&logoColor=white) |
| **Security** | ![Lynis](https://img.shields.io/badge/Lynis_Index-66%2F100-orange?style=flat-square) ![License](https://img.shields.io/badge/License-MIT-green?style=flat-square) |
| **Health** | ![Build](https://img.shields.io/badge/Build-passing-brightgreen?style=flat-square) ![Version](https://img.shields.io/badge/Version-1.0.0-orange?style=flat-square) |

## 📖 Over het project

Dit project is een Infrastructure-as-Code suite die de "standaard" afdwingt op homelab hardware.

Ontwikkeld door voor het beheren van een minimalistische Home Assistant homelab.
Een verzameling Ansible-rollen die een Linux-server strippen van GUI/ballast en configureren als Docker-host voor o.a. Vaultwarden, Caddy en Home Assistant.
Ontworpen voor headless Linux-omgevingen (bijv. Intel N100 of oude laptops) binnen het lokale netwerk.
Te gebruiken bij de initiële setup van een server en bij elke configuratiewijziging om de "Gouden Staat" te behouden.
Om hardware-resources optimaal te benutten (geen verspilling) en om een reproduceerbare, veilige omgeving te hebben zonder handmatige fouten.

---

## ✨ Features

- 🛡️ Core Infrastructure & Security
- 🐳 Container & Netwerk Stack
- 🔐 Apps & Data

---

## 📸 Screenshots (optioneel)

Voeg screenshots of GIFs toe van je project.

```
![Screenshot](docs/screenshot.png)
```

---

## 🛠️ Tech Stack

- **Ansible**: Voor configuratiebeheer en automatisering.
- **Docker**: Voor containerisatie van alle services.
- **Python**: Als runtime voor Ansible en custom scripts.
- **PostgreSQL**: Voor persistente en veilige data-opslag.
- **YAML**: Voor leesbare Infrastructure-as-Code.

---

## ⚙️ Installatie

Stap-voor-stap installatie.

```bash
git clone https://github.com/henrydenhengst/homelab.git
cd homelab
cp group_vars/all/secret.example.yml group_vars/all/secret.yml
vim group_vars/all/secret.yml
ansible-vault encrypt group_vars/all/secret.yml
ansible-playbook site.yml --ask-vault-pass
```

---

## 📂 Project structuur

```
.
├── group_vars
│   └── all
├── inventory
│   └── group_vars
└── roles
    ├── caddy
    ├── common
    ├── docker
    ├── duckdns
    ├── esphome
    ├── fail2ban
    ├── flame
    ├── gotify
    ├── hardware_discovery
    ├── homeassistant
    ├── matter_server
    ├── mosquitto
    ├── portainer
    ├── postgres
    ├── rclone
    ├── rsync
    ├── rtl_433
    ├── security
    ├── vaultwarden
    ├── zigbee2mqtt
    └── zwavejsui

```

---

## 🧪 Tests

Hoe je tests runt.

```bash
ansible-playbook site.yml --syntax-check
ansible-playbook site.yml --check --ask-vault-pass
ansible all -m ping
```

### 🩺 Automated Healthcheck
Na elke run voer ik een automatische controle uit op de vitale functies van het systeem:
- **Container Check:** Zijn Home Assistant, MQTT en Postgres stabiel?
- **Port Check:** Staan de noodzakelijke poorten open voor data-verkeer?
- **Disk Check:** Is er nog voldoende ruimte op de SSD (voor database logs)?

Uitvoeren via:
```bash
ansible-playbook site.yml --tags healthcheck
```

---


## 🏗️ Systeemvereisten

### 🔌 Hardware (Server)
* **CPU:** Minimaal 2 Cores (Intel N100, oude laptop/mini-pc/desktop).
* **RAM:** 4GB minimaal (8GB aanbevolen voor data-analyse).
* **Opslag:** 32GB+ SSD/NVMe (Vermijd SD-kaarten voor database-stabiliteit).
* **Extra:** Externe USB backup-disk & Zigbee dongle (SkyConnect / Sonoff).

---

## 🎯 De Filosofie
Waarom moeilijk doen als het efficiënt kan? Dit project volgt drie kernprincipes:
1. **Headless by Default:** Geen schermen, geen verspilde RAM. Alles via SSH en Web-UI.
2. **OS-Agnostisch:** Of je nu **Debian**, **Arch** of **RedHat** draait; de "standaard" wordt overal afgedwongen.
3. **Idempotentie:** Je kunt het playbook op elk moment draaien om je systeem terug te brengen naar de perfecte staat.

---

## 📺 Media, YouTube & Websites

### 🌿 De Basis: Git & Docker
* **[Git Crash Course](https://www.youtube.com/watch?v=mAFoROnOfHs)** *Snelcursus om te begrijpen hoe je code beheert en veilig naar GitHub pusht.*
* **[Docker Roadmap: Beginner to Pro](https://www.youtube.com/watch?v=zFa9_K8BS8I)** *Alles over containers, van je eerste 'hello world' tot complexe omgevingen.*

### 🤖 Automatisering: Ansible
* **[Ansible Quick Start Course](https://www.youtube.com/watch?v=p9bda0-TIRc)** *De snelste manier om te begrijpen hoe Playbooks en Roles samenwerken.*
* **[Ansible Deep Dive - Playlist Deel 1](https://www.youtube.com/playlist?list=PL2_OBreMn7FqZkvMYt6ATmgC0KAGGJNAN)** *Grondige uitleg over de architectuur van Ansible.*
* **[Ansible Deep Dive - Playlist Deel 2](https://www.youtube.com/playlist?list=PLT98CRl2KxKEUHie1m24-wkyHpEsa4Y70)** *Geavanceerde configuraties voor de echte power-user.*

### Homelab: Home Assistant
* **[Home Assistant](https://www.youtube.com/watch?v=zr48wGUjle8)** *Home Assistant*
* **[Home Assistant Automation](https://www.youtube.com/watch?v=YN2Gpn1l4nU)** *Automations*
* **[Home Assistant Dashboard](https://www.youtube.com/watch?v=pC-VBly1Y00)** *Dashboards*

---

## 🤝 Contributing

Contributions zijn welkom!

1. Fork de repository
2. Maak een nieuwe branch

```
git checkout -b feature/my-feature
```

3. Commit je wijzigingen
4. Open een Pull Request

---

## ⚠️ Mogelijke Problemen (Pijnpunten)

Bij het draaien van een geautomatiseerd homelab op wisselende hardware kunnen de volgende obstakels optreden:

* **Hardware-Inconsistentie:** Verschillende namen voor netwerkinterfaces (`eno1` vs `eth0`) en variabele USB-paden voor Zigbee/Matter dongles.
* **Netwerkbeperkingen (CGNAT):** Providers die poort-forwarding blokkeren, waardoor de standaard HTTP-challenge voor SSL-certificaten (Caddy) faalt.
* **Architectuur-conflicten (CPU):** Docker-images die geoptimaliseerd zijn voor x86_64 (Intel) draaien niet op ARM (Raspberry Pi), wat leidt tot `exec format` fouten.
* **Opslag-fouten:** Onjuiste mount-points voor externe schijven, waardoor databases niet starten of de systeem-schijf onbedoeld volloopt.
* **Configuratie-drift:** Handmatige aanpassingen op de server die niet in de Ansible-code staan, wat leidt tot onvoorspelbaar gedrag bij een herinstallatie.

---

## 🗺️ Roadmap: De Weg naar de Standaard 2.0

Dit plan adresseert de bovenstaande problemen om de stack volledig hardware-agnostisch en robuust te maken.

### 📍 Fase 1: Slimme Hardware Discovery (Korte termijn)
- [ ] **Pre-flight Rol:** Ontwikkelen van een Ansible-taak die hardware (CPU-type, netwerk-ID, USB-sticks) scant vóór de installatie.
- [ ] **Persistente USB-Paden:** Volledige overstap van `/dev/ttyUSBx` naar het unieke `/dev/serial/by-id/` pad voor alle hardware-dongles.

### 📍 Fase 2: Netwerk & SSL Robuustheid
- [ ] **DNS-01 Challenge:** Caddy configureren voor SSL-validatie via DNS-records (DuckDNS API) om CGNAT-beperkingen volledig te omzeilen.
- [ ] **Health-Monitoring:** Implementeren van een centraal dashboard (Portainer/Uptime Kuma) voor real-time status van alle containers.

### 📍 Fase 3: Failover & Backup Strategie
- [ ] **Automated Off-site Backups:** Volledige integratie van de `rclone` rol met versleutelde uploads naar cloud-opslag.
- [ ] **Git-based Rollbacks:** Gebruik maken van Git-tags om configuraties snel terug te draaien naar een bewezen "Gouden Staat".

### 📍 Fase 4: Multi-Architectuur Support
- [ ] **Universal Stack:** Verifiëren en labelen van alle rollen voor zowel Intel/AMD als ARM-hardware, zodat de suite overal draait.


## 📝 License

Dit project valt onder de MIT License.

Zie `LICENSE` voor meer informatie.

---

## 👤 Auteur

Naam – @henrydenhengst

Project Link:
https://github.com/henrydenhengst/homeassistant

---

## ⭐ Support

Vind je dit project handig? Geef het een ⭐ op GitHub!






