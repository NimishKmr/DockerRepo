FROM centos:7

LABEL name="Nimish CentOS 7.4 + PHP 7.2 Image" \
    maintainer="NimishKumar" \
    build-date="20210625"

# update yum
RUN yum clean all; yum -y update --nogpgcheck
RUN yum -y install yum-utils

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm; \
    rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm; \
    yum-config-manager --enable remi-php72

# Install some must-haves
RUN yum -y install --nogpgcheck \
    epel-release \
    wget \
    crontabs \
        sudo

RUN yum -y install \
    php \
    php-bcmath \
    php-cli \
    php-curl \
    php-devel \
    php-gd \
    php-fpm \
    php-intl \
    php-mbstring \
    php-mcrypt \
    php-mysqlnd \
        php-mysql \
        php-json \
        php-iconv \
        php-soap \
    php-opcache --nogpgcheck \
    php-pdo \
    php-xml \
	php-posix \
    php-zip

RUN adduser nginx
RUN mkdir -p /var/www/vhosts/rc_preprod/project_folder/rc-m2-preprod-31
RUN mkdir -p /var/www/vhosts/rc_preprod/project_data/
RUN mkdir -p /var/www/vhosts/rcnewdev/project_folder/
RUN mkdir -p /var/www/vhosts/rcnewdev/project_data/
RUN chown -R nginx:nginx /var/www/vhosts/ && chmod -R 755 /var/www/vhosts/

RUN cp jenkins-rc-m2-prod-build-preprod-31-codebase.tar.gz /var/www/vhosts/rc_preprod/project_folder/rc-m2-preprod-31
RUN cp env.php /var/www/vhosts/rc_preprod/project_data/env.php
RUN gunzip -d /var/www/vhosts/rc_preprod/project_folder/rc-m2-preprod-31/jenkins-rc-m2-prod-build-preprod-31-codebase.tar.gz
RUN tar -xvf /var/www/vhosts/rc_preprod/project_folder/rc-m2-preprod-31/jenkins-rc-m2-prod-build-preprod-31-codebase.tar
RUN ln -sf /var/www/vhosts/rc_preprod/project_folder/rc-m2-preprod-31 /var/www/vhosts/rc_preprod/current
RUN ln -sf /var/www/vhosts/rc_preprod/project_data/env.php /var/www/vhosts/rc_preprod/current/app/etc/env.php

#Cron
RUN sed -i -e '/pam_loginuid.so/s/^/#/' /etc/pam.d/crond

#Add your cron file
ADD cron /etc/cron.d/rc_preprod
RUN chmod 0644 /etc/cron.d/rc_preprod

#This will add it to the cron table (crontab -e)
RUN crontab /etc/cron.d/rc_preprod

CMD crond && tail -f /dev/null
