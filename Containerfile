FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/ublue-os/bazzite:41@sha256:a4a2c0458a6e01af8fbcfae5f6192d09c0429cacee50604489b1a7072101efa1 as amyos
COPY system_files /

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  /ctx/install-apps.sh && \
  /ctx/fix-opt.sh && \
  /ctx/build-initramfs.sh && \
  /ctx/cleanup.sh
