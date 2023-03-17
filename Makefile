.PHONY: run dev kill bash

DEFAULT_GOAL: help
export LOCAL_USER_ID ?= $(shell id -u $$USER)
WEB_SERVICE=app
DB_SERVICE=db
REDIS_SERVICE=redis
IMAGE_NAME=monorkin/blog
VERSION ?= $(shell ruby -r './config/version.rb' -e 'puts Blog::VERSION')

################################################################################
##                                   DEVELOPMENT                              ##
################################################################################

## Starts all containers in the foreground
env:
	@LOCAL_USER_ID=$(LOCAL_USER_ID) docker compose up

## Starts all containers in the foreground
update-env:
	@LOCAL_USER_ID=$(LOCAL_USER_ID) docker compose up -d

## Stops all containers
kill-env:
	@docker compose down

## Builds the development Docker image
build-env:
	@docker compose build

## Starts a server
server: run_migrations
	@bundle exec puma -C config/puma.rb

## Starts a development server
dev:
	@./bin/dev

## Spawns an interactive Rails console in the web container
console:
	@rails c

## Installs all required dependencies
bundle:
	@bundle install --jobs `expr $$(nproc) - 1` --retry 3

## Spawns an interactive Bash shell in the web container
bash:
	@if [ -z "$$ROOT" ]; then \
		docker exec \
			-u $(LOCAL_USER_ID) \
			-it $$(docker compose ps -q $(WEB_SERVICE)) \
			bash -c "reset -w && bash"; \
	else \
		docker exec \
			-it $$(docker compose ps -q $(WEB_SERVICE)) \
			bash; \
	fi

## Run a command inside the docer container
run-command:
	@docker exec \
		-u $(LOCAL_USER_ID) \
		-it $$(docker compose ps -q web) \
		bash -c "reset -w && bash -c '$$COMMAND'"

## Reloads the currently running server
reload:
	@touch ./tmp/restart.txt

## Toggles caching on or off
toggle-caching:
	@rails dev:cache

## Disable Rack Mini Profiler ETag stripping
toggle-rack-mini-profiler-etag-stripping:
	@if [ -f ./tmp/dev-disable-rack-mini-profiler-etag-stripping.txt ]; then \
		rm ./tmp/dev-disable-rack-mini-profiler-etag-stripping.txt; \
	else \
		touch ./tmp/dev-disable-rack-mini-profiler-etag-stripping.txt; \
	fi
	@$(MAKE) reload

version:
	@echo "$(VERSION)"

################################################################################
##                                  TESTING                                   ##
################################################################################

## Prepares and runs all tests in parallel
test: bundle
	@echo "Check for security vulnerability"
	@bundle exec brakeman -z
	@echo "Running tests"
	@bundle exec rails test:all

################################################################################
##                                 DEPLOYMENT                                 ##
################################################################################

server-logs:
	ssh root@deploy.stanko.io "docker-compose logs --tail 100 -f stanko-io"

deploy:
	$(MAKE) push-production-image \
		&& ssh root@deploy.stanko.io "docker-compose pull stanko-io && docker-compose up -d"

list-images:
	@docker image ls | grep $(IMAGE_NAME)

build-production-image:
	@docker build . \
		--target production \
		-t $(IMAGE_NAME):latest \
		-t $(IMAGE_NAME):$(VERSION)

push-production-image: build-production-image
	@docker push $(IMAGE_NAME):$(VERSION)
	@docker push $(IMAGE_NAME):latest

################################################################################
##                                   REDIS                                    ##
################################################################################

## Opens a redis-cli console
redis-cli:
	@docker compose exec $(REDIS_SERVICE) redis-cli

################################################################################
##                                  DATABASE                                  ##
################################################################################

## Runs pending migrations and annotates models with the current DB schema
migrate: run_migrations annotate

## Undoes the previous migration, if possible, and annotates models with the current DB schema
rollback: rollback_migration annotate

## Runs the migrations
run_migrations:
	@bundle exec rake db:migrate

## Undo the previous migration, if possible
rollback_migration:
	@bundle exec rake db:rollback

## Adds annotation comments to the top of each model describing their DB schema
annotate:
	@bundle exec annotate \
		--models --show-migration --show-foreign-keys --show-indexes \
		--classified-sort --with-comment

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
