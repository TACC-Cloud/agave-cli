######################################################
#
# Agave CLI Image
# Tag: agave-cli
#
# https://bitbucket.org/agaveapi/cli
#
# This container the Agave CLI and can be used for
# parallel environment testing.
#
# docker run -it -v $HOME/.agave:/root/.agave agaveapi/cli bash
#
######################################################

FROM ubuntu:trusty

MAINTAINER Rion Dooley <dooley@tacc.utexas.edu>

RUN apt-get update && \
    # install ngrok for reverse tunnel and webhook processing locally
    apt-get install -y git vim.tiny curl ngrok-client jq

    #echo -e "Package: *\nPin: release a=wheezy-backports\nPin-Priority: 100" >> /etc/apt/preferences && \
    #echo -e "## DEBIAN BACKPORTS\ndeb http://ftp.us.debian.org/debian wheezy-backports main contrib non-free
" >> /etc/apt/sources.list

ADD . /usr/local/agave-cli

RUN # install the cli from git
    chmod +x /usr/local/agave-cli/bin/* && \

    # set user's default env. This won't get sourced, but is helpful
    echo HOME=/root >> /root/.bashrc && \
    echo PATH=/usr/local/agave-cli/bin:$PATH >> /root/.bashrc && \
    echo AGAVE_CACHE_DIR=/root/.agave >> /root/.bashrc &&

    # prettyprint the terminal
    echo export PS1=\""\[\e[32;4m\]agave-cli\[\e[0m\]:\u@\h:\w$ "\" >> /root/.bashrc

    /usr/local/agave-cli/bin/tenants-init -t agave.prod


ENV ENV /root/.bashrc
ENV AGAVE_DEVEL_MODE=
ENV AGAVE_DEVURL=
ENV AGAVE_CACHE_DIR=~/.agave
ENV AGAVE_JSON_PARSER=jq

# Runtime parameters. Start a shell by default
VOLUME /root/.agave

CMD "/bin/bash"
