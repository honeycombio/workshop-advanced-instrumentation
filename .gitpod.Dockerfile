FROM gitpod/workspace-full

USER root

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y
RUN apt-get install -y wget gnupg2 inotify-tools locales && \
  locale-gen en_US.UTF-8

# RUN wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb && dpkg -i erlang-solutions_2.0_all.deb

# RUN apt-get update -y
# RUN apt-get install -y esl-erlang 
# RUN apt-get install -y elixir
# RUN apt-get install -y erlang-diameter
# RUN apt-get install -y rebar
# RUN mix local.hex --force
# RUN mix local.rebar --force
