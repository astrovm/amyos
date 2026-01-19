FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/ublue-os/bazzite:stable-43@sha256:fdc77a8b5a08b3bf89063cb02ba8b1e3cb61a09ad776fcfb3c657314e55af729 as amyos
COPY system_files /

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  /ctx/install-apps.sh && \
  /ctx/fix-opt.sh && \
  /ctx/build-initramfs.sh && \
  /ctx/cleanup.sh
