FROM ruby:3.2.2

ADD . /vehicles-service

WORKDIR /vehicles-service
RUN bundle install

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]