FROM ruby:2.3
RUN apt-get update && apt-get -y install build-essential libpq-dev nodejs
RUN gem install bundler
RUN mkdir /sapi
WORKDIR /sapi
ADD Gemfile /sapi/Gemfile
ADD Gemfile.lock /sapi/Gemfile.lock
RUN bundle install

ADD . /sapi
