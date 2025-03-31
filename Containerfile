FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/ublue-os/bazzite:41@sha256:40b77b67f68eafad230e48f453be5aeb4ed42cb0996a43d6e8245e3a3ab752f1 as amyos
COPY system_files /

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  /ctx/install-apps.sh && \
  /ctx/fix-opt.sh && \
  /ctx/build-initramfs.sh && \
  /ctx/cleanup.sh
