#!/bin/bash
# =============================================================================
# Setup-Skript: KVM VM auf Basis von Debian 13 Trixie oder Ubuntu 24.04
# Host: Ubuntu 24.04, Storage: /datadisk/kvm
#
# Alle vier Dateien müssen im selben Verzeichnis liegen,
# empfohlen: /datadisk/kvm/setup/
#
#   setup-pas-vm.sh    ← dieses Skript
#   pas-gemstone.xml   ← libvirt VM-Definition
#   user-data          ← cloud-init Benutzerkonfiguration
#   meta-data          ← cloud-init Instanz-Metadaten
#
# Aufruf:
#   sudo bash setup-pas-vm.sh                    # Standard: Debian Trixie
#   sudo bash setup-pas-vm.sh --distro debian    # Debian 13 Trixie
#   sudo bash setup-pas-vm.sh --distro ubuntu    # Ubuntu 24.04 Noble
# =============================================================================
set -euo pipefail

# --- Parameter parsen --------------------------------------------------------
DISTRO="debian"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --distro)
            DISTRO="$2"
            shift 2
            ;;
        *)
            echo "Unbekannter Parameter: $1"
            echo "Verwendung: $0 [--distro debian|ubuntu]"
            exit 1
            ;;
    esac
done

# --- Distro-spezifische Konfiguration ----------------------------------------
case "${DISTRO}" in
    debian)
        BASE_IMAGE_URL="https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
        BASE_IMAGE_NAME="debian-13-genericcloud-amd64.qcow2"
        CHECKSUM_URL="https://cloud.debian.org/images/cloud/trixie/latest/SHA512SUMS"
        CHECKSUM_CMD="sha512sum"
        echo ">>> Distro: Debian 13 Trixie"
        ;;
    ubuntu)
        BASE_IMAGE_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
        BASE_IMAGE_NAME="ubuntu-24.04-cloudimg-amd64.img"
        CHECKSUM_URL="https://cloud-images.ubuntu.com/noble/current/SHA256SUMS"
        CHECKSUM_CMD="sha256sum"
        echo ">>> Distro: Ubuntu 24.04 Noble"
        ;;
    *)
        echo "FEHLER: Unbekannte Distro '${DISTRO}' — erlaubt: debian, ubuntu"
        exit 1
        ;;
esac

# --- Allgemeine Konfiguration ------------------------------------------------
VM_NAME="pas-gemstone"
BASE_DIR="/datadisk/kvm"
BASE_IMAGE="${BASE_DIR}/bases/${BASE_IMAGE_NAME}"
VM_DISK="${BASE_DIR}/vms/${VM_NAME}/disk.qcow2"
VM_DISK_SIZE="20G"
SEED_ISO="${BASE_DIR}/seeds/${VM_NAME}/seed.iso"
SHARED_DIR="${BASE_DIR}/shared/db_data"
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
USER_DATA="${SCRIPT_DIR}/user-data"
META_DATA="${SCRIPT_DIR}/meta-data"
VM_XML="${SCRIPT_DIR}/pas-gemstone.xml"

# --- Voraussetzungen prüfen --------------------------------------------------
echo ">>> Prüfe benötigte Dateien in: ${SCRIPT_DIR}"
MISSING=0
for f in "${USER_DATA}" "${META_DATA}" "${VM_XML}"; do
    if [[ ! -f "$f" ]]; then
        echo "    FEHLT: $f"
        MISSING=1
    else
        echo "    OK:    $f"
    fi
done
if [[ "${MISSING}" -eq 1 ]]; then
    echo ""
    echo "FEHLER: Fehlende Dateien — bitte alle vier Dateien in dasselbe"
    echo "        Verzeichnis legen und Skript erneut starten."
    echo "        Empfohlen: /datadisk/kvm/setup/"
    exit 1
fi

