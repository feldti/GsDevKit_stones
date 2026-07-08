#cloud-config
hostname: ${VM_NAME}
fqdn: ${VM_NAME}.local
package_update: true
package_upgrade: true

# Temporaeres Root-Passwort fuer Debugging (danach aendern!)
chpasswd:
  list: |
    root:TempPass123!
  expire: false

users:
  - name: pas
    gecos: Allgemeiner Benutzer zur Verwaltung der GemStone/S Anwendung
    groups: sudo
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    passwd: $6$GMWhV831t/TRbUcb$h456/wEvGlr2E3TpEuk/ChIlaItrlF8GXlEO3zB5690euK7PnHH3gIQgWJbiQXjP1LkvKA2F3OFohJBRlqlwE0
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5GzyIsgaUapbyzHj/pUeuYzGDDf+0wqIgCy6qIwvn1 m@feldtmann.online

packages:
  - subversion
  - git
  - curl
  - wget
  - ufw
  - qrencode
  - qemu-guest-agent
  - libpq-dev
  - librabbitmq-dev
  - openjdk-21-jre-headless
  - ansible
  - virtiofsd

runcmd:
  - sed -i 's/^# *\(de_DE.UTF-8 UTF-8\)/\1/' /etc/locale.gen
  - grep -q '^de_DE.UTF-8 UTF-8' /etc/locale.gen || echo 'de_DE.UTF-8 UTF-8' >> /etc/locale.gen
  - locale-gen
  - update-locale LANG=de_DE.UTF-8 LC_ALL=de_DE.UTF-8
  - systemctl enable --now qemu-guest-agent
  # VirtIO FS konfigurieren
  - mkdir -p /mnt/host_db_data
  - mount -t virtiofs db_data /mnt/host_db_data || true
  - echo "db_data /mnt/host_db_data virtiofs rw,nofail 0 0" >> /etc/fstab
  - mkdir -p /mnt/esv5
  - mount -t virtiofs esv5 /mnt/esv5 || true
  - echo "esv5 /mnt/esv5 virtiofs rw,nofail 0 0" >> /etc/fstab
  # Den Nutzer pas ls linger setzen
  - loginctl enable-linger pas
  # Firewall
  - ufw --force disable
  # Installationsskript holen und ausfuehren
  - su - pas -c "wget -O /home/pas/pas_install_env.sh https://feldtmann.ddns.net/pas-project/pas_install_env.sh"
  - su - pas -c "chmod +x /home/pas/pas_install_env.sh"
  - su - pas -c "cd /home/pas && ./pas_install_env.sh"
  # Installation von Zusatzpaketen
  - su - pas -c "git clone https://github.com/feldti/GemConnect-for-Postgres.git"
  - su - pas -c "git clone https://github.com/feldti/GemConnectForRabbitMQ.git"
  - su - pas -c "git clone https://github.com/feldti/PDFtalk-for-Gemstone.git"
  # Wir verlegen einige Strukturen in das shared filesystem: stones und lizenzen
  - su - pas -c "rmdir  /home/pas/pas/work/stones"
  - su - pas -c "rmdir  /home/pas/pas/work/licenses"
  - su - pas -c "mkdir /mnt/host_db_data/stones"
  - su - pas -c "mkdir /mnt/host_db_data/licenses"
  - su - pas -c "ln -s /mnt/host_db_data/stones /home/pas/pas/work/stones"
  - su - pas -c "ln -s /mnt/host_db_data/licenses /home/pas/pas/work/licenses"
  # Entwicklungsroutinen für .NetCore
  - |
    . /etc/os-release
    case "${ID}" in
      debian)
        wget https://packages.microsoft.com/config/debian/${VERSION_ID}/packages-microsoft-prod.deb -O /tmp/ms-prod.deb
        dpkg -i /tmp/ms-prod.deb
        ;;
      ubuntu)
        wget https://packages.microsoft.com/config/ubuntu/${VERSION_ID}/packages-microsoft-prod.deb -O /tmp/ms-prod.deb
        dpkg -i /tmp/ms-prod.deb
        ;;
      *)
        echo "Unbekannte Distribution: ${ID}"
        exit 1
        ;;
    esac
  - apt update
  - apt install -y aspnetcore-runtime-8.0
  - apt install -y aspnetcore-runtime-10.0

  # Shared Memory auf 2GB für die kleinen Lizenzen setzen
  - echo 'kernel.shmmax = 2147483648' >> /etc/sysctl.d/99-pas.conf
  - echo 'kernel.shmall = 524288' >> /etc/sysctl.d/99-pas.conf
  - sysctl -p


