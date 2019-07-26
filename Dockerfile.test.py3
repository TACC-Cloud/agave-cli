FROM cli-base:py3

ARG CLI_BRANCH=master
ARG CLI_VERSION=3.x.y
ARG AGAVEPY_BRANCH=master

LABEL org.label-schema.name = "TACC Tapis CLI"
LABEL org.label-schema.vcs-url = "https://github.com/TACC-Cloud/tapis-cli"
LABEL org.label-schema.vcs-ref = "${CLI_BRANCH}"
LABEL org.label-schema.version = "${CLI_VERSION}"


WORKDIR /install

# AgavePy (from source/branch)
# Clone and install repo
RUN git clone https://github.com/TACC/agavepy \
    && cd agavepy \
    && git fetch --all && \
    git checkout ${AGAVEPY_BRANCH} && \
    pip install --quiet --upgrade -e .

WORKDIR /home

# RUN git clone https://github.com/TACC-Cloud/agave-cli \
#     && cd agave-cli \
#     && git fetch --all && \
#     git checkout ${CLI_BRANCH}

# WORKDIR /home/agave-cli

COPY bin /home/bin
COPY completion/agave-cli /etc/bash_completion.d/agave-cli
COPY etc /home/etc
ENV PATH $PATH:/home/bin
ENV HOME /home
ENV TAPIS_CLI_BRANCH=${CLI_BRANCH}
ENV AGAVEPY_BRANCH=${AGAVEPY_BRANCH}
ENV TAPIS_CACHE_DIR=/home/.agave
ENV AGAVE_CACHE_DIR=/home/.agave

WORKDIR /work

# Set command prompt
RUN echo 'source /home/etc/.dockerprompt' >> /home/.bashrc

CMD ["/bin/bash"]
