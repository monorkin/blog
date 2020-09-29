.PHONY: run dev kill bash

DEFAULT_GOAL: help
export LOCAL_USER_ID ?= $(shell id -u $$USER)
WEB_SERVICE=app
DB_SERVICE=db
REDIS_SERVICE=redis

################################################################################
##                                   RUNNING                                  ##
################################################################################

## Starts all containers in the foreground
dev:
	@LOCAL_USER_ID=$(LOCAL_USER_ID) docker-compose up

## Starts a server
server:
	@rails s

## Starts a development server
dev-server:
	@./bin/webpack-dev-server &
	@rails s -b 0.0.0.0 -p 3000

## Stops all containers
kill:
	@docker-compose down

## Builds the development Docker image
build:
	@docker-compose build

## Spawns an interactive Rails console in the web container
console:
	@rails c

## Installs all required dependencies
bundle:
	@CFLAGS="-Wno-cast-function-type" \
		BUNDLE_FORCE_RUBY_PLATFORM=1 \
		bundle install --jobs `expr $$(nproc) - 1` --retry 3

## Spawns an interactive Bash shell in the web container
bash:
	@if [ -z "$$ROOT" ]; then \
		docker exec \
			-u $(LOCAL_USER_ID) \
			-it $$(docker-compose ps -q $(WEB_SERVICE)) \
			bash -c "reset -w && bash"; \
	else \
		docker exec \
			-it $$(docker-compose ps -q $(WEB_SERVICE)) \
			bash; \
	fi

## Run a command inside the docer container
run-command:
	@docker exec \
		-u $(LOCAL_USER_ID) \
		-it $$(docker-compose ps -q web) \
		bash -c "reset -w && bash -c '$$COMMAND'"

################################################################################
##                                   REDIS                                    ##
################################################################################

## Opens a redis-cli console
redis-cli:
	@docker-compose exec $(REDIS_SERVICE) redis-cli

################################################################################
##                                  TESTING                                   ##
################################################################################

## Prepares and runs all tests in parallel
test: bundle
	@echo "Check for security vulnerability"
	@bundle exec brakeman -z

################################################################################
##                                  DATABASE                                  ##
################################################################################

## Runs pending migrations and annotates models with the current DB state
migrate:
	@bundle exec rake db:migrate && \
		bundle exec annotate \
			--models --show-migration --show-foreign-keys --show-indexes \
			--classified-sort --with-comment

## Starts a MySQL session
psql:
	@docker-compose exec $(DB_SERVICE) psql -u postgres -d postgres

################################################################################
##                                 DEPLOYMENT                                 ##
################################################################################

deploy:
	echo "TODO"

################################################################################
##                                      HELP                                  ##
################################################################################

## Shows the help menu
help:
	@echo "Please use \`make <target>' where <target> is one of\n\n"
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "%-30s %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
