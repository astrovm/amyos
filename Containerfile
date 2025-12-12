FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/ublue-os/bazzite:stable-43@sha256:8025351cc625279fa8870ab22e40cdec0f6ffd825f195da4fb72310190537375 as amyos
COPY system_files /

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  /ctx/install-apps.sh && \
  /ctx/fix-opt.sh && \
  /ctx/build-initramfs.sh && \
  /ctx/cleanup.sh
