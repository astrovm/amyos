FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/ublue-os/bazzite:42@sha256:d0465f7d9c8c05997a96a92fe1d7b24197b14b614c5c518bcba1d0fb48f1bab0 as amyos
COPY system_files /

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  /ctx/install-apps.sh && \
  /ctx/fix-opt.sh && \
  /ctx/build-initramfs.sh && \
  /ctx/cleanup.sh
