FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/ublue-os/bazzite:42@sha256:f01ab84f7bdfb4612eae39f59b933d6dee15f367229079a335ee2bb84bb89580 as amyos
COPY system_files /

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  /ctx/install-apps.sh && \
  /ctx/fix-opt.sh && \
  /ctx/build-initramfs.sh && \
  /ctx/cleanup.sh
