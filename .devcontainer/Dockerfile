FROM mcr.microsoft.com/devcontainers/base:ubuntu

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        nano \
        vim \
        neovim \
        openssh-client \
        openssh-server \
        procps \
    && rm -rf /var/lib/apt/lists/*

RUN ssh-keygen -A

RUN curl -sSf https://sshx.io/get | sh

COPY .devcontainer/entrypoint.sh /usr/local/bin/devcontainer-entrypoint.sh
RUN chmod +x /usr/local/bin/devcontainer-entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/usr/local/bin/devcontainer-entrypoint.sh"]
CMD ["sleep", "infinity"]
