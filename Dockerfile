FROM alpine:latest

LABEL maintainer "robertkazakov@mail.ru"

# Installing browser
RUN apk add --no-cache \
  firefox

# Installing Xephyr(X monitors), fluxbox (win-manager), x11vnc (VNC)
RUN apk add --no-cache \
  xorg-server-xephyr \
  fluxbox \
  x11vnc

# Installing fonts, sudo
RUN apk add --no-cache \
  font-cronyx-cyrillic \
  sudo

# Creating new user 
RUN export uid=1000 gid=1000 && \
  mkdir -p /home/developer && \
  echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
  echo "developer:x:${uid}:" >> /etc/group && \
  echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
  chmod 0440 /etc/sudoers.d/developer && \
  chown ${uid}:${gid} -R /home/developer

ARG DISPLAY
ARG DISPLAY_HEIGHT
ARG DISPLAY_WIDTH
ARG DISPLAY_DEPTH
ARG DISPLAY_NUM
ARG PORT

ENV DISPLAY=${DISPLAY}
ENV RESOLUTION="${DISPLAY_HEIGHT}x${DISPLAY_WIDTH}x${DISPLAY_DEPTH}"

# Launching virtual X display
RUN DISPLAY=${DISPLAY} Xephyr -ac -screen ${RESOLUTION} -br -reset -terminate 2> /dev/null ${DISPLAY_NUM} &

# Running window manager onto the new display
RUN DISPLAY=${DISPLAY_NUM} fluxbox &

# Connecting with VNC
RUN /usr/bin/x11vnc -display ${DISPLAY_NUM} -xkb -rbport 5566 -noxrecord -noxfixes -noxdamage -forever -nopw &

USER developer
ENV HOME /home/developer

# Opening port
EXPOSE ${PORT}

# Launching browser
CMD /usr/bin/firefox