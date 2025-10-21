FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/ublue-os/bazzite:42@sha256:ca0d9ff74c55fa3c4bc193594902cea00daf0ebd58420a4eaa5c8952705ffb5d as amyos
COPY system_files /

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  /ctx/install-apps.sh && \
  /ctx/fix-opt.sh && \
  /ctx/build-initramfs.sh && \
  /ctx/cleanup.sh
