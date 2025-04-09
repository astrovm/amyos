FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/ublue-os/bazzite:41@sha256:857eb4f3a19f7a6956d6ebe458497cc96f7d4e9ed396192518a17ef8a8b40f24 as amyos
COPY system_files /

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  /ctx/install-apps.sh && \
  /ctx/fix-opt.sh && \
  /ctx/build-initramfs.sh && \
  /ctx/cleanup.sh
