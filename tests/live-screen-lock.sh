#!/bin/sh
# Run as root in a disposable Debian container with libkf6config-bin installed.
set -eu
repo=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
component=$repo/debian/live/config/includes.chroot_after_packages/usr/lib/live/config/1190-amyos-screen-lock
state=/var/lib/live/config/amyos-screen-lock
useradd --create-home user
useradd --create-home visitor
# Keep a separate installed-user skeleton and unrelated KDE preferences intact.
printf '[Daemon]\nAutolock=true\n' >/etc/skel/kscreenlockerrc
mkdir -p /home/visitor/.config
printf '[Other]\nKeep=example\n[Daemon]\nAutolock=true\nLockOnResume=true\n' >/home/visitor/.config/kscreenlockerrc

check_disabled() {
  test "$(kreadconfig6 --file "$1" --group Daemon --key Autolock)" = false
  test "$(kreadconfig6 --file "$1" --group Daemon --key LockOnResume)" = false
}
# The exported default is overridden by either supported kernel argument.
for argument in username=visitor live-config.username=visitor; do
  rm -f "$state"
  LIVE_USERNAME=user LIVE_CONFIG_CMDLINE="boot=live $argument" "$component"
  check_disabled /home/visitor/.config/kscreenlockerrc
  test ! -e /home/user/.config/kscreenlockerrc
  test "$(stat -c %U /home/visitor/.config/kscreenlockerrc)" = visitor
  test "$(kreadconfig6 --file /home/visitor/.config/kscreenlockerrc --group Other --key Keep)" = example
  test "$(kreadconfig6 --file /etc/skel/kscreenlockerrc --group Daemon --key Autolock)" = true
done
# Completed components must leave subsequent user changes alone.
kwriteconfig6 --file /home/visitor/.config/kscreenlockerrc --group Daemon --key Autolock true
LIVE_USERNAME=visitor "$component"
test "$(kreadconfig6 --file /home/visitor/.config/kscreenlockerrc --group Daemon --key Autolock)" = true
# No override: use live-config's default, and work on a fresh user directory.
rm -f "$state"
LIVE_USERNAME=user "$component"
check_disabled /home/user/.config/kscreenlockerrc
# A failed user setup must not record success.
rm -f "$state"
if LIVE_USERNAME=missing "$component"; then
  echo 'Missing live user unexpectedly succeeded' >&2
  exit 1
fi
test ! -e "$state"
echo 'Live screen-lock tests passed'
