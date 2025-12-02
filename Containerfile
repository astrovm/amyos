FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/ublue-os/bazzite:stable-43@sha256:db7a1349508d8f2a9c844c297925ba78e0d7167f5883a8b74579ea8c369f6e83 as amyos
COPY system_files /

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  /ctx/install-apps.sh && \
  /ctx/fix-opt.sh && \
  /ctx/build-initramfs.sh && \
  /ctx/cleanup.sh
