FROM ubuntu:14.04

LABEL maintainer "robertkazakov@mail.ru"

# Installing Firefox-browser, packeges for managing x11-socket
RUN apt-get update && \
    apt-get install -y \
    firefox \
    libcanberra-gtk-module \
    packagekit-gtk3-module

# Replace 1000 with your user / group id
RUN export uid=1000 gid=1000 && \
mkdir -p /home/developer && \
echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
echo "developer:x:${uid}:" >> /etc/group && \
echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
chmod 0440 /etc/sudoers.d/developer && \
chown ${uid}:${gid} -R /home/developer

# Installing window-manager, VNC and XVFB
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

# Installing VNCviewer for testing environment
RUN apt-get update && \
    apt-get install -y vncviewer

# ENV DISPLAY=192.168.1.196:0

# Installing fonts, dpi, xorg for XVFB
RUN apt-get update && \
    apt-get install -y \
    x11-xkb-utils \
    xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic \
    xserver-xorg-core

RUN rm -rf /var/lib/apt/lists/* /var/cache/apt/*
#RUN sudo -H Xvfb :0 -screen 0 1024x768x24
#RUN sudo -H fluxbox &
#RUN sudo -H x11vnc -display :0 -bg -forever -nopw -quiet -listen localhost -rfbport 5566 -xkb

USER developer
ENV HOME /home/developer
EXPOSE 5566

CMD /usr/bin/firefox
