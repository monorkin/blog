################################################################################
############################## BASE IMAGE ######################################
################################################################################
FROM ruby:3.1-slim-buster AS base

ARG WORKDIR=/app
ENV WORKDIR=$WORKDIR

ARG APP_USER=user
ENV APP_USER=$APP_USER

# Install dependent libraries
RUN export DEBIAN_FRONTEND=noninteractive \
    && dpkg --configure -a \
    && apt-get update \
    && apt-get install -y \
      libssl1.1 libssl-dev \
      curl \
      bash \
      gnupg \
      gnupg1 \
      gnupg2 \
      make \
      dumb-init \
      gosu \
      tzdata \
      postgresql-client \
      libpq-dev \
      imagemagick \
      libjemalloc-dev \
      libvips-dev \
    && rm -rf /var/lib/apt/lists/*

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
ENV BUNDLER_VERSION=2.3.16
RUN gem install bundler -v $BUNDLER_VERSION
ENV GEM_HOME="/usr/local/bundle"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

# Set the entrypoint
COPY ./docker/entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint"]

###################
### DEVELOPMENT ###
###################

FROM base AS development
RUN export DEBIAN_FRONTEND=noninteractive \
    && dpkg --configure -a \
    && apt-get update \
    && apt-get install -y \
      build-essential \
      less \
      git \
      freerdp2-shadow-x11 \
      fonts-dejavu \
      fonts-droid-fallback \
      fonts-freefont-ttf \
      fonts-liberation2 \
      groff \
      xvfb \
      fontconfig \
      dbus \
      firefox-esr \
      chromium \
      xauth \
    && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get install nodejs \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      yarn \
    && rm -rf /var/lib/apt/lists/* \
    && dbus-uuidgen --ensure=/etc/machine-id

RUN yarn global add node-gyp
ENV PATH="$PATH:$(yarn global bin)"

CMD /bin/bash -c "while true; do sleep 10; done;"

############################
### PRE-PRODUCTION IMAGE ###
############################

FROM development AS pre_production

COPY Gemfile* $APP_HOME/
RUN bundle install --jobs `expr $$(nproc) - 1` --retry 3

COPY package.json yarn.lock $APP_HOME/
RUN yarn install --production

COPY . $APP_HOME

RUN bundle exec rake assets:precompile

RUN rm -rf $APP_HOME/node_modules

########################
### PRODUCTION IMAGE ###
########################

FROM base AS production

ARG APP_HOME=/app
WORKDIR $APP_HOME

# Copy built project
COPY --from=pre_production /app $APP_HOME

# Copy built gems
COPY --from=pre_production /usr/local/bundle /usr/local/bundle

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
