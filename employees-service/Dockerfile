FROM ruby:3.2.2

ADD . /employees-service

WORKDIR /employees-service
RUN bundle install

EXPOSE 3001

CMD ["rails", "server", "-b", "0.0.0.0"]