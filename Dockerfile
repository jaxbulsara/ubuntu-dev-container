# Jay's development environment

FROM ubuntu:jammy

SHELL ["/bin/bash", "-c"]

# Arguments
ARG user=jaxbulsara
ARG pass="ubuntu"
ARG user_name="Jay Bulsara"
ARG user_email="jaxbulsara@gmail.com"
ARG timezone=America/New_York
ARG python_version=3.10.4
ARG poetry_version=1.1.13

# Set timezone 
ENV TZ=${timezone}
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

# Install environment dependencies
RUN apt-get update && \
    apt-get install -y \
    # system
    sudo vim man iputils-ping \
    # git
    git \
    # pyenv
    libedit-dev \
    # python
    make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
    libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils tk-dev libxml2-dev \
    libxmlsec1-dev libffi-dev liblzma-dev \
    # pyodbc
    unixodbc unixodbc-dev freetds-dev freetds-bin tdsodbc

# Unminimize
RUN yes | unminimize

# Setup FreeTDS
COPY odbcinst.ini /etc

# Create user
RUN useradd -rm -s /bin/bash -g root -G sudo ${user} \
    # set default password
    && echo ${user}:${pass} | chpasswd

# Set default user for WSL2
RUN echo -e "[user]\ndefault=${user}" >> /etc/wsl.conf

# Set user
USER ${user}
WORKDIR /home/${user}

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
RUN echo ${pass} | sudo ln -s /usr/bin/python3 /usr/bin/python

# Install pip
RUN apt install -y python3-pip python3.10-venv

# Switch back to user
USER ${user}

# Install poetry
ENV POETRY_HOME=/home/${user}/.poetry
ENV POETRY_VERSION=${poetry_version}
ENV PATH=${POETRY_HOME}/bin:$PATH
RUN curl -sSL https://install.python-poetry.org | python -
RUN echo 'POETRY_HOME=$HOME/.poetry' >> ~/.bashrc
RUN echo 'PATH=${POETRY_HOME}/bin:$PATH' >> ~/.bashrc

# Configure git
RUN git config --global user.email ${user_email}
RUN git config --global user.name ${user_name}
RUN git config --global credential.helper store
RUN git config --global init.defaultBranch main

# Set up git prompt
RUN wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
RUN mv git-prompt.sh .git-prompt.sh
RUN source .git-prompt.sh && echo "source ~/.git-prompt.sh" >> .bashrc

# Configure shell prompt
COPY prompt.bashrc .
RUN cat prompt.bashrc >> .bashrc && rm prompt.bashrc

# Add useful aliases
COPY aliases.bashrc .
RUN cat aliases.bashrc >> .bashrc && rm aliases.bashrc

# Remove sudo instructions
RUN touch .sudo_as_admin_successful

# Configure vim
RUN mkdir -p .vim/colors
COPY .vimrc .
COPY molokai.vim .vim/colors/

