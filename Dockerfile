FROM local_discourse/web_only:latest

# 切换为root用户卸载安装调试工具
# USER root
ENV DEBIAN_FRONTEND=noninteractive

# # 卸载 sudo
# RUN apt-get update   
# RUN apt-get autoremove -y 
# RUN apt-get clean 
# RUN rm -rf /var/lib/apt/lists/*

# # 卸载安装工具
# RUN apt-get update \
#  && apt-get purge -y --auto-remove \
#       tcpdump \
#       nmap \
#       wireshark-common \
#       netcat-openbsd \
#       gdb \
#       strace \
#       binutils \
#       build-essential \
#       cmake \
#       flex \
#       libtool \
#       php-cli \
#       python3-dbg \
#  && rm -f \
#       /usr/bin/tcpdump      \
#       /usr/bin/nmap          \
#       /usr/bin/wireshark*    \
#       /usr/bin/netcat        \
#       /usr/bin/gdb           \
#       /usr/bin/strace        \
#       /usr/bin/readelf       \
#       /usr/bin/cpp           \
#       /usr/bin/gcc           \
#       /usr/bin/make          \
#       /usr/bin/objdump       \
#       /usr/bin/ar            \
#       /usr/bin/ld            \
#       /usr/bin/flex          \
#       /usr/bin/lex           \
#       /usr/bin/rpcgen        \
#       /usr/bin/cmake         \
#  && apt-get clean \
#  && rm -rf /var/lib/apt/lists/*

