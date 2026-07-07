#!/bin/bash
# =============================================================================
# create-vm.sh - Erzeugt eine neue VM aus dem Debian-Trixie-Cloud-Template
#
# Nutzt EIN Set von Templates (user-data.tpl, meta-data.tpl, domain.xml.tpl)
# im selben Verzeichnis wie dieses Skript, um beliebig viele, unabhaengige
# VMs zu erstellen. Jede VM bekommt ihr eigenes Verzeichnis mit generierten
# Dateien - die Templates selbst bleiben unveraendert.
#
# Aufruf:
#   sudo bash create-vm.sh <vm-name> [Optionen]
#
# Optionen:
#   --distro NAME     Distribution        (Default: debian-13)
#                      verfuegbar: debian-13, ubuntu-24, ubuntu-22,ubuntu-26
#   --memory MB       RAM in MiB          (Default: 4096)
#   --vcpus N         Anzahl vCPUs        (Default: 2)
#   --disk-size GB    Groesse der Disk    (Default: 20)
#   --network NAME    libvirt-Netzwerk    (Default: default)
#   --mac MAC         Feste MAC-Adresse   (Default: automatisch generiert)
#
# Beispiel:
#   sudo bash create-vm.sh gemstone-test2 --memory 8192 --vcpus 4
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

DISTRO="debian-13"
BASE_DIR="/datadisk/kvm"
VMS_ROOT="${BASE_DIR}/vms"
SEEDS_ROOT="${BASE_DIR}/seeds"


# --- Defaults ----------------------------------------------------------------
VM_MEMORY_MB=4096
VM_VCPUS=4
DISK_SIZE_GB=20
VM_NETWORK="default"
VM_MAC=""

# --- Argumente parsen ----------------------------------------------------------
if [ $# -lt 1 ]; then
    echo "Nutzung: $0 <vm-name> [--distro debian-13|ubuntu-22|ubuntu-24|ubuntu-26] [--memory MB] [--vcpus N] [--disk-size GB] [--network NAME] [--mac MAC]"
    exit 1
fi

VM_NAME="$1"
shift

SEED_ISO="${BASE_DIR}/seeds/${VM_NAME}/seed.iso"
SHARED_DIR="${BASE_DIR}/shared/${VM_NAME}"
VM_DIR="${VMS_ROOT}/${VM_NAME}"
SEED_DIR="${SEEDS_ROOT}/${VM_NAME}"

while [ $# -gt 0 ]; do
    case "$1" in
        --distro)     DISTRO="$2"; shift 2 ;;
        --memory)     VM_MEMORY_MB="$2"; shift 2 ;;
        --vcpus)      VM_VCPUS="$2"; shift 2 ;;
        --disk-size)  DISK_SIZE_GB="$2"; shift 2 ;;
        --network)    VM_NETWORK="$2"; shift 2 ;;
        --mac)        VM_MAC="$2"; shift 2 ;;
        *) echo "Unbekannte Option: $1"; exit 1 ;;
    esac
done

case "${DISTRO}" in
    debian|debian-13)
        BASE_IMAGE_URL="https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
        BASE_IMAGE_NAME="debian-13-genericcloud-amd64.qcow2"
        CHECKSUM_URL="https://cloud.debian.org/images/cloud/trixie/latest/SHA512SUMS"
        CHECKSUM_CMD="sha512sum"
        echo ">>> Distro: Debian 13 Trixie"
        ;;
    ubuntu|ubuntu-24|ubuntu-24.04)
        BASE_IMAGE_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
        BASE_IMAGE_NAME="ubuntu-24.04-cloudimg-amd64.img"
        CHECKSUM_URL="https://cloud-images.ubuntu.com/noble/current/SHA256SUMS"
        CHECKSUM_CMD="sha256sum"
        echo ">>> Distro: Ubuntu 24.04 Noble"
        ;;
    ubuntu-22|ubuntu-22.04)
        BASE_IMAGE_URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
        BASE_IMAGE_NAME="ubuntu-22.04-cloudimg-amd64.img"
        CHECKSUM_URL="https://cloud-images.ubuntu.com/jammy/current/SHA256SUMS"
        CHECKSUM_CMD="sha256sum"
        echo ">>> Distro: Ubuntu 22.04 Jammy"
        ;;
    ubuntu-26|ubuntu-26.04)
        BASE_IMAGE_URL="https://cloud-images.ubuntu.com/resolute/current/resolute-server-cloudimg-amd64.img"
        BASE_IMAGE_NAME="ubuntu-26.04-cloudimg-amd64.img"
        CHECKSUM_URL="https://cloud-images.ubuntu.com/resolute/current/SHA256SUMS"
        CHECKSUM_CMD="sha256sum"
        echo ">>> Distro: Ubuntu 26.04 Resolute Raccoon"
        ;;
    *)
        echo "FEHLER: Unbekannte Distro '${DISTRO}' — erlaubt: debian-13, ubuntu-22, ubuntu-24, ubuntu-26"
        exit 1
        ;;
