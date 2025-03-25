FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/ublue-os/bazzite:41@sha256:e43ec4fa563576dac7c8ea2c1db47895a608f4c18326c570ca23b0ddb395a10b as bazzite
COPY system_files /

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  /ctx/install-apps.sh && \
  /ctx/fix-opt.sh && \
  /ctx/build-initramfs.sh && \
  /ctx/cleanup.sh
