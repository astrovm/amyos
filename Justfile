# Build the live ISO into output/
build:
    podman run --rm --privileged -v "{{ justfile_directory() }}:/src" -w /src docker.io/library/debian:testing ./build.sh

# Boot the newest ISO in a VM (uefi or bios)
run-vm firmware="uefi":
    #!/usr/bin/env bash
    set -euo pipefail
    args=(-enable-kvm -cpu host -m 4096 -smp 4 -vga virtio -cdrom "$(ls -t output/*.iso | head -n 1)")
    if [[ "{{ firmware }}" == "uefi" ]]; then
        cp /usr/share/OVMF/OVMF_VARS_4M.fd /tmp/amyos-ovmf-vars.fd
        args+=(
            -drive "if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.fd"
            -drive "if=pflash,format=raw,file=/tmp/amyos-ovmf-vars.fd"
        )
    fi
    qemu-system-x86_64 "${args[@]}"

# Remove build files
clean:
    podman run --rm -v "{{ justfile_directory() }}:/src" -w /src docker.io/library/debian:testing rm -rf _build output