esac
BASE_IMAGE="${BASE_DIR}/bases/${BASE_IMAGE_NAME}"


VM_MEMORY_KIB=$((VM_MEMORY_MB * 1024))

# --- Voraussetzungen pruefen ---------------------------------------------------
echo ">>> Pruefe Templates in: ${SCRIPT_DIR}"
for f in user-data.tpl meta-data.tpl domain.xml.tpl; do
    if [ ! -f "${SCRIPT_DIR}/${f}" ]; then
        echo "FEHLER: Template fehlt: ${SCRIPT_DIR}/${f}"
        exit 1
    fi
    echo "    OK: ${f}"
done

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

if virsh dominfo "${VM_NAME}" &>/dev/null; then
    echo "FEHLER: Eine VM namens '${VM_NAME}' existiert in libvirt bereits."
    echo "        Anderen Namen waehlen oder vorher 'virsh undefine ${VM_NAME} --nvram' ausfuehren."
    exit 1
fi

# --- Verzeichnisse anlegen ------------------------------------------------------

echo ">>> Lege Verzeichnisse an..."
mkdir -p "$VM_DIR" "$SEED_DIR" "$SHARED_DIR"

DISK_PATH="${VM_DIR}/${VM_NAME}.qcow2"
SEED_PATH="${SEED_DIR}/seed.iso"
INSTANCE_ID="${VM_NAME}-$(date +%s)"

if [ -z "$VM_MAC" ]; then
    # Locally administered, unicast: erstes Oktett 52 (QEMU-Konvention)
    VM_MAC=$(printf '52:54:00:%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
fi

echo ">>> VM-Parameter:"
echo "    Name:        ${VM_NAME}"
echo "    RAM:         ${VM_MEMORY_MB} MB"
echo "    vCPUs:       ${VM_VCPUS}"
echo "    MAC:         ${VM_MAC}"
echo "    Netzwerk:    ${VM_NETWORK}"
echo "    Shared-Dir:  ${SHARED_DIR}"
echo "    Disk:        ${DISK_PATH}"

# --- Templates rendern (nur definierte Variablen ersetzen) ----------------------
echo ">>> Rendere Templates fuer ${VM_NAME}..."
export VM_NAME VM_MEMORY_KIB VM_VCPUS VM_MAC VM_NETWORK SHARED_DIR \
       DISK_PATH SEED_PATH INSTANCE_ID

VARS='${VM_NAME} ${VM_MEMORY_KIB} ${VM_VCPUS} ${VM_MAC} ${VM_NETWORK} ${SHARED_DIR} ${DISK_PATH} ${SEED_PATH} ${INSTANCE_ID}'

envsubst "$VARS" < "${SCRIPT_DIR}/user-data.tpl"   > "${SEED_DIR}/user-data"
envsubst "$VARS" < "${SCRIPT_DIR}/meta-data.tpl"   > "${SEED_DIR}/meta-data"
envsubst "$VARS" < "${SCRIPT_DIR}/domain.xml.tpl"  > "${VM_DIR}/${VM_NAME}.xml"

# --- Disk als CoW-Klon vom Basis-Image ------------------------------------------
if [ -f "$DISK_PATH" ]; then
    echo ">>> Disk existiert bereits, ueberspringe: ${DISK_PATH}"
else
    echo ">>> Erzeuge Disk (Backing-File: Basis-Image)..."
    qemu-img create -f qcow2 -F qcow2 -b "$BASE_IMAGE" "$DISK_PATH" "${DISK_SIZE_GB}G"
fi

# --- Seed-ISO erzeugen -----------------------------------------------------------
echo ">>> Erzeuge Seed-ISO..."
cloud-localds "$SEED_PATH" "${SEED_DIR}/user-data" "${SEED_DIR}/meta-data"

# --- VM in libvirt definieren ------------------------------------------------------
echo ">>> Definiere VM in libvirt..."
virsh define "${VM_DIR}/${VM_NAME}.xml"

echo ""
echo "=== Fertig: ${VM_NAME} ==="
echo ""
echo "VM starten:      virsh start ${VM_NAME}"
echo "Konsole:         virsh console ${VM_NAME}"
echo "IP ermitteln:    virsh domifaddr ${VM_NAME}"
echo ""
echo "Seed-ISO nach erstem Boot entfernen:"
echo "  virsh change-media ${VM_NAME} sda --eject --config"
