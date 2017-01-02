# Runs a DPRIVE (RFC 7858) nameserver by running BIND behind NGINX TLS proxy.

FROM ubuntu:latest
MAINTAINER Warren Kumari <warren@kumari.net> Version 0.3

# Install Nginx and ISC BIND
RUN \
  apt-get update \
  && apt-get install -y software-properties-common \
  && add-apt-repository -y ppa:nginx/stable \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq nginx bind9 bind9-host dnsutils vim \
  && rm -rf /var/lib/apt/lists/*


# Copy the base config files
COPY files/named.conf /etc/named.conf
COPY files/rndc.key /etc/rndc.key
COPY files/rndc.conf /etc/bind/rndc.conf
COPY files/nginx.conf /etc/nginx/nginx.conf

# and my startup script.
COPY files/entrypoint.sh /sbin/entrypoint.sh

# I used to mount various volumes so that I can more easily expose things
# like statistics, etc. This violates the container ethos and so I now just
# copy things into the container.
COPY files/config /


# Make sure they are owned by the right users, and make my BIND dirs.
RUN \
       chown -R www-data:www-data /var/lib/nginx \
    && chmod 755 /sbin/entrypoint.sh \
    &&   mkdir -m 0775 -p /var/run/named \
    && chown root:bind /var/run/named  \
    && mkdir -m 0775 -p /var/named/data \
    && chown root:bind /var/named

# Remove the default / package rndc.key file
RUN rm /etc/bind/rndc.key

# Define mountable directories.
# /etc/nginx is for things like nginx configs, including certificates
# /var/log/nginx is for logs.
# /var/data/bind is random bind data
#VOLUME ["/etc/nginx/certificates", "/var/log/nginx", "/var/named"]

# Expose ports.
# I run DPRIVE on both the "official" port (853) and also 443 as a proof of concept.
EXPOSE 853 443

# Define working directory.
WORKDIR /etc/nginx

ENTRYPOINT ["/sbin/entrypoint.sh"]


