FROM arm64v8/ubuntu:latest
RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y php7.4-cli php-zip php-xml php-mbstring php-mysql unzip curl  \
  && curl -sS https://getcomposer.org/installer | php \
  && mv composer.phar /usr/local/bin/composer
RUN composer create-project neos/neos-base-distribution neos-example
