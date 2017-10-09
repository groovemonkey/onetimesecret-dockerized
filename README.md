# Intro
This is a dockerized version of delano's [onetimesecret application](https://github.com/onetimesecret/onetimesecret). The application hasn't been updated in a while and relies on an old version of Ruby (1.9.3), which we compile and install as part of this Docker image build.

I'm afraid some of the other Gems that this application uses are quite old, too. If I manage to find the time to renovate things a bit, I'll open a PR with the original author.


# 1. Configure This.

## edit onetime.conf

- add domain name that you want to run under
- add sendgrid or SMTP credentials
- modify the :limits: config
- the 'incoming' config, if you want onetimesecret to receive secrets


## edit redis.conf

- use the password you want
- use a TCP socket, if you like (not sure if this is working, see TODO below)



# 2. Build This.

Just cd to this project directory and run

    docker build -t onetimesecret .


# 2a. (optional) Inspect the resulting docker image and experiment

    run -it onetimesecret:latest /bin/bash


# 3. Actually Run This.

    docker run -d -p 80:80 onetimesecret



# TODO:

- log to stdout/stderr (redis.conf and...somehow...the ruby app?)

## Reduce container size
Use jessie-slim (or another, more minimal base -- 1GB is ridiculous), and use a temporary build container so we don't ship all the build dependencies.


## redis unix sockets not supported?
NoMethodError: undefined method serverid for #<URI::Generic:0x00000000032a3a98>

## run as a separate 'ots' user?
- use ots' $HOME as the WORKDIR?
- RUN chown ots /etc/onetime /var/log/onetime /var/run/onetime /var/lib/onetime

## Upgrade to a newer version of Ruby and gem dependencies
FIX with newer versions of ruby (2.3) + up-to-date gems:

- Install v 1.3.0 of yajl-ruby, otherwise there's an error

- In 2.4, Fixnum and Bignum are just part of the Integer class, and new versions of the gibbler gem will cause errors
- FROM ruby:2.3-jessie

    RUN sed -i "s|require 'gibbler'|require 'gibbler/mixins'|g" /root/onetimesecret/lib/onetime.rb

    # Create a Gemfile.override with newer gems, remove the super ancient lockfile
    COPY ./Gemfile.override /root/onetimesecret/Gemfile
    RUN rm Gemfile.lock && bundle install --without dev
