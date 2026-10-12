# Build the live ISO for this machine's architecture into output/
build:
    podman run --rm --privileged -v "{{ justfile_directory() }}:/src" -w /src docker.io/library/debian:testing ./build.sh

# Build the Fedora bootc image as localhost/amyos:fedora
build-fedora:
    podman build --pull=newer -f fedora/Containerfile -t localhost/amyos:fedora "{{ justfile_directory() }}"

# Boot the newest native ISO with a disposable installation disk
run-vm firmware="uefi":
    #!/usr/bin/env bash
    set -euo pipefail
    firmware={{ quote(firmware) }}
    case "$firmware" in uefi|bios) ;; *) echo "Use uefi or bios" >&2; exit 1 ;; esac
    case "$(uname -m)" in
        arm64|aarch64) architecture=arm64; qemu=qemu-system-aarch64 ;;
        x86_64) architecture=amd64; qemu=qemu-system-x86_64 ;;
        *) echo "Unsupported host architecture" >&2; exit 1 ;;
    esac
    iso="$(ls -t output/*-"$architecture".iso | head -n 1)"
    temporary="$(mktemp -d "${TMPDIR:-/tmp}/amyos-vm.XXXXXX")"
    trap 'rm -rf "$temporary"' EXIT
    qemu-img create -f qcow2 "$temporary/install.qcow2" 24G
    args=(-m 3072 -smp 2 -boot d
        -drive "file=$temporary/install.qcow2,if=virtio,format=qcow2"
        -device virtio-scsi-pci,id=scsi
        -drive "file=$iso,if=none,id=cdrom,format=raw,media=cdrom"
        -device scsi-cd,drive=cdrom,bus=scsi.0)
    if [[ "$(uname -s)" == Darwin ]]; then
        args+=(-accel hvf -cpu host)
        firmware_directory="$(brew --prefix qemu)/share/qemu"
    elif [[ -r /dev/kvm && -w /dev/kvm ]]; then
        args+=(-accel kvm -cpu host)
    else
        args+=(-accel tcg -cpu max)
    fi
    if [[ "$architecture" == arm64 ]]; then
        [[ "$firmware" == uefi ]] || { echo "ARM64 uses UEFI" >&2; exit 1; }
        args+=(-machine virt -device virtio-gpu-pci -device qemu-xhci -device usb-kbd -device usb-tablet)
        code="${firmware_directory:-/usr/share/AAVMF}/AAVMF_CODE.fd"
        variables="${firmware_directory:-/usr/share/AAVMF}/AAVMF_VARS.fd"
        if [[ "$(uname -s)" == Darwin ]]; then
            code="$firmware_directory/edk2-aarch64-code.fd"
            variables="$firmware_directory/edk2-arm-vars.fd"
        fi
    else
        args+=(-vga virtio)
        code=/usr/share/OVMF/OVMF_CODE_4M.fd
        variables=/usr/share/OVMF/OVMF_VARS_4M.fd
        if [[ "$(uname -s)" == Darwin ]]; then
            code="$firmware_directory/edk2-x86_64-code.fd"
            variables="$firmware_directory/edk2-i386-vars.fd"
        fi
    fi
    if [[ "$firmware" == uefi ]]; then
        cp "$variables" "$temporary/variables.fd"
        args+=(-drive "if=pflash,format=raw,readonly=on,file=$code"
               -drive "if=pflash,format=raw,file=$temporary/variables.fd")
    fi
    echo "The VM's temporary installation disk is deleted when QEMU exits."
    "$qemu" "${args[@]}"

# Remove build files
clean:
    podman run --rm -v "{{ justfile_directory() }}:/src" -w /src docker.io/library/debian:testing rm -rf _build output
