FROM local_discourse/web_only:latest
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# 设置目录权限
RUN mkdir -p /shared/state/logrotate && ln -s /shared/state/logrotate /var/lib/logrotate && \
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
    echo "umask 0027" >> /home/discourse/.bashrc && \
    echo "set +o history" >> /home/discourse/.bashrc && \
    sed -i "s|HISTSIZE=1000|HISTSIZE=0|" /home/discourse/.bashrc && \
    source /home/discourse/.bashrc && \
    chage --maxdays 30 discourse && \
    passwd -l discourse && \
    usermod -s /sbin/nologin sync && \
    # 修正 /etc/nginx 下所有目录和文件的属主与权限
    chown -R discourse:www-data /etc/nginx && \
    find /etc/nginx -type d -exec chmod 550 {} \; && \
    find /etc/nginx -type f -name '*.conf' -exec chmod 640 {} \; && \
    find /etc/nginx/sites-available /etc/nginx/sites-enabled /etc/nginx/snippets -type f -exec chmod 640 {} \; && \
    # remove sudo
    apt-get update && \
    apt-get purge -y sudo && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# 切换到非root用户
USER discourse

# 保留原有的ENTRYPOINT和CMD
ENTRYPOINT ["/sbin/boot"]