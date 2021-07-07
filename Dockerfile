################################################################################
##                                   BASE                                     ##
################################################################################
FROM ruby:2.7.1-alpine3.12 AS base

ARG WORKDIR=/app
ENV WORKDIR=$WORKDIR

ARG APP_USER=user
ENV APP_USER=$APP_USER

# Install dependent libraries
RUN apk update \
    && apk upgrade \
    && apk add --no-cache \
      build-base \
      bash \
      curl \
      make \
      ruby-dev \
      git \
      tzdata \
      postgresql-client \
      postgresql-dev \
      glib \
      glib-dev \
      vips \
      vips-dev \
    && apk -v --purge del build-base

RUN apk add --no-cache --force \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main/ \
    libcrypto1.1

RUN apk add --no-cache \
    --repository http://dl-cdn.alpinelinux.org/alpine/v3.8/main/ \
    jemalloc

# Tool to propagate singals from the container to the app
# Repo: https://github.com/fpco/pid1
# Explanation: https://www.fpcomplete.com/blog/2016/10/docker-demons-pid1-orphans-zombies-signals
ENV PID1_VERSION=0.1.2.0
RUN curl -sSL "https://github.com/fpco/pid1/releases/download/v${PID1_VERSION}/pid1-${PID1_VERSION}-linux-x86_64.tar.gz" | tar xzf - -C /usr/local \
    && chown root:root /usr/local/sbin \
    && chown root:root /usr/local/sbin/pid1

# Disable documentation for Ruby gems
RUN echo 'gem: --no-rdoc --no-ri' > /etc/gemrc

# Change working directory
WORKDIR $WORKDIR

# Install bundler
# https://bundler.io/v1.16/guides/bundler_docker_guide.html
#
# A version needs to be specified because the base Ruby image explicetly
# specifies the BUNDLER_VERSION variable, therefore, to use more up-to-date
# versions we need to specify them explicitly
ENV BUNDLER_VERSION=2.1.4
RUN gem install bundler -v $BUNDLER_VERSION
ENV GEM_HOME="/usr/local/bundle"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

# Set the entrypoint
COPY ./docker/entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint"]

# Expose the application's port
EXPOSE 3000

################################################################################
##                                DEVELOPMENT                                 ##
################################################################################
FROM base AS development

# Install dependent libraries
RUN apk update \
    && apk upgrade \
    && apk add --no-cache \
      build-base \
      curl \
      bash \
      less \
      make \
      ruby-dev \
      git \
      nodejs \
      yarn \
      python3 \
      vim
RUN yarn global add node-gyp

# Do nothing forever
CMD ["/bin/bash", "-c", "while true; do sleep 10; done;"]

################################################################################
##                              PRE-PRODUCTION                                ##
################################################################################
FROM development AS pre_production

COPY Gemfile* $APP_HOME/
RUN CFLAGS="-Wno-cast-function-type" \
    BUNDLE_FORCE_RUBY_PLATFORM=1 \
    bundle install \
      --jobs `expr $(nproc)` \
      --retry 3

COPY package.json yarn.lock $APP_HOME/
RUN yarn install --production

COPY . $APP_HOME

RUN bundle exec rails webpacker:compile
RUN rm -rf \
      ./node_modules \
      ./test \
      ./log \
      ./docker \
      ./tmp/* \
      ./.git \
      yarn* \
      package.json \
      tags

################################################################################
##                                PRODUCTION                                  ##
################################################################################
FROM base AS production

ENV RAILS_ENV=production

# Copy built project
COPY --from=pre_production /app $APP_HOME

# Copy built gems
COPY --from=pre_production /usr/local/bundle /usr/local/bundle

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
