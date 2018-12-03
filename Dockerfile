FROM alpine:3.7

MAINTAINER sunny5156 <sunny5156@qq.com> 

#RUN echo "https://mirror.tuna.tsinghua.edu.cn/alpine/v3.7/main" > /etc/apk/repositories

ARG TZ="Asia/Shanghai"

ENV TZ ${TZ}

ENV WORKER /worker
ENV SRC_DIR ${WORKER}/src

RUN mkdir -p  /data/db ${WORKER}/data ${SRC_DIR}

RUN apk upgrade --update \
    && apk add curl bash tzdata openssh gcc \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
    && ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa \
    && ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa \
    && ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' \
    && ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key -N '' \
    && echo "root:123456" | chpasswd \
    && rm -rf /var/cache/apk/*
    
# -----------------------------------------------------------------------------
# Install lrzsz
# ----------------------------------------------------------------------------- 
ENV lrzsz_version 0.12.20
RUN cd ${SRC_DIR} \
    && wget -q -O lrzsz-${lrzsz_version}.tar.gz  http://blog.sunqiang.me/lrzsz-${lrzsz_version}.tar.gz \
    && tar -zxvf lrzsz-${lrzsz_version}.tar.gz  \
    && cd lrzsz-${lrzsz_version} \
    && ./configure \
    && make \
    && make install \
    && ln -s /usr/local/bin/lrz /usr/bin/rz \
    && ln -s /usr/local/bin/lsz /usr/bin/sz


RUN apk --update add \
  php-fpm \
  php-pdo \
  php-json \
  php-openssl \
  php-mysql \
  php-pdo_mysql \
  php-mcrypt \
  php-sqlite3 \
  php-pdo_sqlite \
  php-ctype \
  php-zlib \
  php-bcmath \
  php-dom \
  php-ctype \
  php-curl \
  php-fileinfo \
  php-fpm \
  php-gd \
  php-iconv \
  php-intl \
  php-json \
  php-mbstring \
  php-mcrypt \
  php-mysqlnd \
  php-opcache \
  php-openssl \
  php-pdo \
  php-pdo_mysql \
  php-pdo_pgsql \
  php-pdo_sqlite \
  php-phar \
  php-posix \
  php-simplexml \
  php-session \
  php-soap \
  php-tokenizer \
  php-xml \
  php-xmlreader \
  php-xmlwriter \
  php-zip \
  supervisor
RUN mkdir -p /var/run/php-fpm
RUN mkdir -p /var/log/supervisor
EXPOSE 80 8000 9000
CMD ["/usr/bin/supervisord"]
