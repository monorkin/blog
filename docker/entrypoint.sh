#!/usr/bin/env bash

# Useful shorthand variables
USER_NAME=$APP_USER
USER_ID=${LOCAL_USER_ID:-9001}

# Add user if it doesn't exists
adduser -s /bin/bash -u "$USER_ID" -D "$USER_NAME"
# Convert old UIDs to new ones
# find / -user <OLDUID> -exec chown -h <NEWUID> {} \;

# Change ownership of library directories
mkdir -p "$GEM_HOME/gems/bin"
chown "$USER_NAME":"$USER_NAME" /usr/local/bundle -R
chown "$USER_NAME":"$USER_NAME" "$GEM_HOME/bin" -R
chown "$USER_NAME":"$USER_NAME" "$GEM_HOME/gems/bin" -R
chown "$USER_NAME":"$USER_NAME" "$WORKDIR" -R

# Fake home direcotry
export HOME=/home/$USER_NAME

# Use container set paths
# https://bundler.io/v1.16/guides/bundler_docker_guide.html
unset BUNDLE_PATH
unset BUNDLE_BIN

# Run the command attached to the process with PID 1 so that signals get
# passed to the process/app being run
exec /usr/local/sbin/pid1 -u "$USER_NAME" -g "$USER_NAME" "$@"
