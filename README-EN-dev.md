# 🚀 Home Assistant Homelab

> This project is an Infrastructure-as-Code suite that strips a Linux server down to its essentials and configures it as an optimized, headless Docker host for services like Home Assistant and Vaultwarden.

## 🛠️ Tech Stack & Status

  | Categorie | Badges |
  | :--- | :--- |
  | **Logic** | ![Python](https://img.shields.io/badge/Python-3.9+-3776AB?style=flat-square&logo=python&logoColor=white) ![YAML](https://img.shields.io/badge/YAML-Configuration-red?style=flat-square&logo=yaml&logoColor=white) |
  | **Automation** | ![Ansible](https://img.shields.io/badge/Ansible-2.10+-black?style=flat-square&logo=ansible) ![Vault](https://img.shields.io/badge/Ansible_Vault-Encrypted-yellow?style=flat-square&logo=ansible) |
  | **Infra** | ![Docker](https://img.shields.io/badge/Docker-CE-2496ED?style=flat-square&logo=docker&logoColor=white) ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-4169E1?style=flat-square&logo=postgresql&logoColor=white) |
  | **Security** | ![Lynis](https://img.shields.io/badge/Lynis_Index-66%2F100-orange?style=flat-square) ![License](https://img.shields.io/badge/License-MIT-green?style=flat-square) |
  | **Health** | ![Build](https://img.shields.io/badge/Build-passing-brightgreen?style=flat-square) ![Version](https://img.shields.io/badge/Version-1.0.0-orange?style=flat-square) |

---

## 1. Project Overview
- ### 🎯 Project Vision / Why This Exists
    
  Why build this when there are so many other homelab setups?
  
  - **Reproducibility First:** Your homelab should be a code repository, not a snowflake server
  - **Local-First Philosophy:** All data stays on your hardware - no cloud dependencies
  - **Sustainability:** Give old hardware a second life instead of buying new
  - **Learning by Doing:** Understand every component of your smart home

- ### 🔧 Key Features
    
  #### 🛡️ Security by Default
  - Automated system hardening with Lynis
  - Fail2ban for intrusion prevention
  - Automatic SSL certificates via Caddy
  - Encrypted secrets with Ansible Vault
  - Regular security updates

- ### 🛠️ Tech Stack

  - **Ansible**: For configuration management and automation.
  - **Docker**: For containerization of all services.
  - **Python**: As the runtime for Ansible and custom scripts.
  - **PostgreSQL**: For persistent and secure data storage.
  - **YAML**: For readable Infrastructure-as-Code.

- ### Project Structure
  ```
  homelab/
  ├── group_vars/        # Global configuration variables
  │   └── all/
  ├── inventory/         # Server inventory definitions
  └── roles/             # Ansible roles (organized by function)
    ├── core/            # Base system configuration
    │   ├── common       # System basics, users, SSH
    │   ├── docker       # Docker engine and compose
    │   └── security     # Firewall, fail2ban, hardening
    ├── networking/      # Network services
    │   ├── caddy        # Reverse proxy, SSL
    │   ├── duckdns      # Dynamic DNS
    │   └── mosquitto    # MQTT broker
    ├── database/        # Data persistence
    │   └── postgres     # PostgreSQL database
    ├── smart-home/      # Home automation core
    │   ├── homeassistant
    │   ├── zigbee2mqtt
    │   ├── zwavejsui
    │   ├── esphome
    │   └── matter_server
    └── utilities/       # Supporting services
        ├── vaultwarden  # Password manager
        ├── portainer    # Container management
        ├── rclone       # Cloud backups
        └── ...          # And more!
   ```

---

## 2. Getting Started

- ### 📋 Prerequisites
  
  #### 🖥️ On Your Target Server
  - A Linux server (Debian/Ubuntu/RedHat/Arch) with:
    - 2+ CPU cores (4+ CPU cores recommended)
    - 4GB+ RAM (8GB RAM recommended)
    - 32GB+ SSD/NVMe storage (256GB+ SSD/NVMe storage recommended)
    - SSH access to the server
    - (Optional) Zigbee dongle and others for smart home devices

  #### 🌐 Network Requirements  
  - **Wired Ethernet connection** (Wi-Fi not recommended for stability)
  - **DHCP reservation** or **static IP** on your server
  - **Port forwarding**:
    - Port 80/tcp (for SSL certificate issuance)
    - Port 443/tcp (for HTTPS access)
  - **DuckDNS account** (free) for dynamic DNS

- ### 🖥️ Hardware Recommendations
  
  #### Tested & Proven
  - **Intel N100/N95 Mini-PCs** (Beelink, Minisforum, etc.)
  - **HP EliteDesk/ProDesk Mini** G2, G3, G4
  - **Intel NUC** 7th gen and newer
  - **USB DISK** 500+ GB

  #### Recommended Zigbee/Z-Wave Adapters
  - **Sonoff Zigbee 3.0 USB Dongle Plus** - Best value
  - **Home Assistant SkyConnect** - Works out of box
  - **Conbee II/III** - Solid performer
  - **Zooz Z-Wave Stick** - For Z-Wave networks

  #### What to Avoid
  - ❌ Raspberry Pi 4 (ARM, limited RAM, SD card issues)
  - ❌ Old Pentium/Celeron (pre-2015) - lacks AES-NI for encryption
  - ❌ Consumer NAS devices - limited OS flexibility
  - ❌ SD cards as primary storage - too slow, unreliable
    
- ### Quick Start Installation Server

  ```bash
  git clone https://github.com/henrydenhengst/homelab.git
  cd homelab
  cp group_vars/all/secret.example.yml group_vars/all/secret.yml
  vim group_vars/all/secret.yml # Edit the file and fill in your details
  ansible-vault encrypt group_vars/all/secret.yml # Encrypt sensitive data
  ansible-playbook site.yml --ask-vault-pass # Deploy your server
  ansible-playbook site.yml --tags healthcheck --ask-vault-pass # Verify the installation
  ```

- ### Quick Start Installation Phone
  
  You need three apps on your phone. After installation, you won't need to check them again.
  
  #### 1. Home Assistant (The Boss)
  - 📲 [iOS App Store](https://apps.apple.com/app/home-assistant/id1099568401)
  - 📲 [Android Play Store](https://play.google.com/store/apps/details?id=io.homeassistant.companion.android)
  - **Login:** use your domain: `https://[YOUR-DOMAIN].duckdns.org`
  - **Username:** [YOUR-NAME]
  - **Password:** [YOUR-PASSWORD] (provided separately)
  
  #### 2. Gotify (For The Tech)
  - 📲 [iOS App Store](https://apps.apple.com/app/gotify/id1476400925) (or via TestFlight)
  - 📲 [Android Play Store](https://play.google.com/store/apps/details?id=com.github.gotify)
  - **Server:** `https://[YOUR-DOMAIN].duckdns.org/gotify`
  - **Client token:** [TOKEN] (provided separately)
  - **Settings:** enable notifications for this app
  
  > 💡 **Gotify is for us.** You'll receive notifications about your system's health here. You don't need to do anything with it—just keep it installed.
  
  #### 3. Telegram (For The Household)
  - 📲 [iOS App Store](https://apps.apple.com/app/telegram/id686449807)
  - 📲 [Android Play Store](https://play.google.com/store/apps/details?id=org.telegram.messenger)
  - **Create an account** (if you don't have one yet)
  - **Find the bot:** [LINK TO YOUR BOT]
  - **Press START**
  
  > 💡 **Telegram is for you.** This is where you'll get notifications like "Kitchen light acting up" or "Sensor battery is low." You can also send commands here (e.g., `/status`).

If these three apps are on your phone and you can log in, your system is ready to use. You won't hear from us again unless something important comes up (and then via Gotify or Telegram).

---

## 3. Configuration

- ### 🔑 Essential Variables - change to your taste

  Create your `group_vars/all/secret.yml` file with these variables:

  ```yaml
  # --- User & Location Settings ---
  main_user: "username"
  timezone: "Europe/Amsterdam"
  acme_email: "your-email@example.com"

  # --- DuckDNS & Network ---
  duckdns_domain: "yourdomain"           # Only the name, without .duckdns.org
  duckdns_token: "00000000-0000-0000-0000-000000000000"
  docker_network_name: "t2_network"

  # --- Hardware & Mounts ---
  usb_backup_uuid: "uuid-of-your-drive"
  usb_mount_path: "/mnt/backup-usb"
  zigbee_device: "/dev/serial/by-id/usb-xxxx_USB_Serial-xxxx"

  # --- Application Passwords ---
  db_password: "StrongPassword123!"
  flame_password: "StrongPassword123!"
  mqtt_password: "StrongPassword123!"
  gotify_password: "StrongPassword123!"
  caddy_admin_user: "admin_user"
  caddy_admin_password_hash: "$2a$14$GeneratedHashHere..."
  mqtt_admin_password: "StrongPassword123!"
  mqtt_admin_hash: "$2a$14$GeneratedHashHere..."

  # --- Flame Dashboard Settings ---
  flame_city: "CityName"
  flame_lat_long: "00.0000, 0.0000"
  flame_theme: "dark"

  # --- Subdomains (Caddy / Reverse Proxy) ---
  flame_subdomain: "dashboard"
  ha_subdomain: "ha"
  zigbee_subdomain: "zigbee"
  esphome_subdomain: "esphome"
  mqtt_subdomain: "mqtt"
  vault_subdomain: "vault"
  portainer_subdomain: "portainer"
  gotify_subdomain: "gotify"

  # --- Vault & Database ---
  vaultwarden_admin_token: "SuperSecretTokenHere..."
  vault_postgres_user: "db_user"
  vault_postgres_password: "StrongPassword123!"
  vault_rclone_token: '{"token":"replace-me"}'

- ### 🎨 Optional Customizations

  #### Use It As-Is, Or Make It Your Own

  The beauty of Infrastructure as Code is flexibility. You can:

  **🚀 Use it out of the box**
  Everything works with the default configuration. Just fill in your variables and go.

  **🔧 Or change anything you like**
  This is your homelab—tweak it until it feels like home:

  | What You Can Change | Examples |
  |-------------------|----------|
  | **Add/remove services** | Don't need Vaultwarden? Disable it. Want to add something new? Create a role. |
  | **Adjust resource limits** | Give Home Assistant more RAM, limit a container that's hungry |
  | **Change domains** | Use your own custom domain instead of DuckDNS |
  | **Modify security settings** | Stricter firewall rules, different fail2ban policies |
  | **Customize dashboards** | Flame layout, theme, colors—make it yours |
  | **Add your own automations** | Home Assistant automations, custom scripts |

  #### No Wrong Answers

  Whether you keep it 100% stock or hack it into something completely different:

  - ✅ **Your data stays yours** – Always local, always private
  - ✅ **The "Golden State" stays reproducible** – Infrastructure as Code guarantees it
  - ✅ **You can always revert to default** – Git revert or fresh clone, and you're back

  > 💡 **Pro tip:** Fork the repository and make it your own. Your customizations, version-controlled, forever.

- ### 🔒 Security Features Explained

  You've built a solid foundation for your homelab security. By combining Ansible automation with the "Golden State" principle, you minimize human errors—which is already a massive security advantage.

  Here's a breakdown of the key security features in your project:

  #### 1. Access Control & Network

  - **Reverse Proxy (Caddy):** Caddy acts as your "bouncer." No container (except the proxy itself) is directly reachable from the internet.
  - **Automatic SSL (HTTPS):** Caddy automatically handles your certificates, ensuring all traffic between your devices and the server is encrypted.
  - **Basic Auth:** For applications that lack built-in (strong) authentication (like ESPHome, Zigbee2MQTT, and Flame), you enforce an extra password layer via Caddy.
  - **Trusted Proxies:** In Home Assistant, you configure `trusted_proxies`, so HA only accepts traffic coming through your secure Caddy container.

  #### 2. Data Protection & Passwords

  - **Ansible Vault:** Sensitive information like passwords, API keys, and Wi-Fi credentials aren't stored in plain text. They're encrypted in a vault that only opens with your master password.
  - **Vaultwarden:** You run your own password manager, allowing you to generate unique, complex passwords for every service without relying on external parties.
  - **Hashed Passwords:** Your configuration files use hashed password variants. Even if someone were to see your Caddyfile, they couldn't read your actual passwords.

  #### 3. Container & System Security

  - **Docker Isolation:** Each service runs in its own container. If one service (e.g., Flame) has a vulnerability, the rest of your system remains isolated.
  - **Prune Policy:** Your `docker system prune` strategy keeps the system clean of old, unused images that might contain security vulnerabilities.
  - **Update Management:** Since everything is deployed via Ansible (`site.yml`), you can update all your containers to the latest, most secure versions with a single command.

  #### 4. Integrity & Recovery (Backup)

  - **Rsync (Local):** You ensure continuity with a local copy of your `/opt/appdata`. If a configuration breaks, you can immediately roll back to a working state.
  - **Rclone (Cloud):** By sending encrypted backups to the cloud, you're protected against physical disasters (like theft or hardware failure).
  - **Power Disconnect:** Your security plan includes physical safety too—cutting power to equipment when away reduces the risk of overheating or short circuits from cheaper adapters.

  #### 5. Monitoring & Notifications

  - **Gotify:** You've set up your own notification channel. This lets you receive immediate alerts when unusual events occur (e.g., a server reboot or a failed backup).

  > 💡 **Security by design, not by accident.** Every layer is automated, reproducible, and built to last.

---

## 4. Understanding the Stack
- ### 🏠 Services Overview: What This System Does For You

  Looking at your GitHub and the [Trikos Naming Convention](https://github.com/Trikos/Home-Assistant-Naming-Convention) integration, here are the **5 core services** this system delivers in your daily life:

  #### 1. Energy Management (Savings & Insights)
  *This is currently your most important service.*

  - **Vampire Slayer:** The system detects when equipment (TV, soundbar, game consoles) is in standby and physically cuts power via IKEA and Refoss smart plugs.
  - **Live Monitoring:** A real-time dashboard shows exactly how many watts you're consuming right now—and what it costs.
  - **Historical Overview:** See where the "power vampires" are hiding, per day, week, or month.

  #### 2. Centralized Entertainment Control
  *No more juggling 5 different apps for all your screens:*

  - **Unified Media Player:** One interface in Home Assistant (and on your Flame dashboard) to see and control all Android TVs, Chromecasts, and the JBL Partybox.
  - **Status Check:** At a glance, see if Denzel's Nintendo Switch in his room is still on.

  #### 3. Climate & Comfort Monitoring
  - **Environment Insights:** Sonoff sensors give you temperature and humidity data everywhere (living room, bathroom, bedrooms).
  - **Mold Prevention:** Automatic alerts (via Gotify) if bathroom humidity stays too high after showering.

  #### 4. Infrastructure & Security "as a Service"
  *This is the "invisible" layer that keeps everything running:*

  - **Password Vault:** Vaultwarden gives you secure, self-hosted storage for all your login credentials—accessible everywhere, but yours only.
  - **Notification Hub:** Gotify provides your own messaging service (independent of Google or Apple) for system alerts and warnings.
  - **Zero-Maintenance Backups:** Rsync and Rclone ensure your configuration (built with blood, sweat, and cola) is never lost.

  #### 5. Ease of Use (The "Single Source of Truth")
  - **[Trikos Naming Convention](https://github.com/Trikos/Home-Assistant-Naming-Convention):** Never search for "Lamp_123" again. Everything has logical names (`light.livingroom_tv_left_lamp`), making new automations 10x faster to build.
  - **Flame Dashboard:** One start page for the whole family—buttons to all important services, no need to remember IP addresses or ports.

  > **In short:** You're not just building a server; you're building a **personal utility company** that delivers savings, overview, and peace of mind.

- ### Project Structure
  > How Data Flows

  ```text
  homelab/
  ├── group_vars/               # Global configuration variables
  │   └── all/                   # Variables applied to all hosts
  │       ├── secret.example.yml # Example secrets template
  │       └── secret.yml         # Your encrypted secrets (Ansible Vault)
  │
  ├── inventory/                 # Server inventory definitions
  │   └── group_vars/            # Host-specific variables
  │
  └── roles/                     # Ansible roles (organized by function)
      │
      ├── core/                   # Base system configuration
      │   ├── common/             # System basics, users, SSH, timezone
      │   ├── docker/             # Docker engine and Docker Compose
      │   └── security/           # Firewall (UFW), fail2ban, system hardening
      │
      ├── networking/             # Network services
      │   ├── caddy/              # Reverse proxy, automatic SSL certificates
      │   ├── duckdns/            # Dynamic DNS updater
      │   └── mosquitto/          # MQTT broker for device communication
      │
      ├── database/               # Data persistence
      │   └── postgres/           # PostgreSQL database for various services
      │
      ├── smart-home/             # Home automation core
      │   ├── homeassistant/       # Main smart home platform
      │   ├── zigbee2mqtt/         # Zigbee device bridge
      │   ├── zwavejsui/           # Z-Wave device bridge
      │   ├── esphome/             # ESP8266/ESP32 device management
      │   └── matter_server/       # Matter protocol bridge
      │
      ├── monitoring/             # Health & performance
      │   ├── gotify/             # Self-hosted notification service
      │   └── portainer/          # Docker container management UI
      │
      ├── utilities/              # Supporting services
      │   ├── vaultwarden/         # Password manager (Bitwarden compatible)
      │   ├── flame/               # Customizable dashboard / startpage
      │   ├── rclone/              # Cloud backup synchronization
      │   ├── rsync/               # Local backup utility
      │   ├── rtl_433/             # 433MHz RF device receiver
      │   └── fail2ban/            # Intrusion prevention
      │
      └── discovery/               # Hardware detection
         └── hardware_discovery/   # Auto-detects USB devices (Zigbee, etc.)
  ```

  ### 🧩 Key Files

  | File | Purpose |
  |------|---------|
  | `site.yml` | Main Ansible playbook - runs everything |
  | `ansible.cfg` | Ansible configuration settings |
  | `inventory/hosts` | Defines your server(s) |
  | `group_vars/all/secret.yml` | Your encrypted secrets (passwords, tokens) |
  | `group_vars/all/secret.example.yml` | Template for required variables |

  ### 🔄 How It All Fits Together

  1. **Core roles** prepare the base system
  2. **Networking roles** establish connectivity
  3. **Database** provides persistent storage
  4. **Smart-home roles** deploy the actual services
  5. **Utilities** add convenience and backup
  6. **Discovery** ensures hardware is properly detected

- ### ⚡ Performance & Scaling

  #### 1. Docker Resource Management (Performance)

  - **Lightweight Containers:** By choosing services like Mosquitto (MQTT) and Gotify, you're using tools with an extremely low footprint. These consume virtually zero CPU cycles when idle.
  - **Network Stack:** Since everything runs in a single Docker network, services (e.g., Home Assistant to Mosquitto) communicate via the internal Docker bridge. This is many times faster than communication through your physical router or Wi-Fi network.
  - **I/O Optimization:** By running your databases (like Home Assistant's SQLite or Vaultwarden's database) on an SSD and limiting logs via Docker logging drivers, you prevent system slowdowns caused by disk activity.

  #### 2. The [Trikos Naming Convention](https://github.com/Trikos/Home-Assistant-Naming-Convention) as a Scaling Advantage

  Scaling isn't just about hardware—it's about the manageability of your data:

  - **Predictability:** Using the `domain.location_type_function_id` structure means you can add 50 new lights tomorrow without your naming conventions turning into a mess.
  - **Automation:** In Ansible, you can now work with loops. Instead of configuring each device individually, you input one list of [Trikos Naming Convention](https://github.com/Trikos/Home-Assistant-Naming-Convention) names and let Ansible do the rest. This scales from 5 to 500 devices with zero extra effort.

  #### 3. Protocol Efficiency

  - **MQTT (Mosquitto):** This is the pinnacle of scaling. Instead of Home Assistant having to ask each sensor every second "What's your value?" (polling), the sensor only "pushes" data when something changes. This saves enormous amounts of processing power.
  - **Zigbee vs. Wi-Fi:** By using Zigbee (via Zigbee2MQTT) for large groups of lights and plugs, you offload your Wi-Fi router. The more Zigbee devices you add, the stronger the mesh network becomes—while more Wi-Fi devices actually slow your network down.

  #### 4. System Cleanup (Pruning)

  - **Docker Prune:** Your TODO list includes the `docker system prune` command. This is essential for performance: it removes unused layers and volumes that would otherwise clutter your cache and fill your disk—which would ultimately harm Home Assistant's database performance.

  #### 5. Future Growth (Scaling Path)

  - **From SQLite to MariaDB/InfluxDB:** If, in a year, you've collected so much data from your P1 meter and Refoss plugs that Home Assistant becomes slow, your current Ansible structure allows you to easily add a heavier database container without overhauling your entire configuration.

  **In short:** You're building a foundation that doesn't "clog up." Whether you have 10 or 100 devices, your lights' response time will remain virtually the same.

---

## 5. Maintenance
- ### Regular Maintenance Tasks

  #### Weekly
  
  ```bash
  # Pull latest changes and apply updates
  git pull
  ansible-playbook site.yml --ask-vault-pass

  # Check system health
  ansible-playbook site.yml --tags healthcheck
  ```
  
  #### Monthly
  
  ```bash
  # Update all Docker images
  docker images | grep -v REPOSITORY | awk '{print $1}' | xargs -L1 docker pull

  # Prune old containers and images
  docker system prune -f

  # Check disk usage
  df -h /var/lib/docker
  ```
  #### Quarterly
  
  ```bash
  # Full system audit
  ansible-playbook site.yml --tags security-audit

  # Test backup restoration
  ansible-playbook site.yml --tags test-restore

  # Review logs
  journalctl --since "3 months ago" -p err -g "docker\|homeassistant"
  ```

- ### Upgrade Guide
  
  #### Version Upgrades  
  
  ##### Minor Updates (Patch releases)

  ```bash
  git pull
  ansible-playbook site.yml --ask-vault-pass
  ```
  
  ##### Major Upgrades
  - Backup everything first
  - Read the release notes
  - Test in staging if possible
  - Run with check mode first:  
  ```bash
  ansible-playbook site.yml --check --ask-vault-pass
  ```    
  - Perform upgrade during maintenance window
  ```bash
  ansible-playbook site.yml --ask-vault-pass
  ``` 
- ### Backup & Recovery Procedures
  #### How It Works in Practice:
  - Configuration: You define the UUID of your external USB backup drive (usb_backup_uuid) and the path to mount it (usb_mount_path) in your group_vars/all/secret.yml file. The rclone role would also require configuration for your cloud storage provider.
  - Automation: While not a separate playbook tag in the current README, the backup process is likely automated. It can be triggered in two ways:
  - As part of the main playbook: The site.yml playbook may include tasks from the rsync and rclone roles to ensure backups are performed regularly.
  - As a separate command: You could run backup-specific tasks using an Ansible tag (e.g., ansible-playbook site.yml --tags backup), although this specific tag isn't listed in the main README.
  #### The Process:
  - The rsync role would copy data from your server (e.g., /opt/appdata containing Home Assistant, database files, etc.) to the mounted USB drive.
  - The rclone role would then synchronize that local backup (or the data directly) to your configured cloud storage, ensuring the copy is encrypted for security.

- ### Disaster Recovery

  #### Restoring a Single File or Configuration:
  - If you accidentally break a configuration, you can manually restore a specific file or directory directly from the external USB drive mounted at /mnt/backup-usb. This is the fastest way to revert a small mistake.

  #### Full System Recovery (Planned) :
  The "Git-based Rollbacks" . This is the ultimate recovery procedure:
  - If the server hardware fails completely, you would set up a new machine with a base Linux OS.
  - You would clone your Homelab repository (git clone ...).
  - You would then run the main Ansible playbook (ansible-playbook site.yml). Because your configuration (including secrets encrypted with Ansible Vault) and backup data are stored separately, the playbook should be able to rebuild the entire system to its last known "Golden State" and restore the latest data from your backups.

  > In summary, your Homelab project establishes a solid foundation for data safety with local and off-site backups, managed as code. The planned enhancements will make the recovery process even more automated and foolproof.

## 6. Operations

- ### Health Checks & Monitoring
  - gotify your notification service if anything goes wrong
  - portainer your container management UI
  - additional health and monitoring containers can be implemented to help such as Uptime Kuma, NetData, and or many others.

- ### Troubleshooting Common Issues

  #### Stuck?

  - 1. 📖 **Check the [FAQ](#faq)** – Your question may already be answered
  - 2. 💬 **Ask for help** – Reach out to the community
  - 3. 🐛 **Post an issue** – If all else fails, [open a GitHub issue](https://github.com/henrydenhengst/homelab/issues)

  > 💡 **When posting an issue, include:**
  > - What you were trying to do
  > - What actually happened
  > - Relevant logs (Docker, Ansible)
  > - Your hardware setup

- ### Performance Tuning - Quick Wins (Highest Impact)

  - Use SSDs, not SD cards – Biggest performance gain
  - Keep databases on fast storage – Separate from OS if possible
  - Regular pruning – docker system prune -f
  - Limit logs – Set max size per container
  - Use wired network – Wi-Fi adds latency
  - USB extension cable – For (Zigbee) dongles (reduces interference)

- ### Logs & Debugging
  #### The easiest way is to add Dozzle to the stack
  - All your containers in one list
  - Live logs updating in real-time
  - Click any container to see its logs
  - Search/filter to find errors
  - No login, no setup, no database

## 7. Security
- ### Security Features Explained
- ### Verification Steps
- ### Hardening Details
- ### 🔐 Optional System Hardening (Lynis Score Booster)
  After the base installation, you can further strengthen your server's security by running the dedicated hardening playbook. This will significantly improve your Lynis security audit score.

  #### What it does

  The `lynis_hardening.yml` playbook automates several essential security measures:

  | Component | Action |
  |-----------|--------|
  | **SSH** | Changes to an obscure port (59612), disables root login, enforces key-based authentication, and applies multiple hardening settings |
  | **Kernel** | Optimizes 16+ sysctl parameters for better security (IP forwarding, SYN cookies, source routing, etc.) |
  | **Firewall** | Configures UFW to only allow the new SSH port with rate limiting, blocks port 22 |
  | **Rootkit scanners** | Installs and configures rkhunter, chkrootkit, AIDE, and ClamAV |
  | **Fail2ban** | Updates SSH jail to monitor the new port |
  | **Lynis audit** | Runs a final security scan to show your improved hardening score |

  #### Prerequisites

  - Your homelab server must be reachable via SSH
  - You have Ansible installed on your control machine
  - You have the vault password ready (if using encrypted secrets)

  #### How to run

  ```bash
  # First, do a dry-run to see what will change
  ansible-playbook playbooks/lynis_hardening.yml --check --ask-vault-pass

  # Then run the actual hardening (this will modify your system!)
  ansible-playbook playbooks/lynis_hardening.yml --ask-vault-pass
  ```

  #### ⚠️ Important notes
  Keep your current SSH session open until you've verified the new one works

  After the playbook completes, test the new SSH connection in a separate terminal:
  ```bash
  ssh -p 59612 henry@192.168.178.2
  ```
  
  If you have an existing SSH configuration on your client, update it to use the new port:
  ```bash  
  # Add to ~/.ssh/config
  Host homelab
    HostName 192.168.178.2
    Port 59612
    User <you>
  ```

  #### Expected result
  After a successful run, your Lynis hardening index should increase from around 66 to 80+. The playbook will display your new score at the end.


- ## Best Practices

### 8. Integration & Extension
- Adding Custom Services
- Integration Examples
- Custom Scripts
- API Access

### 9. Real-World Context
- Comparison with Alternatives
- Current Limitations
- Known Challenges & Solutions
- When to Upgrade

### 10. Migration
- Migrating from Other Systems
- Importing Existing Configurations
- Gradual Migration Strategy

### 11. Roadmap
- Phase 1: Smart Hardware Discovery
- Phase 2: Network & SSL Robustness
- Phase 3: Backup & Recovery
- Phase 4: Multi-Architecture Support

### 12. Community
- How to Get Help
- Contributing Guide
- Testing & Development
- Translation Efforts

### 13. Resources
- Learning Materials
- Beginner-Friendly Guides
- Deep Dive Content
- External Documentation

### 14. Legal & Support
- License
- Author Information
- Support Options
- Acknowledgments

### 15. Appendix
- FAQ
  > ❓ **Frequently Asked Questions (FAQ)**
  
  Welcome to the Homelab project FAQ. Here you'll find answers to common questions, from very practical to a bit technical.
  
  #### 📦 For (Future) Users
  
  ##### "What exactly do I get when I order a system from you?"
  You get a complete, working system in a box. That means:
  - A refurbished mini-PC (energy-efficient, quiet, ready for 24/7 use)
  - An external USB drive for daily backups (mandatory!)
  - The required smart dongles (e.g., for Zigbee, tailored to your needs)
  - All necessary USB extension cables (for optimal reception)
  - Pre-installed and configured software: Home Assistant, MQTT, Zigbee2MQTT, and more.
  - Secure remote access via your own DuckDNS domain name.
  
  In short: you only need to plug the power cables in and install the app on your phone. We handle the rest.
  
  ##### "Do I need to be technical?"
  No. The system is fully managed by us. You only use the Home Assistant app on your phone or a browser. If something happens, you'll get a simple notification in the app (e.g., "The kitchen sensor battery is low") and we'll handle the technical issues.
  
  ##### "How much does it cost?"
  That depends on your needs (how many sensors, which dongles). We work with affordable, refurbished hardware to keep the barrier low. Contact us for a no-obligation custom quote.
  
  ##### "What happens if the system breaks?"
  We have a backup of your system. If the mini-PC fails, we'll send you a replacement. You plug it in, and we'll restore everything from your backup. You'll barely notice a thing.
  
  ##### "Is it secure? I don't want strangers controlling my lights."
  Yes. Your system is secured in multiple ways:
  - Remote access uses encrypted connections (HTTPS).
  - We use strong passwords, stored in an encrypted vault.
  - The operating system base is 'hardened' according to the latest insights (Lynis score 80+).
  - Your data stays on your system; we only have access for management and backups.
  
  ##### "Why is that USB drive mandatory?"
  Because without a backup, we can't guarantee we can recover your data if something goes wrong. A simple SD card in a Raspberry Pi is asking for trouble. A proper USB drive (SSD) is the foundation of a reliable system. It's not optional—it's part of the solution.
  
  #### 🛠️ For (Beginning) Administrators & Tech Enthusiasts
  
  ##### "I want to be able to manage something like this too. Where do I start?"
  Glad you're interested! Our system is built to be maintainable by multiple people. You start by understanding the basics:
  - **Git:** To manage the code. ([See explanation](#))
  - **Docker:** Where all services run. ([See explanation](#))
  - **Ansible:** How we automate everything. ([See explanation](#))
  
  Read the `README.md` for the philosophy and setup. We're happy to teach you more if you want to help out long-term.
  
  ##### "How does that automatic hardware detection work?"
  That's one of the most powerful components. The `hardware_discovery` Ansible role scans at startup which USB devices (like Zigbee sticks or SDR receivers) are connected. Based on that, only the necessary software components are installed and configured. So you don't need to specify in advance which dongles are plugged in—the system discovers it automatically.
  
  ##### "How are notifications handled?"
  There are two separate systems:
  1. **For users:** Notifications from Home Assistant (e.g., "Kitchen light not responding").
  2. **For administrators:** Technical notifications via Gotify (e.g., "Client 14 SSD showing errors" or "Backup failed"). This way, we can fix problems before the user even notices.
  
  ##### "What does your backup strategy look like?"
  Each system makes an automated daily backup to the included USB drive. Additionally, an encrypted copy of the most important data is sent to a central location (or cloud). This is all managed via Ansible and the `rclone` role.
  
  ##### "I'd like to help manage things. What should I know?"
  You don't need to be an expert, but basic Linux knowledge and a willingness to learn are important. You'll start with simple tasks, like checking backups or answering initial user questions. From there, you can grow. The most important things are working carefully and asking questions when unsure.
  
  #### 💻 For Developers & Code-Interested People
  
  ##### "Where can I find the code?"
  The entire configuration is open source and available on GitHub: [https://github.com/henrydenhengst/homelab](https://github.com/henrydenhengst/homelab)
  
  ##### "Why Ansible and not just Docker Compose?"
  We use Ansible for the *setup* of the base system (the 'golden state' of the Linux server) and to start the Docker containers in a reproducible way. It ensures that every server, whether it's on our workbench or needs to be rebuilt after a year, is 100% identical. Docker Compose is used within Ansible to define the containers.
  
  ##### "How did you handle CGNAT?"
  We use DuckDNS for dynamic DNS and Caddy as a reverse proxy. For situations where port forwarding isn't possible (CGNAT), we've configured Caddy to use the DNS-01 challenge for SSL certificates, instead of the HTTP-01 challenge. This makes the system work even behind the most restrictive internet connections.
  
  ##### "How is security verified?"
  We use [Lynis](https://cisofy.com/lynis/) for security auditing and aim for a score of at least 80. Additionally, fail2ban is enabled by default to thwart brute-force attempts. The system base is continuously updated with the latest security patches via Ansible. Everyone is invited to inspect the code or perform a pentest; we're open to constructive feedback.
  
  ##### "Can I contribute to the code?"
  Absolutely! The project is open to contributions under the MIT license. Do you have an improvement for a role, a new way to detect hardware, or have you spotted a bug? Fork the repo, create a branch, and submit a Pull Request. For major changes, it's helpful to open an Issue first to discuss it.
  
  *This FAQ is continuously updated. Have a question that isn't listed? Feel free to ask!*

- Troubleshooting Matrix
  > Content coming soon...

- Port Reference
  > Content coming soon...

- Environment Variables Reference
  > Content coming soon...
