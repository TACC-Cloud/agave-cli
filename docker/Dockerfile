######################################################
#
# Agave CLI Image
# Tag: agave-cli
#
# https://bitbucket.org/taccaci/agave-environment
#
# This container the Agave CLI and can be used for
# parallel environment testing.
#
# docker run -it -v $HOME/.agave:/root/.agave agaveapi/agave-cli bash
#
######################################################

FROM centos:centos6
MAINTAINER Rion Dooley <dooley@tacc.utexas.edu>
RUN yum install -y git vim-minimal

# install the cli from git
RUN git clone https://bitbucket.org/taccaci/foundation-cli /usr/local/agave-cli && \
    chmod +x /usr/local/agave-cli/bin/*

# set user's default env. This won't get sourced, but is helpful
RUN echo HOME=/root >> /root/.bashrc && \
    echo PATH=/usr/local/agave-cli/bin:$PATH >> /root/.bashrc && \
    echo AGAVE_CACHE_DIR=/root/.agave >> /root/.bashrc

ENV ENV /root/.bashrc

# Runtime parameters. Start a shell by default
VOLUME /root/.agave
CMD "/bin/bash"
