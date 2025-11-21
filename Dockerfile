FROM ubuntu:bionic
LABEL app="Teaching Phylogenetics"
LABEL description="Docker image for teaching phylogenetics"
LABEL maintainer="Daniel Wilson"
LABEL version="November 2025"

# Set home directory
ENV HOME /home

# Install standard packages, avoiding dialogue requesting locale
RUN apt update && apt upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt install -y tzdata
RUN apt install build-essential x11-apps default-jre wget curl git xterm firefox r-base r-cran-phangorn jalview -y

# Install specialist apps
WORKDIR /tmp

# BEAST
RUN wget https://github.com/beast-dev/beast-mcmc/releases/download/v1.10.5pre1/BEASTv1.10.5pre.tgz
RUN tar -xzvf BEASTv1.10.5pre.tgz
RUN mv /tmp/BEASTv1.10.5pre/bin/* /usr/bin/
RUN mv /tmp/BEASTv1.10.5pre/lib/* /usr/lib/
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
RUN curl -O https://mafft.cbrc.jp/alignment/software/mafft_7.450-1_amd64.deb
RUN dpkg -i mafft_7.450-1_amd64.deb

# TempEst
RUN wget https://github.com/beast-dev/beast-mcmc/releases/download/v1.5.3-tempest/TempEst_v1.5.3.tgz
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

# Default command
WORKDIR $HOME
CMD ["/bin/bash"]
