FROM ghcr.io/ublue-os/bazzite:41@sha256:e43ec4fa563576dac7c8ea2c1db47895a608f4c18326c570ca23b0ddb395a10b

COPY system_files /
COPY build_files /tmp

RUN /tmp/install-apps.sh
RUN /tmp/fix-opt.sh
RUN /tmp/build-initramfs.sh
RUN /tmp/cleanup.sh
