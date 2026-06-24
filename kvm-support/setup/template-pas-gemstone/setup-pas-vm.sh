#!/bin/bash
# =============================================================================
# Setup-Skript: Debian 13 Trixie VM "pas-gemstone" auf KVM
# Host: Ubuntu 24.04, Bridge: br0, Storage: /datadisk/kvm
#
# Alle vier Dateien müssen im selben Verzeichnis liegen,
# empfohlen: /datadisk/kvm/setup/
#
#   setup-pas-vm.sh    ← dieses Skript
#   pas-gemstone.xml   ← libvirt VM-Definition
#   user-data          ← cloud-init Benutzerkonfiguration
#   meta-data          ← cloud-init Instanz-Metadaten
#
# Aufruf: sudo bash /datadisk/kvm/setup/setup-pas-vm.sh
# =============================================================================
set -euo pipefail

# --- Konfiguration -----------------------------------------------------------
VM_NAME="pas-gemstone"
BASE_DIR="/datadisk/kvm"
BASE_IMAGE_URL="https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
BASE_IMAGE="${BASE_DIR}/bases/debian-13-genericcloud-amd64.qcow2"
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
    wget -O "${BASE_IMAGE}.SHA512SUMS" \
        "https://cloud.debian.org/images/cloud/trixie/latest/SHA512SUMS"
    echo ">>> Prüfsumme verifizieren..."
    grep "$(basename "${BASE_IMAGE}")" "${BASE_IMAGE}.SHA512SUMS" | \
        sha512sum -c --ignore-missing
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
    echo "    (Zum Neudefinieren: virsh undefine ${VM_NAME} --nvram)"
else
    echo ">>> VM XML definieren..."
    virsh define "${VM_XML}"
fi

echo ""
echo "=== Fertig! ==="
echo ""
echo "VM starten:         virsh start ${VM_NAME}"
echo "Konsole:            virsh console ${VM_NAME}"
echo "IP ermitteln:       virsh domifaddr ${VM_NAME}"
echo ""
echo "Seed-ISO nach erstem Boot entfernen:"
echo "  virsh change-media ${VM_NAME} sda --eject --config"
