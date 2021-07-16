# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.187.0/containers/debian/.devcontainer/base.Dockerfile

# [Choice] Debian version: buster, stretch
ARG VARIANT="buster"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

# ** [Optional] Uncomment this section to install additional packages. **
 RUN gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF \
     && gpg --export BC528686B50D79E339D3721CEB3E94ADBE1229CF | apt-key add - \
     && echo 'deb [arch=amd64,arm64,armhf] https://packages.microsoft.com/debian/10/prod buster main' > /etc/apt/sources.list.d/microsoft.list \
     && apt-get update && export DEBIAN_FRONTEND=noninteractive \
     && apt-get -y install --no-install-recommends make cargo ruby-mustache npm g++ dpkg-dev \
     && cargo install --root /usr/local/bin --locked --git https://github.com/Kixunil/debcrafter \
     && cargo install --root /usr/local/bin --locked cfg_me
