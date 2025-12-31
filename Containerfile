FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/ublue-os/bazzite:stable-43@sha256:5a5a9625b10ebf7eba4be7e2cb9a83ef7a8589b3a017a91bb3e21567b35b1cce as amyos
COPY system_files /

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  /ctx/install-apps.sh && \
  /ctx/fix-opt.sh && \
  /ctx/build-initramfs.sh && \
  /ctx/cleanup.sh
