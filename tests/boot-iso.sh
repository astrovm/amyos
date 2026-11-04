#!/usr/bin/env bash
# Boots a live ISO in a VM and fails unless Plasma starts and stays up, without crashes.
# It boots the ISO's first GRUB menu entry, loading the kernel directly so the VM gets a
# root shell on a serial port. That skips GRUB itself and Secure Boot.
# Runs as root in a Debian container, see `just test-iso`. Leaves logs in _build/boot-test.
# Usage: boot-iso.sh <AMD64 ISO>
set -euo pipefail
iso="$(realpath "$1")"
limit=300
stable=30
logs="$PWD/_build/boot-test"

apt-get update -qq
apt-get install -y -qq --no-install-recommends qemu-system-x86 seabios xorriso >/dev/null

rm -rf "$logs"
mkdir -p "$logs"
work="$(mktemp -d)"
cleanup() {
  [[ -z "${qemu_pid:-}" ]] || kill "$qemu_pid" 2>/dev/null || true
  [[ -z "${reader_pid:-}" ]] || kill "$reader_pid" 2>/dev/null || true
  rm -rf "$work"
}
trap cleanup EXIT

extract() { xorriso -osirrox on -indev "$iso" -extract "$1" "$2" 2>/dev/null; }
extract /boot/grub2/grub.cfg "$work/grub.cfg" || extract /boot/grub/grub.cfg "$work/grub.cfg"
read -r _ kernel arguments < <(grep -m 1 -E '^\s*linux\s' "$work/grub.cfg")
read -r _ initrd < <(grep -m 1 -E '^\s*initrd\s' "$work/grub.cfg")
extract "${kernel#'($root)'}" "$work/kernel"
extract "${initrd#'($root)'}" "$work/initrd"
# Drop GRUB's variables and what hides boot messages.
kept=()
for argument in $arguments; do
  case "$argument" in
    quiet | rhgb | splash | *'${'*) ;;
    *) kept+=("$argument") ;;
  esac
done
arguments="${kept[*]}"
arguments+=" console=ttyS0,115200 systemd.debug_shell=ttyS1"
echo "Booting $(basename "$iso"): $arguments"

mkfifo "$work/shell.in" "$work/shell.out" "$work/monitor.in" "$work/monitor.out"
cat "$work/shell.out" >"$logs/shell.log" &
reader_pid=$!
qemu-system-x86_64 -accel kvm -cpu host -machine q35 -smp 4 -m 4096 -display none -nic none \
  -device virtio-vga -device qemu-xhci -device usb-tablet \
  -drive "file=$iso,media=cdrom,readonly=on" \
  -kernel "$work/kernel" -initrd "$work/initrd" -append "$arguments" \
  -serial "file:$logs/console.log" -serial "pipe:$work/shell" -monitor "pipe:$work/monitor" &
qemu_pid=$!
exec 3<>"$work/shell.in" 4<>"$work/monitor.in"
cat "$work/monitor.out" >/dev/null &

screenshot() {
  printf 'screendump %s\nscreendump %s -f png\n' "$work/screen.ppm" "$logs/screen.png" >&4
  sleep 3
}
collect() {
  printf '%s\n' 'coredumpctl --no-pager list' 'journalctl -b --no-pager -p warning | tail -n 80' >&3
  sleep 5
  screenshot
}
fail() {
  echo "FAILED: $1" >&2
  collect
  tail -n 100 "$logs/shell.log" | tr -d '\r' >&2
  exit 1
}

# Each line reports KWin's and Plasma's process IDs and the number of crashes.
check='echo "CHECK $(pgrep -o -x kwin_wayland)/$(pgrep -o -x plasmashell)/$(coredumpctl -q --no-legend --no-pager list 2>/dev/null | wc -l)"'
last=
since=
while ((SECONDS < limit)); do
  kill -0 "$qemu_pid" 2>/dev/null || fail "the VM stopped"
  printf '%s\n' "$check" >&3
  sleep 5
  # Not anchored, since the shell wraps its output in escape codes. The echoed command has no match.
  state="$(grep -aoE 'CHECK [0-9]*/[0-9]*/[0-9]+' "$logs/shell.log" | tail -n 1 | cut -d' ' -f2)" || state=
  [[ -n "$state" ]] || continue
  IFS=/ read -r kwin plasma crashes <<<"$state"
  ((crashes == 0)) || fail "$crashes programs crashed"
  if [[ -z "$kwin" || -z "$plasma" ]]; then
    last=
  elif [[ "$state" != "$last" ]]; then
    last="$state"
    since=$SECONDS
  elif ((SECONDS - since >= stable)); then
    screenshot
    # A running compositor that draws nothing is still a black screen.
    [[ "$(tr -d '\0' <"$work/screen.ppm" | wc -c)" -gt 100000 ]] || fail "the screen is black"
    echo "Plasma stayed up for ${stable}s, after $((SECONDS - stable))s of booting"
    collect
    exit 0
  fi
done
fail "Plasma wasn't up and stable after ${limit}s"
