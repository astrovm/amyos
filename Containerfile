FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/ublue-os/bazzite:42@sha256:2e4a612571d9845db2d1d0fb783c26a67bfcb8da463ba825a408d146e24e7f1d as amyos
COPY system_files /

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  /ctx/install-apps.sh && \
  /ctx/fix-opt.sh && \
  /ctx/build-initramfs.sh && \
  /ctx/cleanup.sh
