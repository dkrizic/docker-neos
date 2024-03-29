FROM ubuntu:20.10
RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y apache2 libapache2-mod-php php7.4-cli php-zip php-xml php-mbstring php-mysql php-gd php-gd php-gmagick unzip curl  \
  && curl -sS https://getcomposer.org/installer | php \
  && mv composer.phar /usr/local/bin/composer
WORKDIR /var/www/html
RUN composer create-project neos/neos-base-distribution neoscms
RUN a2enmod rewrite
WORKDIR /
RUN chown -R www-data:www-data /var/www/html/neoscms/
RUN chmod -R 755 /var/www/html/neoscms/
COPY conf/ /
RUN a2dissite 000-default
ENTRYPOINT [ "/bin/bash", "-c", "a2ensite neoscms && service apache2 restart && while true; do sleep 30; done" ]

