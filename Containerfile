FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/ublue-os/bazzite:42@sha256:0ab926cdf8c1cb63029399242e95f2196bb2c720bb03cc5897148c2010638c7c as amyos
COPY system_files /

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  /ctx/install-apps.sh && \
  /ctx/fix-opt.sh && \
  /ctx/build-initramfs.sh && \
  /ctx/cleanup.sh
