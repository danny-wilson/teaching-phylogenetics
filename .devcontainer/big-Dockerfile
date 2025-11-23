FROM ubuntu:22.04
LABEL app="Teaching Phylogenetics"
LABEL description="Docker image for teaching phylogenetics"
LABEL maintainer="Daniel Wilson"
LABEL version="November 2025"

# Disable prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install standard packages, avoiding dialogue requesting locale
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y tzdata
RUN apt-get install -y build-essential x11-apps default-jre wget curl git xterm r-base r-cran-phangorn jalview tini

# Install Firefox from Mozilla's repository to get the latest version
RUN apt-get install -y --no-install-recommends \
      software-properties-common \
      wget \
      gnupg \
      ca-certificates
RUN add-apt-repository -y ppa:mozillateam/ppa \
  && echo "Package: firefox*; Pin: release o=LP-PPA-mozillateam; Pin-Priority: 501" \
     | sed 's/; /\n/g' > /etc/apt/preferences.d/mozilla-firefox
RUN apt-get update \
  && apt-get install -y --no-install-recommends firefox \
  && rm -rf /var/lib/apt/lists/*

# Install specialist apps
WORKDIR /tmp

# BEAST
RUN wget https://github.com/beast-dev/beast-mcmc/releases/download/v1.10.5pre_thorney_v0.1.2/BEASTv1.10.5pre_thorney_0.1.2.tgz
RUN tar -xzvf BEASTv1.10.5pre_thorney_0.1.2.tgz
RUN mv /tmp/BEASTv1.10.5pre_thorney_0.1.2/bin/* /usr/bin/
RUN mv /tmp/BEASTv1.10.5pre_thorney_0.1.2/lib/* /usr/lib/
# Make alias for beast -java
RUN alias beast='/usr/bin/beast -java'

# Figtree
RUN wget https://github.com/rambaut/figtree/releases/download/v1.4.4/FigTree_v1.4.4.tgz
RUN tar -xzvf FigTree_v1.4.4.tgz
RUN mv /tmp/FigTree_v1.4.4/bin/* /usr/bin/
RUN mv /tmp/FigTree_v1.4.4/lib/* /usr/lib/
RUN chmod +x /usr/bin/figtree
RUN sed -i 's+lib+/usr/lib+' /usr/bin/figtree

# Phyml
RUN curl -O http://www.atgc-montpellier.fr/download/binaries/phyml/PhyML-3.1.zip
RUN unzip PhyML-3.1.zip 
RUN mv /tmp/PhyML-3.1/PhyML-3.1_linux64 /usr/bin/
RUN ln -s /usr/bin/PhyML-3.1_linux64 /usr/bin/phyml

# ClonalFrameML
RUN git clone https://github.com/xavierdidelot/ClonalFrameML.git
WORKDIR /tmp/ClonalFrameML/src
RUN make
RUN mv /tmp/ClonalFrameML/src/ClonalFrameML /usr/bin/
WORKDIR /tmp

# Mafft
ARG TARGETARCH
RUN set -eux; \
    if [ "x$TARGETARCH" = "xamd64" ]; then \
      curl -fsSL -O https://mafft.cbrc.jp/alignment/software/mafft_7.450-1_amd64.deb; \
      dpkg -i mafft_7.450-1_amd64.deb || (apt-get update && apt-get -f install -y); \
      rm -f mafft_7.450-1_amd64.deb; \
    else \
      echo "Warning: mafft unsupported on architecture: $TARGETARCH - skipping installation"; \
    fi \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# TempEst
RUN wget https://github.com/beast-dev/Tempest/releases/download/v1.5.3/TempEst_v1.5.3.tgz
RUN tar -xzvf TempEst_v1.5.3.tgz
RUN mv /tmp/TempEst_v1.5.3/bin/* /usr/bin/
RUN mv /tmp/TempEst_v1.5.3/lib/* /usr/lib/
RUN chmod +x /usr/bin/tempest

# Tracer
RUN wget https://github.com/beast-dev/tracer/releases/download/v1.7.1/Tracer_v1.7.1.tgz
RUN tar -xzvf Tracer_v1.7.1.tgz
RUN mv /tmp/Tracer_v1.7.1/bin/* /usr/bin/
RUN mv /tmp/Tracer_v1.7.1/lib/* /usr/lib/
RUN chmod +x /usr/bin/tracer

# Clean up
RUN rm /tmp/*.tgz

# Install XPRA
RUN apt-get update && apt-get install -y \
      gnupg2 apt-transport-https \
      x11-xserver-utils xserver-xorg-video-dummy \
    && wget -qO- https://xpra.org/gpg.asc | apt-key add - \
    && echo "deb https://xpra.org/ jammy main" > /etc/apt/sources.list.d/xpra.list \
    && apt-get update && apt-get install -y xpra xpra-x11 xvfb \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Desktop and browser-accessible VNC (noVNC)
RUN apt update && \
	apt install -y xfce4 xfce4-terminal x11vnc dbus-x11 python3 python3-pip git \
		xauth x11-utils xfonts-base iproute2 && \
	pip3 install --no-cache-dir websockify

RUN git clone https://github.com/novnc/noVNC.git /opt/noVNC
RUN git clone https://github.com/novnc/websockify /opt/noVNC/utils/websockify

# Copy helper scripts into the image and make them executable
COPY ./bin/*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh
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

# Remove screensaver packages to avoid interference
#RUN apt-get update && apt-get remove -y light-locker xfce4-screensaver && \
#    apt-get autoremove -y

# Allow any user to start Xvfb :1
RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

# Set up user
ARG USERNAME=student
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid ${USER_GID} ${USERNAME} \
 && useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash ${USERNAME} \
 && apt-get update && apt-get install -y sudo \
 && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
 && chmod 0440 /etc/sudoers.d/${USERNAME}

# Ensure XDG runtime dir exists for the student (some apps expect it)
ARG XDG_RUNTIME_DIR=/run/user/${USER_GID}
RUN mkdir -p ${XDG_RUNTIME_DIR} && \
  chown ${USERNAME}:${USERNAME} ${XDG_RUNTIME_DIR} && \
  chmod 700 ${XDG_RUNTIME_DIR}

# Ensure Xpra run dir exists
#RUN mkdir -p ${RUN_XPRA_DIR} && \
#  chown ${USERNAME}:${USERNAME} ${RUN_XPRA_DIR} && \
#  chmod 700 ${RUN_XPRA_DIR}

# Switch to non-root user
USER ${USERNAME}
ENV HOME=/home/${USERNAME}

# Ensure workspace directory exists
RUN mkdir -p ${HOME}/work

# Ensure Xauthority exists
ARG XAUTHORITY=/home/${USERNAME}/.Xauthority
RUN touch ${XAUTHORITY}

# Default command
WORKDIR $HOME
ENTRYPOINT ["/usr/bin/tini", "--"]

# Start the desktop+xpra services on container run and keep container alive
#USER root
CMD ["/usr/local/bin/entry.sh"]