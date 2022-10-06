ARG TAG
FROM ruby:${TAG}
COPY Gemfile Gemfile.lock inoculate.gemspec ./
COPY lib/inoculate/version.rb ./lib/inoculate/
RUN bundle install
