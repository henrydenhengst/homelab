---
- name: "Maak Debian 12 Bootable USB"
  hosts: localhost
  connection: local
  become: false
  vars:
    # Debian 12 specifieke variabelen
    debian_version: "12.9.0"
    iso_name: "debian-{{ debian_version }}-amd64-netinst.iso"
    iso_url: "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/{{ iso_name }}"
    sums_url: "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS"
    download_dir: "{{ ansible_env.HOME }}/Downloads"
    
    # DOELAPPARAAT: Pas dit aan naar jouw USB-stick (bijv. /dev/sdb)
    # Gebruik 'lsblk' om de juiste schijf te vinden!
    target_device: "/dev/sdX"

  tasks:
    - name: "Check of het doelapparaat {{ target_device }} bestaat"
      ansible.builtin.stat:
        path: "{{ target_device }}"
      register: device_stat

    - name: "Stop als het apparaat niet bestaat of geen block device is"
      ansible.builtin.fail:
        msg: "FOUT: {{ target_device }} is geen geldig apparaat!"
      when: not device_stat.stat.exists or not device_stat.stat.isblk

    - name: "Download Debian 12 ISO"
      ansible.builtin.get_url:
        url: "{{ iso_url }}"
        dest: "{{ download_dir }}/{{ iso_name }}"
        checksum: "sha256:{{ sums_url }}"
        mode: '0644'
      register: download_iso

    - name: "Bevestiging vragen voor wissen van {{ target_device }}"
      ansible.builtin.pause:
        prompt: "WAARSCHUWING: Alle data op {{ target_device }} wordt gewist! Typ 'JA' om door te gaan"
      register: user_confirmation

    - name: "Breek af als bevestiging niet 'JA' is"
      ansible.builtin.fail:
        msg: "Actie geannuleerd door gebruiker."
      when: user_confirmation.user_input != "JA"

    - name: "Schrijf ISO naar USB-stick (dd)"
      become: true
      ansible.builtin.command:
        cmd: "dd if={{ download_dir }}/{{ iso_name }} of={{ target_device }} bs=4M status=progress conv=fsync"
      register: dd_result
      changed_when: true

    - name: "Resultaat"
      ansible.builtin.debug:
        msg: "✅ Debian 12 installatiestick op {{ target_device }} is gereed!"
