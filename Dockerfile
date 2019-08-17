#
# docker build --build-arg=COMMIT=$(git rev-parse --short HEAD) \
# --build-arg=BRANCH=$(git name-rev --name-only HEAD) -t akiko/redmine_banner:latest .
#
#
FROM ruby:2.5
LABEL maintainer="AKIKO TAKANO / (Twitter: @akiko_pusu)" \
  description="Image to run Redmine simply with sqlite to try/review plugin."

ARG BRANCH="master"
ARG COMMIT="unknown"

ENV COMMIT_SHA=${COMMIT}
ENV COMMIT_BRANCH=${BRANCH}


### get Redmine source
### Replace shell with bash so we can source files ###
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

### install default sys packeges ###

RUN apt-get update
RUN apt-get install -qq -y --no-install-recommends \
    git vim subversion      \
    sqlite3 && rm -rf /var/lib/apt/lists/*

RUN cd /tmp && svn co http://svn.redmine.org/redmine/branches/4.0-stable/ redmine
WORKDIR /tmp/redmine

COPY . /tmp/redmine/plugins/redmine_banner/

# add database.yml (for development, development with mysql, test)
RUN echo $'test:\n\
  adapter: sqlite3\n\
  database: /tmp/data/redmine_test.sqlite3\n\
  encoding: utf8mb4\n\
development:\n\
  adapter: sqlite3\n\
  database: /tmp/data/redmine_development.sqlite3\n\
  encoding: utf8mb4\n'\
>> config/database.yml

RUN gem update bundler
RUN bundle install --without postgresql rmagick mysql
RUN bundle exec rake db:migrate && bundle exec rake redmine:plugins:migrate \
  && bundle exec rake generate_secret_token
RUN VERSION=$(cd plugins/redmine_banner && git rev-parse --short HEAD) && \
  bundle exec rails runner \
  "Setting.send('plugin_redmine_banner=', {enable: 'true', type: 'info', display_part: 'both', banner_description: 'This is a test message for Global Banner. (${COMMIT_BRANCH}:${COMMIT_SHA})'}.stringify_keys)"

EXPOSE  3000
CMD ["rails", "server", "-b", "0.0.0.0"]
