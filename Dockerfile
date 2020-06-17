FROM ubuntu:latest

LABEL maintainer "robertkazakov@mail.ru"

# Install minimal runtime
RUN apt-get update -qqy && \
    apt-get -qqy --no-install-recommends install \
    bzip2 \
    ca-certificates \
    default-jre \
    sudo \
    unzip \
    wget \
    libgconf-2-4

# Install supervisor, VNC, & X11 packages
RUN set -ex && \
    apt-get update && \
    apt-get install -y \
      bash \
      fluxbox \
      net-tools \
      novnc \
      socat \
      supervisor \
      x11vnc \
      xterm \
      xvfb

RUN apt-get update && \
    apt-get install -y \
    x11-xkb-utils \
    xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic \
    xserver-xorg-core \
    firefox

RUN rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN sudo useradd rabbit --shell /bin/bash --create-home \
  && sudo usermod -a -G sudo rabbit \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'rabbit:secret' | chpasswd

ENV HOME=/root \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=:0 \
    DISPLAY_WIDTH=1024 \
    DISPLAY_HEIGHT=768 \
    RUN_XTERM=yes \
    RUN_FLUXBOX=yes

USER root

RUN sudo -H Xvfb $DISPLAY -screen 0 ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x16 -fbdir /var/tmp&
RUN sudo -H fluxbox & 
RUN sudo -H x11vnc -display ${DISPLAY} -bg -nopw -listen localhost -xkb -rfbport 5566 -noxrecord -noxfixes -noxdamage

EXPOSE 5566

RUN firefox