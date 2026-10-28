#!/usr/bin/bash
# Runs inside the live image once kiwi has installed its packages, see build-iso.sh.
set -euxo pipefail

# build-iso.sh copies the repo's branding and Fedora scripts here.
/root/amyos/fedora/customize.sh /root/amyos
rm -rf /root/amyos

# livesys creates the live user and logs it into Plasma.
echo 'livesys_session="kde"' >/etc/sysconfig/livesys

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
