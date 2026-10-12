builder_image := "docker.io/library/debian:testing"
container_runtime := env("CONTAINER_RUNTIME", "podman")

[private]
default:
    @just --list

# Check Just Syntax
[group('Just')]
check:
    #!/usr/bin/env bash
    find . -type f -name "*.just" | while read -r file; do
    	echo "Checking syntax: $file"
    	just --unstable --fmt --check -f $file
    done
    echo "Checking syntax: Justfile"
    just --unstable --fmt --check -f Justfile

# Fix Just Syntax
[group('Just')]
fix:
    #!/usr/bin/env bash
    find . -type f -name "*.just" | while read -r file; do
    	echo "Checking syntax: $file"
    	just --unstable --fmt -f $file
    done
    echo "Checking syntax: Justfile"
    just --unstable --fmt -f Justfile || { exit 1; }

# Build the live ISO into output/
[group('ISO')]
build:
    {{ container_runtime }} run --rm --privileged \
      -v "{{ justfile_directory() }}:/src" \
      -w /src \
      {{ builder_image }} \
      ./build.sh

# Boot the ISO in a VM (uefi or bios)
[group('ISO')]
run-vm firmware="uefi" iso="":
    #!/usr/bin/env bash
    set -euo pipefail
    iso="{{ iso }}"
    if [[ -z "$iso" ]]; then
        iso="$(ls -t output/*.iso | head -n 1)"
    fi
    args=(-enable-kvm -cpu host -m 4096 -smp 4 -vga virtio -cdrom "$iso" -boot d)
    if [[ "{{ firmware }}" == "uefi" ]]; then
        vars="$(mktemp)"
        cp /usr/share/OVMF/OVMF_VARS_4M.fd "$vars"
        args+=(
            -drive "if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.fd"
            -drive "if=pflash,format=raw,file=$vars"
        )
    fi
    qemu-system-x86_64 "${args[@]}"

# Remove build files
[group('Utility')]
clean:
    {{ container_runtime }} run --rm \
      -v "{{ justfile_directory() }}:/src" \
      -w /src \
      {{ builder_image }} \
      rm -rf _build output
