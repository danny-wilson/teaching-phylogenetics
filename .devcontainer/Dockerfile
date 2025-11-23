# syntax=docker/dockerfile:1

###################################
# Base image / args
###################################
ARG UBUNTU=ubuntu:22.04
FROM ${UBUNTU} AS base
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

###################################
# Install runtime packages (single RUN)
# - --no-install-recommends to slim deps
# - combine all apt ops, then clean lists
###################################
# Not yet added: r-base r-cran-phangorn jalview
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    tzdata \
    build-essential x11-apps default-jre wget curl git xterm tini \
    software-properties-common gnupg ca-certificates \
    xfce4 xfce4-terminal x11vnc dbus-x11 python3 python3-pip \
	xauth x11-utils xfonts-base iproute2 \
    apt-transport-https x11-xserver-utils xserver-xorg-video-dummy \
  && pip3 install --no-cache-dir websockify \
  && rm -rf /var/lib/apt/lists/*

# Need to add firefox
# Need to add BEAST, Figtree, Phyml, ClonalFrameML, Mafft, TempEst, Tracer

# Do I need these:
#RUN git clone https://github.com/novnc/noVNC.git /opt/noVNC
#RUN git clone https://github.com/novnc/websockify /opt/noVNC/utils/websockify

###################################
#Optional: add xpra repo if you need the upstream packages
#(uncomment if upstream repo required)
###################################
RUN wget -qO- https://xpra.org/gpg.asc | apt-key add - \
  && echo "deb https://xpra.org/ jammy main" >/etc/apt/sources.list.d/xpra.list \
  && apt-get update && apt-get install -y xpra xpra-x11 xvfb \
  && apt-get clean && rm -rf /var/lib/apt/lists/*
#   && apt-get update && apt-get install -y --no-install-recommends xpra xpra-x11 xvfb \

###################################
# Copy configuration files
###################################
# Copy landing page into image so it can be served without relying on build context at runtime
COPY ./landing /opt/landing
# Copy XPRA configuration file
COPY ./conf/xpra.conf /etc/xpra/xpra.conf
# Copy XPRA aliases to profile.d and change permissions
COPY ./conf/xpra_aliases.sh /etc/profile.d/xpra_aliases.sh
RUN chmod 644 /etc/profile.d/xpra_aliases.sh
# Remove annoying message Xsession: unable to launch "true" X session --- "true" not found; falling back to default session.
# Patch Xsession.d script to replace buggy command -v line with /usr/bin/which. See https://bugs.launchpad.net/ubuntu/+source/xorg/+bug/1983185
COPY ./conf/20x11-common_process-args /etc/X11/Xsession.d/20x11-common_process-args

###################################
# Create a non-root user and dirs in one layer
###################################
ARG USERNAME=student
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid ${USER_GID} ${USERNAME} \
 && useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash ${USERNAME} \
 && mkdir -p /tmp/.X11-unix /home/${USERNAME}/work /run/user/${USER_GID} \
 && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME} /run/user/${USER_GID} \
 && chmod 1777 /tmp/.X11-unix

# Ensure XDG runtime dir exists for the student (some apps expect it)
ARG XDG_RUNTIME_DIR=/run/user/${USER_GID}
RUN mkdir -p ${XDG_RUNTIME_DIR} && \
  chown ${USERNAME}:${USERNAME} ${XDG_RUNTIME_DIR} && \
  chmod 700 ${XDG_RUNTIME_DIR}
# Allow any user to start Xvfb :1
RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix


# Switch to non-root user
USER ${USERNAME}
ENV HOME=/home/${USERNAME}

###################################
# Copy only required runtime files and mark executable
###################################
# (keep this minimal; copy helper scripts and xpra conf)
COPY --chown=${USERNAME}:${USERNAME} ./bin/*.sh /usr/local/bin/
COPY --chown=${USERNAME}:${USERNAME} ./conf/xpra.conf /etc/xpra/xpra.conf
COPY --chown=${USERNAME}:${USERNAME} ./conf/xpra_aliases.sh /etc/profile.d/xpra_aliases.sh
RUN chmod +x /usr/local/bin/*.sh

WORKDIR ${HOME}
ENTRYPOINT ["/usr/bin/tini", "--"]
# CMD ["/usr/local/bin/entry.sh"]

# ###################################
# # Dev target (only when you ask for it: `docker build --target=dev .`)
# # Adds debugging/tools & git/noVNC during development
# ###################################
# FROM base AS dev
# USER root
# RUN apt-get update \
#  && apt-get install -y --no-install-recommends git curl vim less iproute2 x11-utils xauth \
#  && pip3 install --no-cache-dir git+https://github.com/novnc/noVNC.git@master \
#  && rm -rf /var/lib/apt/lists/*
# USER ${USERNAME}
