FROM docker:1.10-dind
MAINTAINER nasuno@ascade.co.jp

RUN apk add --no-cache --update \
    bash \
    ca-certificates \
    openssh \
    supervisor \
    build-base \
    ruby \
    ruby-irb \
    ruby-dev \
  && echo 'gem: --no-document' >> /etc/gemrc \
  && gem install fluentd -v 0.12.22 \
  && apk del build-base ruby-dev

RUN wget https://releases.hashicorp.com/serf/0.7.0/serf_0.7.0_linux_amd64.zip \
  && unzip serf_*.zip -d /usr/local/bin/ \
  && rm serf_*.zip

RUN mkdir -p /var/run/sshd \
  && ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa \
  && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \
  && echo "Port 10022" >> /etc/ssh/sshd_config \
  && echo "root:root" | chpasswd

COPY supervisord.conf /etc/supervisor.d/vcpbase.ini

# alpine-pkg-glibc <https://github.com/andyshinn/alpine-pkg-glibc>
RUN wget -O /etc/apk/keys/andyshinn.rsa.pub \
    https://raw.githubusercontent.com/andyshinn/alpine-pkg-glibc/master/andyshinn.rsa.pub \
  && wget https://github.com/andyshinn/alpine-pkg-glibc/releases/download/2.23-r1/glibc-2.23-r1.apk \
  && wget https://github.com/andyshinn/alpine-pkg-glibc/releases/download/2.23-r1/glibc-bin-2.23-r1.apk \
  && wget https://github.com/andyshinn/alpine-pkg-glibc/releases/download/2.23-r1/glibc-i18n-2.23-r1.apk \
  && apk add --no-cache glibc*.apk \
  && /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true \
  && echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh \
  && apk del glibc-i18n \
  && rm -f /etc/apk/keys/andyshinn.rsa.pub glibc-*.apk \
ENV LANG=C.UTF-8

CMD ["/usr/bin/supervisord"]

