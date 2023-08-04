FROM ruby:3.2-bullseye

RUN gem install bundler

WORKDIR /app

COPY . .
RUN bundle install
