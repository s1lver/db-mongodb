help:			## Display help information
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

build:			## Build an image from a docker-compose file. Params: {{ v=8.1 }}. Default latest PHP 8.1
	make generate-mongo-key
	sleep 2
	PHP_VERSION=$(filter-out $@,$(v)) docker-compose up -d --build
	make composer-update

down:			## Stop and remove containers, networks
	docker-compose down

sh:			## Enter the container with the application
	docker exec -it db-mongodb-php sh

composer-update:	## Composer update
	docker exec db-mongodb-php composer update --prefer-dist --no-interaction --no-progress --optimize-autoloader --ansi

test:			## Run tests. Params: {{ v=8.1 }}. Default latest PHP 8.1
	make build
	make create-cluster-mongodb
	PHP_VERSION=$(filter-out $@,$(v)) docker-compose run db-mongodb-php vendor/bin/phpunit --coverage-clover coverage.xml
	make down

mutation-test:		## Run mutation tests. Params: {{ v=8.1 }}. Default latest PHP 8.1
	make build
	make create-cluster-mongodb
	PHP_VERSION=$(filter-out $@,$(v)) docker-compose run db-mongodb-php vendor/bin/roave-infection-static-analysis-plugin --threads=2 --ignore-msi-with-no-mutations --only-covered
	make down

generate-mongo-key:	## Generate key for MongoDB cluster
	@if [ -f mongo-key.key ] ; then chmod 777 mongo-key.key; rm mongo-key.key; fi
	openssl rand -base64 756 > ./mongo-key.key && chmod 400 ./mongo-key.key

create-cluster-mongodb:	## Create MongoDB cluster
	docker exec db-mongodb-db-primary mongosh --quiet --host db-mongodb-db-primary --port 27017 --eval "EJSON.stringify(db.getSiblingDB('admin').auth('root', 'password'));" --eval "EJSON.stringify(rs.initiate({_id: 'myReplicaSet', version: 1, members: [{ _id: 0, host: 'db-mongodb-db-primary:27017', 'priority': 2 }, { _id: 1, host: 'db-mongodb-db-secondary:27017', 'priority': 1 }, { _id: 2, host: 'db-mongodb-db-arbiter:27017', 'priority': 1, 'arbiterOnly': true }]}));"
