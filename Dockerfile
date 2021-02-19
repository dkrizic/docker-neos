FROM arm64v8/ubuntu:latest
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y php7.4-cli


