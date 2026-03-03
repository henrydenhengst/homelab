# Verwijder de mogelijk corrupte bestanden
rm -f ~/git/homelab/roles/docker/tasks/main.yml
rm -f ~/git/homelab/roles/docker/tasks/network.yml

# Maak main.yml opnieuw aan (STRICT)
printf -- "---\n- name: Importeer installatie\n  import_tasks: install.yml\n\n- name: Importeer netwerk\n  import_tasks: network.yml\n" > ~/git/homelab/roles/docker/tasks/main.yml

# Maak network.yml opnieuw aan (STRICT)
printf -- "---\n- name: Maak docker netwerk\n  docker_network:\n    name: \"{{ docker_network_name }}\"\n    driver: bridge\n" > ~/git/homelab/roles/docker/tasks/network.yml
