# syntax=docker/dockerfile:1

###################################
# Base image / args
###################################
ARG UBUNTU=ubuntu:22.04
FROM ${UBUNTU} AS base
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# ###################################
# # Install runtime packages (single RUN)
# # - --no-install-recommends to slim deps
# # - combine all apt ops, then clean lists
# ###################################
# RUN apt-get update \
#  && apt-get install -y --no-install-recommends \
#       ca-certificates gnupg2 wget curl apt-transport-https \
#       xpra xpra-x11 xvfb xfce4-terminal xterm x11-xserver-utils \
#       x11vnc python3 python3-pip tini \
#  && pip3 install --no-cache-dir websockify \
#  && rm -rf /var/lib/apt/lists/*

# ###################################
# # Optional: add xpra repo if you need the upstream packages
# # (uncomment if upstream repo required)
# ###################################
# # RUN wget -qO- https://xpra.org/gpg.asc | apt-key add - \
# #  && echo "deb https://xpra.org/ jammy main" >/etc/apt/sources.list.d/xpra.list \
# #  && apt-get update && apt-get install -y --no-install-recommends xpra xpra-x11

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

USER ${USERNAME}
ENV HOME=/home/${USERNAME}

# ###################################
# # Copy only required runtime files and mark executable
# ###################################
# # (keep this minimal; copy helper scripts and xpra conf)
# COPY --chown=${USERNAME}:${USERNAME} ./bin/*.sh /usr/local/bin/
# COPY --chown=${USERNAME}:${USERNAME} ./conf/xpra.conf /etc/xpra/xpra.conf
# COPY --chown=${USERNAME}:${USERNAME} ./conf/xpra_aliases.sh /etc/profile.d/xpra_aliases.sh
# RUN chmod +x /usr/local/bin/*.sh

# WORKDIR ${HOME}
# ENTRYPOINT ["/usr/bin/tini", "--"]
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
