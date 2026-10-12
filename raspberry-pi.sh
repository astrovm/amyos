#!/usr/bin/env bash
# Rebuilds the ARM64 ISO so a Raspberry Pi 3, 4 or 5 boots it from an SD card or USB stick.
# The Pi firmware starts U-Boot, which loads the same EFI boot loader UEFI computers use.
# Runs after `lb build`, see build.sh.
set -euo pipefail
cd "$(dirname "$0")/_build"

# raspi-firmware is in non-free-firmware.
sed -i 's/^Components: main$/Components: main non-free-firmware/' /etc/apt/sources.list.d/debian.sources
apt-get update
apt-get install -y dosfstools mtools xorriso

rm -rf pi
mkdir -p pi/debs pi/files
(cd pi/debs && apt-get download raspi-firmware u-boot-rpi)
for deb in pi/debs/*.deb; do dpkg-deb -x "$deb" pi/root; done

# One FAT partition holds the EFI boot files and the Pi boot files.
efi=binary/boot/grub/efi.img
mcopy -s -m -i "$efi" '::*' pi/files/
firmware=pi/root/usr/lib/raspi-firmware
cp "$firmware"/{bootcode.bin,start.elf,fixup.dat,start4.elf,fixup4.dat} pi/files/
cp pi/root/usr/lib/u-boot/rpi_arm64/u-boot.bin pi/files/
# Broadcom's license must ship with its firmware.
cp pi/root/usr/share/doc/raspi-firmware/copyright pi/files/LICENCE.broadcom
# The firmware picks the device tree for its model; upstream_kernel selects these names.
kernel="$(find chroot/usr/lib/modules -mindepth 1 -maxdepth 1 -printf '%f\n' | sort -V | tail -n 1)"
mapfile -t dtbs < <(find "chroot/usr/lib/modules/$kernel" -path '*/broadcom/bcm2*-rpi-*.dtb')
if ((${#dtbs[@]} == 0)); then
  echo "No Raspberry Pi device trees in the kernel package" >&2
  exit 1
fi
cp "${dtbs[@]}" pi/files/
# U-Boot's serial console needs enable_uart on the Pi 3.
cat >pi/files/config.txt <<'EOF'
arm_64bit=1
upstream_kernel=1
enable_uart=1
kernel=u-boot.bin
EOF

# The Pi firmware reads FAT16 and FAT32, not the FAT12 live-build uses.
size=$(($(du -sk pi/files | cut -f1) + 4096))
mkfs.fat -F 16 -n AMYOS_BOOT -C pi/boot.img "$size"
mcopy -s -m -i pi/boot.img pi/files/* ::/

# Rebuild the ISO with that FAT image as partition 1, so the Pi finds it.
# The EFI El Torito entry points at the same partition, so it isn't stored twice.
command="$(cat binary/.disk/mkisofs)"
lb_efi='-e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat -isohybrid-apm-hfsplus'
if [[ "$command" != *"$lb_efi"* ]]; then
  echo "live-build's EFI options changed, update raspberry-pi.sh" >&2
  exit 1
fi
command="${command/"$lb_efi"/-append_partition 1 0x0c pi/boot.img -e --interval:appended_partition_1:all:: -no-emul-boot}"
rm "$efi"
sed -i '\|  \./boot/grub/efi\.img$|d' binary/*sum.txt
if grep -q 'boot/grub/efi\.img' binary/*sum.txt; then
  echo "Couldn't drop efi.img from the checksum list" >&2
  exit 1
fi
echo "$command" >binary/.disk/mkisofs
rm -f ./*.iso
eval "$command"
