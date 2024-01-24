FROM gitpod/workspace-full

USER root

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y
RUN apt-get install -y wget gnupg2 inotify-tools locales && \
  locale-gen en_US.UTF-8

USER gitpod

RUN bash -c ". /home/gitpod/.sdkman/bin/sdkman-init.sh && \
    sdk install java 21.0.2-zulu && \
    sdk default java 21.0.2-zulu \

