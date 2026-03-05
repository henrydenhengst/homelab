# 🚀 Henry's Lean & Mean Home Assistant Homelab

> Korte beschrijving van wat dit project doet.

![Ansible](https://img.shields.io/badge/Ansible-2.10+-black.svg?style=for-the-badge&logo=ansible)
![Docker](https://img.shields.io/badge/Docker-CE-blue.svg?style=for-the-badge&logo=docker)
![License](https://img.shields.io/badge/license-MIT-blue)
![Build](https://img.shields.io/badge/build-passing-brightgreen)
![Version](https://img.shields.io/badge/version-1.0.0-orange)

## 📖 Over het project

Dit project is een Infrastructure-as-Code suite die de "Henry-standaard" afdwingt op homelab hardware.

**Wie:** Ontwikkeld door voor het beheren van een minimalistische Home Assistant homelab.
**Wat:** Een verzameling Ansible-rollen die een Linux-server strippen van GUI/ballast en configureren als Docker-host voor o.a. Vaultwarden, Caddy en Home Assistant.
**Waar:** Ontworpen voor headless Linux-omgevingen (bijv. Intel N100 of oude laptops) binnen het lokale netwerk.
**Wanneer:** Te gebruiken bij de initiële setup van een server en bij elke configuratiewijziging om de "Gouden Staat" te behouden.
**Waarom:** Om hardware-resources optimaal te benutten (geen verspilling) en om een reproduceerbare, veilige omgeving te hebben zonder handmatige fouten.

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
2. **OS-Agnostisch:** Of je nu **Debian**, **Arch** of **RedHat** draait; de "Henry-standaard" wordt overal afgedwongen.
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
* **[Home Assistant] (https://www.youtube.com/watch?v=zr48wGUjle8)**
* **[Home Assistant Automation] https://www.youtube.com/watch?v=YN2Gpn1l4nU)**
* **[Home Assistant Dashboard] https://www.youtube.com/watch?v=pC-VBly1Y00)**

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






