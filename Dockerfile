FROM ruby:2.6.3

RUN apt-get update -qq \
    && apt-get install -y \
        postgresql-client

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y nodejs

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -\
    && echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y yarn

RUN mkdir /project
WORKDIR /project
COPY .ruby-version Gemfile Gemfile.lock /project/
RUN gem install bundler:2.0.2
RUN bundle install --jobs=4 --retry=3 --without development test --full-index

ENV PATH /opt/bin/:$PATH
COPY . /project

RUN mkdir -p /home/project && \
  useradd project -u 1001 --user-group --home /home/project && \
  chown -R project:project /project && \
  chown -R project:project /home/project

RUN RAILS_ENV=production rails assets:precompile --trace
EXPOSE 3000
