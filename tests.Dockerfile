FROM python:3.7.0-stretch

RUN apt-get update -y && apt-get install -yq curl git bash-completion \
    expect netcat \
    jq && \
    git clone https://github.com/bats-core/bats-core.git && \
    (cd bats-core && ./install.sh /usr/local) && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /src/.*deb && \
    curl -L https://raw.githubusercontent.com/alejandrox1/dev_env/master/local-setup/bashrc \
    -o /root/.bashrc && \
    curl -L https://raw.githubusercontent.com/alejandrox1/dev_env/master/local-setup/bash_prompt \
    -o /root/.bash_prompt

ADD agave_mock_server/requirements.txt .
RUN pip install -r requirements.txt

WORKDIR /agave-cli
COPY . /agave-cli

ENV PATH "${PATH}:/agave-cli/bin"

CMD ["/bin/bash"]
