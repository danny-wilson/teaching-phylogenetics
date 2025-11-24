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
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    tzdata \
    build-essential x11-apps default-jre wget curl git xterm tini \
    software-properties-common gnupg ca-certificates \
    xfce4 xfce4-terminal x11vnc dbus-x11 python3 python3-pip \
	  xauth x11-utils xfonts-base iproute2 \
    apt-transport-https x11-xserver-utils xserver-xorg-video-dummy \
    r-base r-cran-phangorn jalview unzip \
    r-base-dev gfortran \
    libxml2-dev libcurl4-openssl-dev libssl-dev \
    zlib1g-dev libbz2-dev liblzma-dev libzmq3-dev pandoc \
  && pip3 install --no-cache-dir jupyterlab websockify \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /root/.cache/pip

###################################
# Install R packages and register IRkernel system-wide
RUN R -e "install.packages(c('IRkernel','languageserver','rmarkdown','repr','IRdisplay','evaluate'), repos='https://cloud.r-project.org')" \
  && R -e "IRkernel::installspec(user = FALSE)"
###################################

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
# Install apps
###################################

# Firefox
RUN add-apt-repository -y ppa:mozillateam/ppa \
  && echo "Package: firefox*; Pin: release o=LP-PPA-mozillateam; Pin-Priority: 501" \
     | sed 's/; /\n/g' > /etc/apt/preferences.d/mozilla-firefox \
  && apt-get update \
  && apt-get install -y --no-install-recommends firefox \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# BEAST
RUN wget https://github.com/beast-dev/beast-mcmc/releases/download/v1.10.5pre_thorney_v0.1.2/BEASTv1.10.5pre_thorney_0.1.2.tgz \
  && tar -xzvf BEASTv1.10.5pre_thorney_0.1.2.tgz \
  && mv /tmp/BEASTv1.10.5pre_thorney_0.1.2/bin/* /usr/local/bin/ \
  && mv /tmp/BEASTv1.10.5pre_thorney_0.1.2/lib/* /usr/local/lib/ \
  && rm -rf /tmp/BEASTv1.10.5pre_thorney_0.1.2 BEASTv1.10.5pre_thorney_0.1.2.tgz

# Figtree
RUN wget https://github.com/rambaut/figtree/releases/download/v1.4.4/FigTree_v1.4.4.tgz \
  && tar -xzvf FigTree_v1.4.4.tgz \
  && mv /tmp/FigTree_v1.4.4/bin/* /usr/local/bin/ \
  && mv /tmp/FigTree_v1.4.4/lib/* /usr/local/lib/ \
  && chmod +x /usr/local/bin/figtree \
  && sed -i 's+lib+/usr/local/lib+' /usr/local/bin/figtree \
  && rm -rf /tmp/FigTree_v1.4.4 FigTree_v1.4.4.tgz

# Phyml
RUN curl -O http://www.atgc-montpellier.fr/download/binaries/phyml/PhyML-3.1.zip \
  && unzip PhyML-3.1.zip \
  && mv /tmp/PhyML-3.1/PhyML-3.1_linux64 /usr/local/bin/ \
  && ln -s /usr/local/bin/PhyML-3.1_linux64 /usr/local/bin/phyml \
  && rm -rf /tmp/PhyML-3.1 PhyML-3.1.zip \
  && chmod +x /usr/local/bin/PhyML-3.1_linux64

# ClonalFrameML
RUN git clone --depth 1 https://github.com/xavierdidelot/ClonalFrameML.git /tmp/ClonalFrameML \
  && cd /tmp/ClonalFrameML/src \
  && make \
  && mv /tmp/ClonalFrameML/src/ClonalFrameML /usr/local/bin/ \
  && mv /tmp/ClonalFrameML/src/cfml_results.R /usr/local/bin/ \
  && rm -rf /tmp/ClonalFrameML

# Mafft
ARG TARGETARCH
RUN set -eux; \
    if [ "x$TARGETARCH" != "xamd64" ]; then \
      echo "Warning: mafft unsupported on architecture: $TARGETARCH - skipping installation"; \
    else \
      curl -fsSL -O https://mafft.cbrc.jp/alignment/software/mafft_7.450-1_amd64.deb; \
      dpkg -i mafft_7.450-1_amd64.deb || (apt-get update && apt-get -f install -y); \
      rm -f mafft_7.450-1_amd64.deb; \
    fi \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# TempEst
RUN wget https://github.com/beast-dev/Tempest/releases/download/v1.5.3/TempEst_v1.5.3.tgz \
  && tar -xzvf TempEst_v1.5.3.tgz \
  && mv /tmp/TempEst_v1.5.3/bin/* /usr/local/bin/ \
  && mv /tmp/TempEst_v1.5.3/lib/* /usr/local/lib/ \
  && chmod +x /usr/local/bin/tempest \
  && rm -rf /tmp/TempEst_v1.5.3 TempEst_v1.5.3.tgz

# Tracer
RUN wget https://github.com/beast-dev/tracer/releases/download/v1.7.1/Tracer_v1.7.1.tgz \
  && tar -xzvf Tracer_v1.7.1.tgz \
  && mv /tmp/Tracer_v1.7.1/bin/* /usr/local/bin/ \
  && mv /tmp/Tracer_v1.7.1/lib/* /usr/local/lib/ \
  && chmod +x /usr/local/bin/tracer \
  && rm -rf /tmp/Tracer_v1.7.1 Tracer_v1.7.1.tgz

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

###################################
# Switch to non-root user
###################################
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
CMD ["/usr/local/bin/entry.sh"]
