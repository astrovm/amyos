#!/usr/bin/env bash
# Rebuilds the ARM64 ISO so a Raspberry Pi 3 or 4 boots it from an SD card or USB stick.
# The Pi firmware starts U-Boot, which loads the same EFI boot loader UEFI computers use.
# Runs after kiwi, see build-iso.sh. Usage: raspberry-pi.sh <ISO>
set -euo pipefail
iso="$(realpath "$1")"
cd "$(dirname "$0")/../_build"

dnf -y install dosfstools mtools xorriso

rm -rf pi
mkdir -p pi/rpms pi/root pi/files pi/boot-images
# The same firmware, device trees and U-Boot as Fedora's own Pi images.
dnf download --destdir pi/rpms bcm283x-firmware bcm283x-overlays bcm2835-firmware \
  bcm2711-firmware bcm2712-firmware uboot-images-armv8
for rpm in pi/rpms/*.rpm; do rpm2archive - <"$rpm" | tar -xz -C pi/root; done

# One FAT partition holds the EFI boot files and the Pi boot files.
xorriso -osirrox on -indev "$iso" -extract_boot_images pi/boot-images/
mcopy -s -m -i pi/boot-images/eltorito_img1_uefi.img '::*' pi/files/
# Fedora's config.txt starts rpi-u-boot.bin and loads the firmware's device trees
# with the overlays that make them work with Fedora's kernel.
cp -a pi/root/boot/efi/. pi/files/
cp pi/root/usr/share/uboot/rpi_arm64/u-boot.bin pi/files/rpi-u-boot.bin
grep -qx 'kernel=rpi-u-boot.bin' pi/files/config.txt
# Broadcom's license must ship with its firmware.
cp pi/root/usr/share/licenses/bcm283x-firmware/LICENCE.broadcom pi/files/

# The Pi firmware reads FAT16 and FAT32.
size=$(($(du -sk pi/files | cut -f1) + 4096))
mkfs.fat -F 16 -n AMYOS_BOOT -C pi/boot.img "$size"
mcopy -s -m -i pi/boot.img pi/files/* ::/

# Replace kiwi's GPT with an MBR, since the Pi 3 only reads MBR: partition 1 is that
# FAT image, partition 2 kiwi's EFI image. UEFI firmware boots the EFI image through
# El Torito, which can't describe a boot image over 32 MB like the Pi's.
efi=pi/boot-images/eltorito_img1_uefi.img
if (($(stat -c %s "$efi") >= 65536 * 512)); then
  echo "kiwi's EFI image is over 32 MB, too big for El Torito" >&2
  exit 1
fi
xorriso -indev "$iso" -outdev pi/amyos.iso \
  -boot_image any discard \
  -append_partition 1 0x0c pi/boot.img \
  -append_partition 2 0xef "$efi" \
  -boot_image any efi_path=--interval:appended_partition_2:all:: \
  -boot_image any cat_hidden=on
mv pi/amyos.iso "$iso"
