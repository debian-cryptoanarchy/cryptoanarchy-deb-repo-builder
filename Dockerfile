FROM debian:buster

LABEL repository="https://github.com/debian-cryptoanarchy/cryptoanarchy-deb-repo-builder"

ENV DEBIAN_FRONTEND=noninteractive

RUN echo 'APT::Get::Assume-Yes "true";' >> /etc/apt/apt.conf.d/90assumeyes

COPY tests/data/microsoft_key.gpg /tmp/
COPY tests/data/microsoft_apt.list /tmp/

RUN apt-get update && apt-get dist-upgrade && \
    apt-get install apt-utils && \
    apt-get install wget cargo npm git apt-transport-https \
    ruby-mustache dirmngr sudo libvips-dev ca-certificates gpg \
    systemd systemd-sysv net-tools netcat xxd && \
    update-ca-certificates && \
    mv /tmp/microsoft_apt.list /etc/apt/sources.list.d/microsoft.list && \
    apt-key add < /tmp/microsoft_key.gpg && \
    apt-get update && \
    cargo install --root /usr/local --locked --git https://github.com/Kixunil/debcrafter && \
    cargo install --root /usr/local --locked cfg_me && \
    apt-get autoremove && apt-get clean && \
    rm -rf /root/.cargo \
    /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
    /lib/systemd/system/systemd-update-utmp* \
    /usr/sbin/policy-rc.d

RUN adduser --disabled-password user && echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER user
RUN mkdir -p ~/.gnupg/private-keys-v1.d && \
    chmod 700 ~/.gnupg/private-keys-v1.d
USER root

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/lib/systemd/systemd"]
