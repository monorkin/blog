ARG RUBY_VERSION=3.2

################################################################################
############################## BASE IMAGE ######################################
################################################################################
FROM ruby:$RUBY_VERSION-slim-bullseye AS base

# Rails app lives here
WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl \
      libsqlite3-0 \
      postgresql-client \
      default-mysql-client \
      libvips \
      dumb-init \
      gosu \
      libjemalloc-dev \
      ffmpeg \
      exiftool \
    && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Disable documentation for Ruby gems
RUN echo 'gem: --no-rdoc --no-ri' > /etc/gemrc

# Install bundler
# https://bundler.io/v1.16/guides/bundler_docker_guide.html
#
# A version needs to be specified because the base Ruby image explicetly
# specifies the BUNDLER_VERSION variable, therefore, to use more up-to-date
# versions we need to specify them explicitly
ENV BUNDLE_PATH="/usr/local/bundle"

# Set the entrypoint
COPY ./bin/docker-entrypoint /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint"]

###################
### DEVELOPMENT ###
###################

FROM base AS development

# Install packages needed to build gems and node modules
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      pkg-config \
      libpq-dev \
      default-libmysqlclient-dev \
      libvips \
      node-gyp \
      python-is-python3 \
      less \
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
      vim

# Install JavaScript dependencies
ARG NODE_VERSION=18.15.0
ARG YARN_VERSION=latest
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    npm install -g yarn@$YARN_VERSION && \
    rm -rf /tmp/node-build-master

CMD /bin/bash -c "while true; do sleep 10; done;"

###################
### BUILD IMAGE ###
###################

FROM development AS build

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Install node modules
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .

RUN bundle exec bootsnap precompile app/ lib/

RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

RUN rm -rf node_modules

########################
### PRODUCTION IMAGE ###
########################

FROM base AS production

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

RUN useradd rails --home /rails --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

EXPOSE 3000
CMD ["./bin/rails", "server"]
