FROM debian:latest
LABEL maintainer="xxy1991"
ENV container=docker

ENV pip_packages "ansible cryptography"

# Install dependencies.
COPY app/apt-cacher.sh /usr/local/bin/
RUN sh /usr/local/bin/apt-cacher.sh && rm /usr/local/bin/apt-cacher.sh

RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive \
    apt-get -yqq --no-install-recommends install \
            sudo systemd systemd-cron \
            build-essential libffi-dev libssl-dev libyaml-dev \
            wget ca-certificates \
            python3-pip python3-dev python3-setuptools python3-wheel \
            python3-apt python3-yaml \
            iproute2 && \
    rm -rf /var/lib/apt/lists/* && \
    rm -Rf /usr/share/doc && rm -Rf /usr/share/man && \
    rm -f /etc/apt/apt.conf

# Upgrade pip.
# RUN python3 -m pip install --upgrade pip

# Install Ansible via pip.
RUN python3 -m pip install $pip_packages

COPY ansible/initctl_faker .
RUN chmod +x initctl_faker && rm -fr /sbin/initctl && ln -s /initctl_faker /sbin/initctl

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# Make sure systemd doesn't start agettys on tty[1-6].
RUN rm -f /lib/systemd/system/multi-user.target.wants/getty.target

VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
CMD ["/lib/systemd/systemd"]
