# Docker container for Neos CMS

See http://neos.io for more details.

This Docker image is multi architecture. Supported archtictures include:

* amd64 ("normal PC)
* arm64 (Raspberry Pi 4 or newer running "real" OS like Ubuntu)

Further architectures on request.

## Sources

* Source Code https://github.com/dkrizic/docker-neos
* Docker images https://hub.docker.com/repository/docker/dkrizic/neos/

## Installation

I am using the Docker image on a hybrid Kubernetes cluster so I prepared

* This Docker image
* A Helm chart

This allows the installation of Observium on Kubernetes and expose it using an Ingress Controller.

### Requirements

* A Kubernetes cluster with amd64 or arm64 nodes (or any combination of that)
* An installed Ingress Controller

### Helm Chart

I created a Helm Chart for deploying Observium into a Kubernetes cluster which can be found here https://github.com/dkrizic/charts/tree/main/charts/observium

### Preparation

Create namespace using

```
kubectl create namespace neos
```

### Install MariaDB

Create a configuration file mariadb.yaml

```
userDatabase:
  name: neos
  user: neos
  password: secret
  rootPassword: neos
storage:
  requestedSize: 1Gi
nodeSelector:
  kubernetes.io/arch: arm64
```

Change accordingly to you environment. The run

```
helm repo add groundhog2k https://groundhog2k.github.io/helm-charts/
helm repo update
helm -n neos upgrade --install neos-mariadb -f mariadb.yaml groundhog2k/mariadb
```

You should now have MariaDB up an running with is available as mysql://neos-mariadb:3306 inside the cluster which has a database observium preconfigured.

### Install Neos

Create a configuration file neos.yaml

```
ingress:
  enabled: true
  annotations:
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "360"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "360"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "360"
    nginx.ingress.kubernetes.io/proxy-body-size: 100m
    nginx.ingress.kubernetes.io/client-body-buffer-size: 100m
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
  hosts:
    - host: neos.example.com
      paths:
      - path: "/"
nodeSelector:
  kubernetes.io/arch: arm64
database:
  username: neos
  password: secret
  hostname: neos-mariadb
  name: neos
neos:
  settings:
    Neos:
      Flow:
        http:
          trustedProxies:
            proxies: '*'
            headers:
              clientIp: 'X-Forwarded-For'
              host: 'X-Forwarded-Host'
              port: 'X-Forwarded-Port'
              proto: 'X-Forwarded-Proto'
      Imagine:
        driver: Gmagick
  sites:
    neoscms: |-
      <VirtualHost *:80>
           ServerAdmin admin@example.com
           DocumentRoot /var/www/html/neoscms/Web
           ServerName neos.example.com
  
           ErrorLog ${APACHE_LOG_DIR}/neos_error.log
           CustomLog ${APACHE_LOG_DIR}/neos_access.log combined
  
           <Directory /var/www/html/neoscms/Web/>
              Options FollowSymlinks
              AllowOverride All
              Require all granted
              RewriteEngine on
              RewriteBase /
              RewriteCond %{REQUEST_FILENAME} !-f
              RewriteRule ^(.*) index.php [PT,L]
          </Directory>
  
      </VirtualHost>
```

Note that the entries unter database must match the entries from MariaDB in order to connect property. Also change the hostname to your own hostname. 
In this case Neos should be available as https://neos.example.com. Now run

```
helm repo add dkrizic https://dkrizic.github.io/charts
helm repo update
helm -n neos upgrade --install neos -f neos.yaml dkrizic/neos
```
to install Neos. Enjoy.

## Changelog

* 2021-05-24: First version, contains Neos 7.1.0

