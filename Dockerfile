FROM alpine:3.8

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
#ENV lrzsz_version 0.12.20
#RUN cd ${SRC_DIR} \
#    && wget -q -O lrzsz-${lrzsz_version}.tar.gz  http://blog.sunqiang.me/lrzsz-${lrzsz_version}.tar.gz \
#    && tar -zxvf lrzsz-${lrzsz_version}.tar.gz  \
#    && cd lrzsz-${lrzsz_version} \
#    && ./configure \
#    && make \
#    && make install \
#    && ln -s /usr/local/bin/lrz /usr/bin/rz \
#    && ln -s /usr/local/bin/lsz /usr/bin/sz


#RUN echo 'http://mirrors.aliyun.com/alpine/latest-stable/main' > /etc/apk/repositories \
#	&& echo '@community http://mirrors.aliyun.com/alpine/latest-stable/community' >> /etc/apk/repositories \
#	&& echo '@testing http://mirrors.aliyun.com/alpine/edge/testing' >> /etc/apk/repositories
	
RUN echo 'http://mirrors.aliyun.com/alpine/latest-stable/main' >> /etc/apk/repositories \ 
  echo 'http://mirrors.aliyun.com/alpine/latest-stable/community' >> /etc/apk/repositories \
  apk --update add \
  php7-fpm \
  php7-pdo \
  php7-json \
  php7-openssl \
  php7-mysql \
  php7-pdo_mysql \
  php7-mcrypt \
  php7-sqlite3 \
  php7-pdo_sqlite \
  php7-ctype \
  php7-zlib \
  php7-bcmath \
  php7-dom \
  php7-ctype \
  php7-curl \
  php7-fileinfo \
  php7-fpm \
  php7-gd \
  php7-iconv \
  php7-intl \
  php7-json \
  php7-mbstring \
  php7-mcrypt \
  php7-mysqlnd \
  php7-opcache \
  php7-openssl \
  php7-pdo \
  php7-pdo_mysql \
  php7-pdo_pgsql \
  php7-pdo_sqlite \
  php7-phar \
  php7-posix \
  php7-simplexml \
  php7-session \
  php7-soap \
  php7-tokenizer \
  php7-xml \
  php7-xmlreader \
  php7-xmlwriter \
  php7-zip 
  
RUN apk add python supervisor

RUN echo -e "#!/bin/bash\n/usr/sbin/sshd -D \nnohup supervisord -c /worker/supervisor/supervisord.conf" >>/etc/start.sh

RUN mkdir -p /var/log/supervisor
EXPOSE 80 8000 9000
CMD ["/etc/start.sh"]
