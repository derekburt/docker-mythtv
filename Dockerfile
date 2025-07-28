FROM ubuntu:noble

ENV CONFIG_MODE=1 

DEBIAN_FRONTEND="noninteractive" 

DISPLAY=:1 

HOME=/home/mythtv 

GROUPID=121 

LANG=en_US.UTF-8 

LANGUAGE=en_US:en 

LC_ALL=en_US.UTF-8 

TERM="xterm" 

TZ="America/Chicago" 

USERID=120

ARG MYTHTV_VERSION="35"
ARG MYTHTV_URL="https://ppa.launchpadcontent.net/mythbuntu/$MYTHTV_VERSION/ubuntu/"
ARG S6_VERSION="v3.2.1.0"
ARG S6_NOARCH_URL="https://github.com/just-containers/s6-overlay/releases/download/$S6_VERSION/s6-overlay-noarch.tar.xz"
ARG S6_ARCH_URL="https://github.com/just-containers/s6-overlay/releases/download/$S6_VERSION/s6-overlay-x86_64.tar.xz"

RUN apt-get update && apt-get install -y software-properties-common gnupg2 curl wget

RUN echo "deb ${MYTHTV_URL} noble main" > /etc/apt/sources.list.d/mythbuntu.list 

&& curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x517F4B7559621884DCD9C61960AF0EE633670609" | gpg --dearmor -o /etc/apt/trusted.gpg.d/mythbuntu.gpg 

&& apt-get update 

&& apt-get dist-upgrade -y --no-install-recommends 

-o Dpkg::Options::="--force-confold" 



&& apt-get install -y mariadb-server apt-utils locales tzdata  

git x11vnc xvfb mate-desktop-environment-core net-tools 



&& sed -i 's/3306/6506/g' /etc/mysql/mariadb.conf.d/50-server.cnf 

&& sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf 



&& echo "mythtv-common mythtv/mysql_admin_password password " | debconf-set-selections 

&& echo "mythtv-common mythtv/mysql_admin_user string root" | debconf-set-selections 

&& echo "mythtv-common mythtv/mysql_host string localhost" | debconf-set-selections 

&& echo "mythtv-common mythtv/mysql_mythtv_user string mythtv" | debconf-set-selections 

&& echo "mythtv-common mythtv/mysql_mythtv_password password mythtv" | debconf-set-selections 

&& echo "mythtv-common mythtv/mysql_appname string mythtv" | debconf-set-selections 

&& echo "mythtv-backend-master mythtv/public_bind boolean true" | debconf-set-selections 



&& apt-get install -y  

mythtv-backend-master xmltv xmltv-util 



&& wget https://nice.net.nz/scripts/tv_grab_nz-py -O /usr/bin/tv_grab_nz-py 

&& chmod a+x /usr/bin/tv_grab_nz-py 



&& cd /opt && git clone https://github.com/kanaka/noVNC.git 

&& cd noVNC/utils && git clone 

https://github.com/kanaka/websockify websockify 



&& locale-gen en_US.UTF-8 



&& curl -o /tmp/s6-noarch.tar.xz -L ${S6_NOARCH_URL} 

&& tar -Jxpf /tmp/s6-noarch.tar.xz -C / 

&& curl -o /tmp/s6-arch.tar.xz -L ${S6_ARCH_URL} 

&& tar -Jxpf /tmp/s6-arch.tar.xz -C / 

&& rm /tmp/.tar.xz 



&& apt-get clean 

&& rm -rf /var/lib/apt/lists/ /tmp/* /var/tmp/*

COPY rootfs/ /

CMD ["/init"]

VOLUME ["/home/mythtv", "/var/lib/mysql", "/var/lib/mythtv"]
