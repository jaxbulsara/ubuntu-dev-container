FROM ubuntu:jammy

SHELL ["/bin/bash", "-c"]

# Arguments
ARG user=jaxbulsara
ARG home=/home/${user}
ARG timezone=America/New_York
ARG python_version=3.10.4

# Set timezone 
ENV TZ=${timezone}
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

# Install environment dependencies
RUN apt update && \
    apt install -y \
    # system
    sudo \
    # git
    git \
    # pyenv
    libedit-dev \
    # python
    make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
    libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils tk-dev libxml2-dev \
    libxmlsec1-dev libffi-dev liblzma-dev

# Create user
RUN useradd -rm -s /bin/bash -g root -G sudo ${user} \
    # set default password
    && echo ${user}:ubuntu | chpasswd

# Set user
USER ${user}
WORKDIR /home/${user}

# Configure shell prompt to use WSL2 Ubuntu style
RUN echo 'export PS1="\[\e]0;\u@\h: \w\a\]\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$"' >> ~/.bashrc

# Configure git
RUN git config --global user.email "jaxbulsara@gmail.com"
RUN git config --global user.name "Jay Bulsara"
RUN git config --global credential.helper store

# Install pyenv
ENV PYENV_ROOT=/home/${user}/.pyenv
ENV PATH=${PYENV_ROOT}/bin:$PATH

RUN curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
RUN exec $SHELL

RUN pyenv init --path
RUN pyenv init -

# Configure environment for pyenv
RUN sed -Ei \
    -e '/^([^#]|$)/ {a export PYENV_ROOT="$HOME/.pyenv" \nexport PATH="$PYENV_ROOT/bin:$PATH"\n' \
    -e ':a' \
    -e '$!{n;ba};}' ~/.profile
RUN echo 'eval "$(pyenv init --path)"' >> ~/.profile
RUN echo 'eval "$(pyenv init -)"' >> ~/.bashrc

# Install python
RUN pyenv install ${python_version}
RUN pyenv global ${python_version}

# Switch to root for additional python setup
USER root
# Alias python to python3
RUN echo 'ubuntu' | sudo ln -s /usr/bin/python3 /usr/bin/python

# Install pip
RUN apt install -y python3-pip python3.10-venv

# Switch back to user
USER ${user}

# Install poetry
ENV POETRY_HOME=/home/${user}/.poetry
ENV PATH=${POETRY_HOME}/bin:$PATH
RUN curl -sSL https://install.python-poetry.org | python -