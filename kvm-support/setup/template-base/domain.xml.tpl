<domain type='kvm'>
  <name>${VM_NAME}</name>
  <uuid><!-- wird von libvirt automatisch generiert, wenn leer gelassen --></uuid>
  <seclabel type="none"/>
  <description>Debian 13 Trixie – GemStone/S Anwendungsserver für Wahlsysteme und Dashboards</description>
  <memory unit='KiB'>${VM_MEMORY_KIB}</memory>
  <currentMemory unit='KiB'>${VM_MEMORY_KIB}</currentMemory>
  <vcpu placement='static'>${VM_VCPUS}</vcpu>
  <memoryBacking>
    <source type="memfd"/>
    <access mode="shared"/>
  </memoryBacking>

  <os>
    <type arch='x86_64' machine='q35'>hvm</type>
    <boot dev='hd'/>
  </os>

  <features>
    <acpi/>
    <apic/>
  </features>

  <cpu mode='host-passthrough' check='none'/>

  <clock offset="utc">
    <timer name="rtc" tickpolicy="catchup"/>
    <timer name="pit" tickpolicy="delay"/>
    <timer name="hpet" present="no"/>
  </clock>

  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>destroy</on_crash>

  <pm>
    <suspend-to-mem enabled="no"/>
    <suspend-to-disk enabled="no"/>
  </pm>

  <devices>
    <emulator>/usr/bin/qemu-system-x86_64</emulator>

    <!-- ==================================================================
         Disk 1: VM-Hauptdisk (CoW-Clone vom Trixie Basis-Image)
         ================================================================== -->
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2' discard="unmap"/>
      <source file='${DISK_PATH}'/>
      <target dev='vda' bus='virtio'/>
    </disk>

    <!-- ==================================================================
         Disk 2: cloud-init Seed-ISO
         Nach erstem Boot entfernen:
           virsh change-media esystem sda -eject -config
         ================================================================== -->
    <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <source file='${SEED_PATH}'/>
      <target dev='sda' bus='sata'/>
      <readonly/>
    </disk>

    <!-- Optional: virtiofs Share, falls nicht benoetigt diesen Block entfernen -->
    <filesystem type='mount' accessmode='passthrough'>
      <driver type='virtiofs' queue="1024"/>
      <source dir='${SHARED_DIR}'/>
      <target dir='db_data'/>
    </filesystem>

    <!-- ==================================================================
    virtiofs: Freigegebenes Verzeichnis für Wahlsystem-Daten (Wahltags, Dispatcher, DDXML-Dispatcher)
    ================================================================== -->
    <filesystem type="mount" accessmode="passthrough">
      <driver type="virtiofs" queue="1024"/>
      <source dir="/var/esv5/"/>
      <target dir="esv5"/>
    </filesystem>

    <interface type='network'>
      <source network='${VM_NETWORK}'/>
      <model type='virtio'/>
    </interface>

    <!-- Serielle Konsole für virsh console -->
    <serial type="pty">
      <target type="isa-serial" port="0">
        <model name="isa-serial"/>
      </target>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>

    <!-- QEMU Guest Agent (für virsh domifaddr, shutdown, etc.) -->
    <channel type="unix">
      <target type="virtio" name="org.qemu.guest_agent.0"/>
      <address type="virtio-serial" controller="0" bus="0" port="1"/>
    </channel>

    <!-- SATA Controller (für Seed-ISO) -->
    <controller type="sata" index="0">
    </controller>

    <graphics type="spice" autoport="yes" listen="127.0.0.1">
      <listen type="address" address="127.0.0.1"/>
    </graphics>

    <!-- Kein Display / keine Grafik (Server-VM) -->
    <video>
      <model type="vga" vram="16384" heads="1"/>
    </video>

    <memballoon model='virtio'/>

    <rng model='virtio'>
      <backend model='random'>/dev/urandom</backend>
    </rng>
  </devices>

</domain>
