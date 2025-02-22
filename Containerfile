FROM ghcr.io/ublue-os/bazzite:41

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:stable
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
#
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

COPY system_files /
COPY build_files /tmp

RUN mkdir -p /var/opt && \
  /tmp/build.sh && \
  /tmp/fix-opt.sh && \
  /tmp/build-initramfs.sh && \
  /tmp/cleanup.sh && \
  ostree container commit
