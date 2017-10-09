# Dockerfile for building onetimesecret

FROM debian:jessie

# Install base stuff
RUN apt-get update && apt-get -y install build-essential zlib1g-dev libyaml-dev libevent-dev libssl-dev libreadline-gplv2-dev curl tar git ntp zlib1g openssl libxml2 redis-server

# Build Super-Ancient Ruby :((
RUN curl -O https://cache.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p362.tar.bz2
RUN tar xjf ruby-1.9.3-p362.tar.bz2
WORKDIR ruby-1.9.3-p362
RUN ./configure && make && make install
RUN gem install bundler

# Install the Application and its Dependencies
WORKDIR /root
RUN git clone https://github.com/onetimesecret/onetimesecret
WORKDIR /root/onetimesecret
RUN bundle install --deployment --without dev
RUN bin/ots init

# Create Application directories, add configuration
RUN mkdir /etc/onetime /var/log/onetime /var/run/onetime /var/lib/onetime
RUN cp -R etc/* /etc/onetime/

# Overwrite with your own configs (edit these before running docker build)
COPY ./onetime.conf /etc/onetime/config
COPY ./redis.conf /etc/onetime/redis.conf

EXPOSE 80

ENTRYPOINT redis-server /etc/onetime/redis.conf && bundle exec thin -e prod -R /root/onetimesecret/config.ru -p 80 start
