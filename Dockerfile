FROM docker:1.13.1-dind
LABEL maintainer "nasuno@ascade.co.jp"

RUN apk add --no-cache --update \
    bash \
    ca-certificates \
    openssh \
    supervisor \
    py2-pip \
    ansible \
    build-base \
    ruby \
    ruby-irb \
    ruby-dev \
    tcptraceroute \
    tcpdump \
  && pip install docker-py \
  && echo 'gem: --no-document' >> /etc/gemrc \
  && gem install fluentd:0.12.33 fluent-plugin-cadvisor:0.3.1 \
  && apk del build-base ruby-dev

RUN wget https://github.com/google/cadvisor/releases/download/v0.24.1/cadvisor -O /usr/local/bin/cadvisor \
  && chmod +x /usr/local/bin/cadvisor

RUN wget https://releases.hashicorp.com/serf/0.8.0/serf_0.8.0_linux_amd64.zip \
  && unzip serf*.zip -d /usr/local/bin/ \
  && rm serf*.zip

RUN mkdir -p /var/run/sshd \
  && ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa \
  && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \
  && echo "Port 10022" >> /etc/ssh/sshd_config \
  && echo "root:root" | chpasswd

COPY supervisord.conf /etc/supervisor.d/vcpbase.ini

# if aufs is available in this kernel
RUN sed -i 's/storage-driver=vfs/storage-driver=aufs/' /usr/local/bin/dockerd-entrypoint.sh

ENV LANG=C.UTF-8

CMD ["/usr/bin/supervisord"]
