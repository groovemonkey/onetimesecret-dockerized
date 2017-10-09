# Dockerfile for building onetimesecret

# BUILDER

## TODO:
# Install v 1.3.0 of yajl-ruby, otherwise there's an error

# In 2.4, Fixnum and Bignum are just part of the Integer class, and new versions of the gibbler gem will cause errors
# FROM ruby:2.4-jessie

# Use Ruby 2.3 instead
FROM ruby:2.3-jessie

# Install base stuff
RUN apt-get update && apt-get -y install build-essential zlib1g-dev libyaml-dev libevent-dev libssl-dev libreadline-gplv2-dev curl tar

RUN apt-get -y install ntp zlib1g openssl libxml2

# App
RUN apt-get -y install redis-server
WORKDIR /root
RUN git clone https://github.com/onetimesecret/onetimesecret

# Old Ruby :((
RUN curl -O https://cache.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p362.tar.bz2
RUN tar xjf ruby-1.9.3-p362.tar.bz2
WORKDIR ruby-1.9.3-p362
RUN ./configure && make && make install
RUN gem install bundler

# Install App Dependencies
# COPY ./Gemfile.override /root/onetimesecret/Gemfile
WORKDIR /root/onetimesecret
RUN bundle install --deployment --without dev
# RUN rm Gemfile.lock && bundle install --without dev
RUN bin/ots init

# OTS user and directories
RUN mkdir /etc/onetime /var/log/onetime /var/run/onetime /var/lib/onetime

RUN cp -R etc/* /etc/onetime/
COPY ./onetime.conf /etc/onetime/config
COPY ./redis.conf /etc/onetime/redis.conf

EXPOSE 80

# RUN SERVICES
# redis-server /etc/onetime/redis.conf
# bundle exec thin -e prod -R config.ru -p 80 start

## ENTRYPOINT ["redis-server", "/etc/onetime/redis.conf", "&&", bundle", "exec", "thin", "-e", "prod", "-R", "/root/onetimesecret/config.ru", "-p", "80", "start",]

ENTRYPOINT redis-server /etc/onetime/redis.conf && bundle exec thin -e prod -R /root/onetimesecret/config.ru -p 80 start