# --- Verzeichnisse anlegen ---------------------------------------------------
echo ">>> Verzeichnisstruktur anlegen..."
mkdir -p "${BASE_DIR}/bases"
mkdir -p "${BASE_DIR}/vms/${VM_NAME}"
mkdir -p "${BASE_DIR}/seeds/${VM_NAME}"
mkdir -p "${SHARED_DIR}"

# --- Basis-Image herunterladen (falls nicht vorhanden) -----------------------
if [[ ! -f "${BASE_IMAGE}" ]]; then
    echo ">>> Basis-Image herunterladen..."
    wget -O "${BASE_IMAGE}" "${BASE_IMAGE_URL}"
    wget -O "${BASE_IMAGE}.SUMS" "${CHECKSUM_URL}"
    echo ">>> Prüfsumme verifizieren..."
    # Prüfsumme extrahieren — funktioniert für beide Formate:
    # Debian: "abc123  dateiname"
    # Ubuntu: "abc123 *dateiname" (Sternchen vor Dateiname)
    CHECKSUM=$(grep "$(basename "${BASE_IMAGE}")" "${BASE_IMAGE}.SUMS" | awk '{print $1}')
    if [[ -z "${CHECKSUM}" ]]; then
        echo "FEHLER: Keine Prüfsumme für $(basename "${BASE_IMAGE}") gefunden"
        exit 1
    fi
    echo "${CHECKSUM}  ${BASE_IMAGE}" | ${CHECKSUM_CMD} -c
    chmod 444 "${BASE_IMAGE}"
    echo ">>> Basis-Image OK."
else
    echo ">>> Basis-Image bereits vorhanden, überspringe Download."
fi

# --- Laufende VM prüfen ------------------------------------------------------
if virsh list --state-running --name 2>/dev/null | grep -q "^${VM_NAME}$"; then
    echo "FEHLER: VM '${VM_NAME}' läuft gerade — bitte zuerst stoppen:"
    echo "       virsh shutdown ${VM_NAME}"
    exit 1
fi

# --- VM-Disk als CoW-Clone anlegen -------------------------------------------
if [[ -f "${VM_DISK}" ]]; then
    echo ">>> VM-Disk existiert bereits, überspringe Anlage: ${VM_DISK}"
else
    echo ">>> VM-Disk als Copy-on-Write Clone anlegen (${VM_DISK_SIZE})..."
    qemu-img create \
        -f qcow2 \
        -b "${BASE_IMAGE}" \
        -F qcow2 \
        "${VM_DISK}" \
        "${VM_DISK_SIZE}"
fi

# --- cloud-init Seed-ISO erstellen -------------------------------------------
if [[ -f "${SEED_ISO}" ]]; then
    echo ">>> Seed-ISO existiert bereits, überspringe Erstellung: ${SEED_ISO}"
    echo "    (Zum Neuerstellen: rm ${SEED_ISO} und Skript erneut ausführen)"
else
    echo ">>> cloud-init Seed-ISO erstellen..."
    cloud-localds "${SEED_ISO}" "${USER_DATA}" "${META_DATA}"
fi

# --- VM in libvirt definieren ------------------------------------------------
if virsh dominfo "${VM_NAME}" &>/dev/null; then
    echo ">>> VM '${VM_NAME}' bereits in libvirt definiert, überspringe 'virsh define'."
    echo "    (Zum Neudefinieren: virsh undefine ${VM_NAME})"
else
    echo ">>> VM XML definieren..."
    virsh define "${VM_XML}"
fi

echo ""
echo "=== Fertig! ==="
echo ""
echo "Distro:             ${DISTRO}"
echo "Basis-Image:        ${BASE_IMAGE}"
echo "VM starten:         virsh start ${VM_NAME}"
echo "Konsole:            virsh console ${VM_NAME}"
echo "IP ermitteln:       virsh domifaddr ${VM_NAME}"
echo ""
echo "Seed-ISO nach erstem Boot entfernen:"
echo "  virsh change-media ${VM_NAME} sda --eject --config"