# 卸载 sudo
RUN apt-get update && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* && \
  # 卸载安装工具
  apt-get update \
  && apt-get purge -y --auto-remove \
  tcpdump \
  nmap \
  wireshark-common \
  netcat-openbsd \
  gdb \
  strace \
  binutils \
  build-essential \
  cmake \
  flex \
  libtool \
  php-cli \
  python3-dbg \
  && rm -f \
  /usr/bin/tcpdump      \
  /usr/bin/nmap          \
  /usr/bin/wireshark*    \
  /usr/bin/netcat        \
  /usr/bin/gdb           \
  /usr/bin/strace        \
  /usr/bin/readelf       \
  /usr/bin/cpp           \
  /usr/bin/gcc           \
  /usr/bin/make          \
  /usr/bin/objdump       \
  /usr/bin/ar            \
  /usr/bin/ld            \
  /usr/bin/flex          \
  /usr/bin/lex           \
  /usr/bin/rpcgen        \
  /usr/bin/cmake         \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* &&\
  # 设置目录权限
  mkdir -p /shared/state/logrotate && ln -s /shared/state/logrotate /var/lib/logrotate && \
  mkdir -p /shared/state/anacron-spool && ln -s /shared/state/anacron-spool /var/spool/anacron && \
  mkdir -p /shared/log/rails && mkdir -p /shared/uploads && mkdir -p /shared/backups && \
  rm -rf /shared/tmp/{backups,restores} && mkdir -p /shared/tmp/{backups,restores} && \
  chown -R discourse:www-data /etc/runit/1.d && \
  chown -R discourse:www-data /etc/service && \
  chmod -R 755 /etc/service && \
  rm -f /etc/runit/1.d/00-fix-var-logs && \
  rm -rf /etc/service/rsyslog /etc/service/cron /etc/service/anacron &&\
  mkdir -p /var/log/nginx && \
  chown -R www-data:www-data /var/log/nginx && \
  chmod -R 755 /var/log/nginx && \
  touch /var/log/syslog   && chown -f discourse:www-data /var/log/syslog* && \
  touch /var/log/auth.log && chown -f discourse:www-data /var/log/auth.log* && \
  touch /var/log/kern.log && chown -f discourse:www-data /var/log/kern.log* && \
  chown -R discourse:www-data /var/www/discourse && \
  chown -R discourse:www-data /shared && \
  chown -R discourse:www-data /var/log && \
  chown -R discourse:www-data /var/lib && \
  chown -R discourse:www-data /var/run && \
  chown -R discourse:www-data /run && \
  chown -R discourse:www-data /tmp && \
  chown -R discourse:www-data /dev && \
  chown -R discourse:www-data /var/spool && \
  sed -i "s|root|discourse|g" /etc/rsyslog.conf && \
  sed -i "s|adm|www-data|g" /etc/rsyslog.conf && \
  sed -i '2i cd /var/www/discourse' /etc/service/unicorn/run && \
  sed -i "s|www-data|discourse|g" /etc/nginx/nginx.conf && \
  echo "umask 0027" >> /etc/bashrc && \
  echo "set +o history" >> /etc/bashrc && \
  sed -i "s|HISTSIZE=1000|HISTSIZE=0|" /etc/profile && \
  chage --maxdays 30 discourse && \
  passwd -| discourse && \
  usermod -s /sbin/nologin sync && \
  # 插入证书路径
  sed -i 's/server {/server {\
  listen 8080;\
  listen 443 ssl http2;\
  ssl_certificate     \/etc\/nginx\/certs\/discourse.crt;\
  ssl_certificate_key \/etc\/nginx\/certs\/discourse.key;\
  ssl_protocols       TLSv1.2;\
  ssl_prefer_server_ciphers on;\
  ssl_ciphers         HIGH:!aNULL:!MD5;/' \
  /etc/nginx/conf.d/discourse.conf && \
  cat /etc/nginx/conf.d/discourse.conf && \
  # 修正 /etc/nginx 下所有目录和文件的属主与权限
  chown -R discourse:www-data /etc/nginx && \
  find /etc/nginx -type d -exec chmod 550 {} \; && \
  find /etc/nginx -type f -name '*.conf' -exec chmod 640 {} \; && \
  find /etc/nginx/sites-available /etc/nginx/sites-enabled /etc/nginx/snippets -type f -exec chmod 640 {} \; && \
  # 对 /var 下目录做按需属主和权限调整
  chown discourse:www-data /var/backups /var/log /var/nginx /var/www/discourse \
  && chmod 750 /var/backups /var/log /var/nginx /var/www/discourse \
  \
  && chmod 550 /var/cache /var/lib /var/local /var/spool /var/mail /var/opt \
  \
  && find /var/www/discourse /var/backups /var/log /var/nginx -type f -exec chmod 640 {} \; \
  \
  && find /var/www/discourse/vendor/bundle/ruby/3.3.0/bin -type f -exec chmod 755 {} \; \
  \
  && find /var/www/discourse -type d -exec chmod 755 {} \; && chmod 755 /var/www/discourse/config/unicorn_launcher\
  \
  && find /var/cache /var/lib /var/local /var/spool /var/mail /var/opt -type f -exec chmod 440 {} \; && \
  # 修复 /var/local、/var/mail、/var/www/html 下残余 root 属主
  chown -R discourse:www-data /var/local /var/mail /var/www/html && \
  chown -R discourse:www-data /etc/ssl/certs && \
  find /var/local /var/mail /var/www/html -type d -exec chmod 750 {} \; && \
  find /var/local /var/mail /var/www/html -type f -exec chmod 640 {} \; && \
  # 删除任何已有的 history 文件
  rm -f /root/.bash_history /home/discourse/.bash_history && \
  { \
  echo ''; \
  echo '# Disable Bash history for security'; \
  echo 'set +o history'; \
  echo 'export HISTFILE=/dev/null'; \
  echo 'export HISTSIZE=0'; \
  echo 'export HISTFILESIZE=0'; \
  } >> /etc/profile && \
  # 确保 Discourse 用户也读取到
  chown root:root /etc/profile && chmod 644 /etc/profile && \
  rm -f /etc/nginx/sites-enabled/default

EXPOSE 8080

# 切换到非root用户
USER discourse

# 保留原有的ENTRYPOINT和CMD
ENTRYPOINT ["/sbin/boot"]