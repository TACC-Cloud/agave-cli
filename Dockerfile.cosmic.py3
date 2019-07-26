FROM ubuntu:cosmic

ARG CLI_BRANCH=master
ARG CLI_VERSION=3.x.y
ARG AGAVEPY_BRANCH=master
ARG PYTHON_PIP_VERSION=19.2.1
ARG PYTHON_VIRTUALENV_VERSION=16.7.0

LABEL org.label-schema.vendor = "Texas Advanced Computing Center"
LABEL org.label-schema.name = "TACC Tapis CLI Base"
LABEL org.label-schema.vcs-url = "https://github.com/TACC-Cloud/agave-cli"
LABEL org.label-schema.organization=tacc.cloud
LABEL cloud.tacc.project="Tapis CLI"

# In-container volume mounts
# (For containers launched using TACC.cloud SSO identity)
ARG CORRAL=/corral
ARG STOCKYARD=/work

# Dependencies
RUN apt-get -y update && \
    apt-get -y install --no-install-recommends \
    apt-utils bash curl dialog git vim rsync && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# jq for parsing JSON
RUN curl -L -sk -o /usr/local/bin/jq "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64" \
    && chmod a+x /usr/local/bin/jq

RUN apt-get -y update && \
    apt-get -y install --no-install-recommends \
    python3 \
    python3-pip \
    python3-setuptools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Make python3 the default user python
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10
RUN pip3 install --quiet --upgrade pip==${PYTHON_PIP_VERSION}
RUN pip3 install --quiet --upgrade virtualenv==${PYTHON_VIRTUALENV_VERSION}

# Make pip behave better
COPY pip.conf /etc/pip.conf

# Force locale to UTF-8
RUN apt-get update && \
    apt-get install -y locales locales-all && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN mkdir -p /home
RUN mkdir -p /work
RUN mkdir -p /install

WORKDIR /work
