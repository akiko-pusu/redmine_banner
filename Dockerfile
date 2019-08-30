#
# docker build --build-arg=COMMIT=$(git rev-parse --short HEAD) \
# --build-arg=BRANCH=$(git name-rev --name-only HEAD) -t akiko/redmine_banner:latest .
#
#
FROM ruby:2.5
LABEL maintainer="AKIKO TAKANO / (Twitter: @akiko_pusu)" \
  description="Image to run Redmine simply with sqlite to try/review plugin."

ARG BRANCH="master"
ARG COMMIT="commit_sha"

ENV COMMIT_SHA=${COMMIT}
ENV COMMIT_BRANCH=${BRANCH}

RUN mkdir /app

### get Redmine source
### Replace shell with bash so we can source files ###
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

### install default sys packeges ###

RUN apt-get update
RUN apt-get install -qq -y --no-install-recommends \
    git vim subversion      \
    sqlite3 && rm -rf /var/lib/apt/lists/*

RUN cd /app && svn co http://svn.redmine.org/redmine/branches/4.0-stable/ redmine
WORKDIR /app/redmine

COPY . /app/redmine/plugins/redmine_banner/

WORKDIR /app/redmine/plugins
RUN git clone https://github.com/ishikawa999/redmine_message_customize.git

WORKDIR /app/redmine/public/themes
RUN git clone https://github.com/akiko-pusu/redmine_theme_kodomo.git

WORKDIR /app/redmine

# add database.yml (for development, development with mysql, test)
RUN echo $'test:\n\
  adapter: sqlite3\n\
  database: /app/data/redmine_test.sqlite3\n\
  encoding: utf8mb4\n\
development:\n\
  adapter: sqlite3\n\
  database: /app/data/redmine_development.sqlite3\n\
  encoding: utf8mb4\n'\
>> config/database.yml

RUN gem update bundler
RUN bundle install --without postgresql rmagick mysql
RUN bundle exec rake db:migrate && bundle exec rake redmine:plugins:migrate \
  && bundle exec rake generate_secret_token
RUN bundle exec rails runner \
  "Setting.send('plugin_redmine_banner=', {enable: 'true', type: 'info', display_part: 'both', banner_description: 'This is a test message for Global Banner. (${COMMIT_BRANCH}:${COMMIT_SHA})'}.stringify_keys)"

# Change Admin's password to 'redmine_banner_${COMMIT_SHA}'
# Default is 'redmine_banner_commit_sha'
RUN bundle exec rails runner \
  "User.find_by_login('admin').update!(password: 'redmine_banner_${COMMIT_SHA}', must_change_passwd: false)"

EXPOSE  3000
RUN ls /app/redmine
CMD ["rails", "server", "-b", "0.0.0.0"]
