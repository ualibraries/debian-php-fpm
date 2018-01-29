#
# Debian9 (stretch) + shibboleth 2.6
#
# Ideas were taken from https://hub.docker.com/r/josefcs/debian-apache/~/dockerfile/
#

# Pull base image
FROM debian:stretch

# From https://hub.docker.com/_/debian/
# Set utf8 support by default 
ENV LANG=C.UTF-8

# Make apt-get commands temporarily non-interactive
# Solution from https://github.com/phusion/baseimage-docker/issues/58
# Update apt cache to use fastest local mirror
RUN \
export DEBIAN_FRONTEND=noninteractive && \
export DEBCONF_NONINTERACTIVE_SEEN=true && \
apt-get update && \
apt-get install -y procps apt-utils less nano emacs-nox curl netcat-openbsd mariadb-client ssmtp php-fpm php-mysql && \
apt-get clean

# Enable directory colors:
RUN \
sed -i "s/^# export LS/export LS/g" /root/.bashrc && \
sed -i "s/^# eval/eval/g" /root/.bashrc && \
sed -i "s/^# alias l/alias l/g" /root/.bashrc

# Fix error that occurs with directory colors enabled
ENV SHELL /bin/bash

# Make sure _shibd:_shibd permissions on directories we might tmp mount
RUN \
mkdir -p /var/log/php-fpm && \
touch /var/log/php-fpm/php7.0-fpm.log && \
chown -R www-data.www-data /var/log/php-fpm

#COPY fpm/conf.d/site.conf /etc/php/7.0/fpm/conf.d
COPY fpm/php-fpm.conf /etc/php/7.0/fpm
COPY fpm/pool.d/www.conf /etc/php/7.0/fpm/pool.d

EXPOSE 9000

VOLUME [ "/etc/php", "/var/log/php-fpm" ]

# Autostart service
CMD ["/usr/sbin/php-fpm7.0", "-F", "--fpm-config", "/etc/php/7.0/fpm/php-fpm.conf" ]
