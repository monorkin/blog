#!/usr/bin/env bash

# Useful shorthand variables
USER_NAME=$APP_USER
USER_ID=${LOCAL_USER_ID:-9001}

mkdir -p "/home/$USER_NAME"
useradd -d "/home/$USER_NAME" -s "/bin/bash" -u "$USER_ID" "$USER_NAME"

export HOME=/home/$USER_NAME
chown "$USER_NAME:$USER_NAME" "$HOME"

# Change ownership of library directories
mkdir -p "$GEM_HOME/gems/bin"
chown "$USER_NAME:$USER_NAME" /usr/local/bundle -R
chown "$USER_NAME:$USER_NAME" "$GEM_HOME/bin" -R
chown "$USER_NAME:$USER_NAME" "$GEM_HOME/gems/bin" -R
chown "$USER_NAME:$USER_NAME" "$WORKDIR" -R

# Use container set paths
# https://bundler.io/v1.16/guides/bundler_docker_guide.html
unset BUNDLE_PATH
unset BUNDLE_BIN

# Setup jemalloc
export LD_PRELOAD="$JEMALLOC_PATH"
export JEMALLOC_PATH

JEMALLOC_PATH="$(find /usr/lib -name libjemalloc.so | head -n1)"

if [ -n "$JEMALLOC_PATH" ]; then
  LD_PRELOAD="$JEMALLOC_PATH"
fi

# Run the command attached to the process with PID 1 so that signals get
# passed to the process/app being run
exec gosu "$USER_NAME" /usr/bin/dumb-init "$@"
