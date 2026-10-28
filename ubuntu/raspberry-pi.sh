#!/usr/bin/env bash
# Rebuilds the ARM64 ISO so a Raspberry Pi 3, 4 or 5 boots it from an SD card or USB stick.
# Ubuntu's generic kernel has no Pi drivers, so the Pi firmware starts Ubuntu's Pi kernel,
# like Ubuntu's own Pi images. UEFI computers still boot the generic kernel.
# Runs after `lb build`, see build.sh.
set -euo pipefail
cd "$(dirname "$0")/../_build"

apt-get install -y dosfstools mtools squashfs-tools xorriso

rm -rf pi
mkdir -p pi/debs pi/files pi/firmware pi/layer/usr/lib/modules

# Ubuntu's Pi kernel and firmware, from the archive the ISO uses.
mirror=http://ports.ubuntu.com/ubuntu-ports/
keyring=/usr/share/keyrings/ubuntu-archive-keyring.gpg
for suite in resolute resolute-updates resolute-security; do
  echo "deb [signed-by=$keyring] $mirror $suite main restricted universe multiverse"
done >pi/sources.list
apt=(-o Dir::Etc::SourceList="$PWD/pi/sources.list" -o Dir::Etc::SourceParts=/dev/null
  -o Dir::State::Lists="$PWD/pi/lists" -o Dir::Cache="$PWD/pi/cache" -o APT::Sandbox::User=root)
mkdir -p pi/lists/partial pi/cache/archives/partial
apt-get "${apt[@]}" update
image="$(apt-cache "${apt[@]}" depends linux-image-raspi | awk '$1 == "Depends:" && $2 ~ /^linux-image-.*-raspi$/ {print $2; exit}')"
version="${image#linux-image-}"
if [[ -z "$version" ]]; then
  echo "Couldn't find Ubuntu's Pi kernel" >&2
  exit 1
fi
(cd pi/debs && apt-get "${apt[@]}" download "$image" "linux-modules-$version" linux-firmware-raspi)

# Build its initramfs in the image, so it has the same live-boot scripts and hooks.
dpkg-deb -x "pi/debs/${image}_"*.deb chroot
dpkg-deb -x "pi/debs/linux-modules-${version}_"*.deb chroot
dpkg-deb -x pi/debs/linux-firmware-raspi_*.deb pi/firmware
mount --bind /dev chroot/dev
mount -t proc proc chroot/proc
mount -t sysfs sysfs chroot/sys
trap 'umount chroot/dev chroot/proc chroot/sys' EXIT
chroot chroot depmod "$version"
chroot chroot mkinitramfs -o "/boot/initrd.img-$version" "$version"

# The Pi kernel's modules and Wi-Fi firmware go in their own layer, which only the
# Pi mounts (module=raspi below). Installs copy filesystem.squashfs alone, without it.
mv "chroot/usr/lib/modules/$version" pi/layer/usr/lib/modules/
cp -a pi/firmware/usr/lib/firmware pi/layer/usr/lib/
mksquashfs pi/layer binary/live/raspi.squashfs -comp xz -b 1M -Xbcj arm64 -noappend
echo filesystem.squashfs >binary/live/filesystem.module
printf '%s\n' filesystem.squashfs raspi.squashfs >binary/live/raspi.module
for list in binary/*sum.txt; do
  tool="$(basename "$list" .txt)"
  (cd binary && "$tool" ./live/raspi.squashfs ./live/filesystem.module ./live/raspi.module) >>"$list"
done

# One FAT partition holds the EFI boot files and the Pi boot files.
efi=binary/boot/grub/efi.img
mcopy -s -m -i "$efi" '::*' pi/files/
boot=pi/firmware/usr/lib/linux-firmware-raspi
cp "$boot"/{bootcode.bin,start.elf,fixup.dat,start4.elf,fixup4.dat} pi/files/
cp "chroot/boot/vmlinuz-$version" pi/files/vmlinuz
cp "chroot/boot/initrd.img-$version" pi/files/initrd.img
# Broadcom's license must ship with its firmware.
cp pi/firmware/usr/share/doc/linux-firmware-raspi/copyright pi/files/LICENCE.broadcom
# The firmware picks the device tree for its model and applies the overlays.
dtbs="chroot/usr/lib/firmware/$version/device-tree"
cp "$dtbs"/broadcom/bcm27*.dtb pi/files/
cp -r "$dtbs/overlays" pi/files/
# Ubuntu's own Pi settings, from github.com/canonical/pi-gadget.
cat >pi/files/config.txt <<'EOF'
[all]
arm_64bit=1
kernel=vmlinuz
cmdline=cmdline.txt
initramfs initrd.img followkernel

dtparam=audio=on
dtparam=i2c_arm=on
dtparam=spi=on
dtparam=watchdog=on
disable_overscan=1
dtoverlay=vc4-kms-v3d
disable_fw_kms_setup=1
camera_auto_detect=1
display_auto_detect=1
dtoverlay=dwc2

[pi4]
max_framebuffers=2
arm_boost=1

# 512 MB boards run out of memory for the GPU with the default.
[pi3+]
dtoverlay=vc4-kms-v3d,cma-128

[pi02]
dtoverlay=vc4-kms-v3d,cma-128

[cm4]
dtoverlay=dwc2,dr_mode=host

[all]
EOF
# The same live options as the boot menu, plus the Pi kernel's layer.
# shellcheck disable=SC1091
bootappend="$(. config/binary && echo "$LB_BOOTAPPEND_LIVE")"
echo "$bootappend module=raspi" >pi/files/cmdline.txt

# The Pi firmware reads FAT16 and FAT32, not the FAT12 live-build uses.
size=$(($(du -sk pi/files | cut -f1) + 4096))
mkfs.fat -F 16 -n AMYOS_BOOT -C pi/boot.img "$size"
mcopy -s -m -i pi/boot.img pi/files/* ::/

# Rebuild the ISO with that FAT image as partition 1, so the Pi finds it.
# UEFI firmware keeps booting El Torito's efi.img: El Torito can't describe a boot
# image over 32 MB, and EDK2 then fails to read it. The GPT and Apple options
# would hide the MBR from the Pi 3.
command="$(cat binary/.disk/mkisofs)"
lb_efi='-e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat -isohybrid-apm-hfsplus'
if [[ "$command" != *"$lb_efi"* ]]; then
  echo "live-build's EFI options changed, update raspberry-pi.sh" >&2
  exit 1
fi
if (($(stat -c %s "$efi") >= 65536 * 512)); then
  echo "$efi is over 32 MB, too big for El Torito" >&2
  exit 1
fi
command="${command/"$lb_efi"/-e boot/grub/efi.img -no-emul-boot -append_partition 1 0x0c pi/boot.img}"
echo "$command" >binary/.disk/mkisofs
rm -f ./*.iso
eval "$command"
