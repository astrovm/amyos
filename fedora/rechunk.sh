#!/usr/bin/env bash
# Splits the image into stable layers, so `bootc upgrade` downloads only what changed.
# Usage: fedora/rechunk.sh <image> [key=value label ...]
set -euo pipefail
image="$1"
shift

# Rechunking writes a new image config, so carry the labels over.
# rpm-ostree sets its own ostree and bootc labels.
declare -A labels
while IFS='=' read -r key value; do
  [[ -z "$key" || "$key" == ostree.* || "$key" == containers.bootc ]] && continue
  labels[$key]="$value"
done < <(podman image inspect "$image" --format '{{range $k, $v := .Labels}}{{$k}}={{$v}}{{"\n"}}{{end}}')
for label in "$@"; do
  labels[${label%%=*}]="${label#*=}"
done
args=()
for key in "${!labels[@]}"; do
  args+=(--label "$key=${labels[$key]}")
done

graphroot="$(podman info --format '{{.Store.GraphRoot}}')"
podman run --rm --pull=never --privileged \
  --mount=type=image,src="$image",target=/rpm-ostree \
  --mount=type=bind,src="$graphroot",target=/run/host-container-storage,rw \
  --mount=type=tmpfs,target=/run/rpm-ostree-storage \
  --entrypoint /usr/bin/rpm-ostree \
  "$image" \
  compose build-chunked-oci --bootc --format-version=2 --max-layers 127 \
  --rootfs /rpm-ostree "${args[@]}" \
  --output "containers-storage:[overlay@/run/host-container-storage+/run/rpm-ostree-storage]$image"
