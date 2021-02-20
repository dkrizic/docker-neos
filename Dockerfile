FROM arm64v8/ubuntu:latest
RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y apache2 libapache2-mod-php php7.4-cli php-zip php-xml php-mbstring php-mysql php-gd php-gd php-gmagick unzip curl  \
  && curl -sS https://getcomposer.org/installer | php \
  && mv composer.phar /usr/local/bin/composer
WORKDIR /var/www
RUN composer create-project neos/neos-base-distribution neos
RUN rm -rf html
RUN ln -s neos/Web html
RUN a2enmod rewrite
WORKDIR /
COPY conf/ /
CMD service apache2 start && while true; do sleep 30; done
