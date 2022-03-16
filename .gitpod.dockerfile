FROM gitpod/workspace-full

USER root

ENV DEBIAN_FRONTEND noninteractive

RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb \
    && dpkg -i erlang-solutions_1.0_all.deb \
    && apt-get update \
    && apt-get install esl-erlang -y \
    && apt-get install elixir -y \
    && mix local.hex --force

# More information: https://www.gitpod.io/docs/42_config_docker/
# https://github.com/gitpod-io/gitpod/issues/30#issuecomment-529876891
