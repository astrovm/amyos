#!/usr/bin/bash
# Runs inside the live image once kiwi has installed its packages, see build-iso.sh.
set -euxo pipefail

# build-iso.sh copies the repo's branding and Fedora scripts here.
/root/amyos/fedora/customize.sh /root/amyos
rm -rf /root/amyos

# livesys creates the live user and logs it into Plasma.
echo 'livesys_session="kde"' >/etc/sysconfig/livesys

# Without these the installer doesn't open or fails at the end, see config.kiwi.
rpm -q slitherer efibootmgr cryptsetup glibc-all-langpacks

# livesys puts this on the desktop. Its icon comes from fedora-logos, which
# Amy OS leaves out, so use the Amy OS name and logo like the Debian ISO.
desktop=/usr/share/applications/liveinst.desktop
sed -i -e 's/^Name=.*/Name=Install Amy OS/' -e 's/^Icon=.*/Icon=amyos/' "$desktop"
grep -qx 'Icon=amyos' "$desktop"

# Fedora's release package replaces os-release on updates. Bring the Amy OS name
# back when that happens and at boot. bootc images get it when they're built.
cat >/usr/lib/systemd/system/amyos-os-release.service <<'UNIT'
[Unit]
Description=Show the Amy OS name in os-release

[Service]
Type=oneshot
ExecStart=/usr/lib/amyos/update-os-release

[Install]
WantedBy=multi-user.target
UNIT
cat >/usr/lib/systemd/system/amyos-os-release.path <<'UNIT'
[Unit]
Description=Show the Amy OS name in os-release after updates

[Path]
PathChanged=/usr/lib/os-release

[Install]
WantedBy=paths.target
UNIT
systemctl enable amyos-os-release.service amyos-os-release.path

# Like Fedora's live images: each boot and install gets its own machine ID,
# root has no password, and GRUB matches what Anaconda sets up.
rm -f /etc/machine-id /var/lib/systemd/random-seed
echo uninitialized >/etc/machine-id
passwd -d root
passwd -l root
cat >>/etc/default/grub <<'CONF'
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_DISABLE_RECOVERY=true
CONF
