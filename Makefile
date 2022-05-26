init: init-ci frontend-ready
init-ci: d-down-clear \
	api-clear frontend-clear cucumber-clear\
	d-pull d-build d-up \
	api-init frontend-init cucumber-init
build-prod: build-gateway build-frontend build-api
push-prod: push-gateway push-frontend push-api

########################################################################################################################

test: api-test api-fixtures frontend-test
test-coverage: api-test-coverage api-fixtures
test-unit: api-test-unit
test-unit-coverage: api-test-unit-coverage
test-functional: api-test-functional api-fixtures
test-functional-coverage: api-test-functional-coverage api-fixtures
test-smoke: api-fixtures cucumber-clear cucumber-smoke
test-e2e:
	make api-fixtures
	make cucumber-clear
	- make cucumber-e2e
	make cucumber-report

########################################################################################################################

d-restart: d-down d-up

d-up:
	docker-compose up -d

d-down:
	docker-compose down

d-down-clear:
	docker-compose down -v --remove-orphans

d-build:
	docker-compose build --pull

d-list:
	docker ps -a

d-pull:
	docker-compose pull

d-cli-run:
	docker-compose run --rm api-php-cli $(p)

########################################################################################################################

build-gateway:
	docker --log-level=debug build --pull --file=gateway/docker/production/nginx/Dockerfile --tag=${REGISTRY}/auction-gateway:${IMAGE_TAG} gateway/docker

build-frontend:
	docker --log-level=debug build --pull --file=frontend/docker/production/nginx/Dockerfile --tag=${REGISTRY}/auction-frontend:${IMAGE_TAG} frontend

build-api:
	docker --log-level=debug build --pull --file=api/docker/production/nginx/Dockerfile --tag=${REGISTRY}/auction-api:${IMAGE_TAG} api
	docker --log-level=debug build --pull --file=api/docker/production/php-fpm/Dockerfile --tag=${REGISTRY}/auction-api-php-fpm:${IMAGE_TAG} api
	docker --log-level=debug build --pull --file=api/docker/production/php-cli/Dockerfile --tag=${REGISTRY}/auction-api-php-cli:${IMAGE_TAG} api

push-gateway:
	docker push ${REGISTRY}/auction-gateway:${IMAGE_TAG}

push-frontend:
	docker push ${REGISTRY}/auction-frontend:${IMAGE_TAG}

push-api:
	docker push ${REGISTRY}/auction-api:${IMAGE_TAG}
	docker push ${REGISTRY}/auction-api-php-fpm:${IMAGE_TAG}
	docker push ${REGISTRY}/auction-api-php-cli:${IMAGE_TAG}

deploy:
	ssh -o StrictHostKeyChecking=no root@${HOST} -p ${PORT} 'rm -rf site_${BUILD_NUMBER}'
	ssh -o StrictHostKeyChecking=no root@${HOST} -p ${PORT} 'mkdir site_${BUILD_NUMBER}'
	scp -o StrictHostKeyChecking=no -P ${PORT} docker-compose-production.yml root@${HOST}:site_${BUILD_NUMBER}/docker-compose.yml
	ssh -o StrictHostKeyChecking=no root@${HOST} -p ${PORT} 'cd site_${BUILD_NUMBER} && echo "COMPOSE_PROJECT_NAME=auction" >> .env'
	ssh -o StrictHostKeyChecking=no root@${HOST} -p ${PORT} 'cd site_${BUILD_NUMBER} && echo "REGISTRY=${REGISTRY}" >> .env'
	ssh -o StrictHostKeyChecking=no root@${HOST} -p ${PORT} 'cd site_${BUILD_NUMBER} && echo "IMAGE_TAG=${IMAGE_TAG}" >> .env'
	ssh -o StrictHostKeyChecking=no root@${HOST} -p ${PORT} 'cd site_${BUILD_NUMBER} && echo "API_DB_PASSWORD=${API_DB_PASSWORD}" >> .env'
	ssh -o StrictHostKeyChecking=no root@${HOST} -p ${PORT} 'cd site_${BUILD_NUMBER} && echo "API_MAILER_HOST=${API_MAILER_HOST}" >> .env'
	ssh -o StrictHostKeyChecking=no root@${HOST} -p ${PORT} 'cd site_${BUILD_NUMBER} && echo "API_MAILER_PORT=${API_MAILER_PORT}" >> .env'
	ssh -o StrictHostKeyChecking=no root@${HOST} -p ${PORT} 'cd site_${BUILD_NUMBER} && echo "API_MAILER_USER=${API_MAILER_USER}" >> .env'
	ssh -o StrictHostKeyChecking=no root@${HOST} -p ${PORT} 'cd site_${BUILD_NUMBER} && echo "API_MAILER_PASSWORD=${API_MAILER_PASSWORD}" >> .env'
	ssh -o StrictHostKeyChecking=no root@${HOST} -p ${PORT} 'cd site_${BUILD_NUMBER} && echo "API_MAILER_FROM_EMAIL=${API_MAILER_FROM_EMAIL}" >> .env'

	ssh -o StrictHostKeyChecking=no  root@${HOST} -p ${PORT} 'mkdir site_${BUILD_NUMBER}/secrets'
	scp -o StrictHostKeyChecking=no -P ${PORT} ${JWT_PUBLIC_KEY} root@${HOST}:site_${BUILD_NUMBER}/secrets/jwt_public.key
	scp -o StrictHostKeyChecking=no -P ${PORT} ${JWT_PRIVATE_KEY}  root@${HOST}:site_${BUILD_NUMBER}/secrets/jwt_private.key

	ssh -o StrictHostKeyChecking=no root@${HOST} -p ${PORT} 'cd site_${BUILD_NUMBER} && docker-compose pull'
	ssh -o StrictHostKeyChecking=no root@${HOST} 'cd site_${BUILD_NUMBER} && docker-compose up -d --build --remove-orphans'
	ssh -o StrictHostKeyChecking=no root@${HOST} -p ${PORT} 'rm -f site'
	ssh -o StrictHostKeyChecking=no root@${HOST} -p ${PORT} 'ln -sr site_${BUILD_NUMBER} site'

deploy-clean:
	rm -f docker-compose-production-env.yml

rollback:
	ssh -o StrictHostKeyChecking=no root@${HOST} -p ${PORT} 'cd site_${BUILD_NUMBER} && docker-compose pull'
	ssh -o StrictHostKeyChecking=no root@${HOST} -p ${PORT} 'cd site_${BUILD_NUMBER} && docker-compose up --build --remove-orphans -d'	ssh -o StrictHostKeyChecking=no root@${HOST} -p ${PORT} 'rm -f site'
	ssh -o StrictHostKeyChecking=no root@${HOST} -p ${PORT} 'ln -sr site_${BUILD_NUMBER} site'

########################################################################################################################

api-init: api-permissions api-composer-install api-wait-db api-migrations api-fixtures
api-check: api-lint api-analyze api-validate-schema api-test

api-analyze:
	docker-compose run --rm api-php-cli composer psalm

api-validate-schema:
	docker-compose run --rm api-php-cli composer app orm:validate-schema

api-lint:
	docker-compose run --rm api-php-cli composer lint
	docker-compose run --rm api-php-cli composer php-cs-fixer fix -- --dry-run --diff

api-cs-fix:
	docker-compose run --rm api-php-cli composer php-cs-fixer fix

api-test:
	docker-compose run --rm api-php-cli composer test

api-test-coverage:
	docker-compose run --rm api-php-cli composer test-coverage

api-test-unit:
	docker-compose run --rm api-php-cli composer test -- --testsuite=unit

api-test-unit-coverage:
	docker-compose run --rm api-php-cli composer test-coverage -- --testsuite=unit

api-test-functional:
	docker-compose run --rm api-php-cli composer test -- --testsuite=functional

api-test-functional-coverage:
	docker-compose run --rm api-php-cli composer test-coverage -- --testsuite=functional

api-clear:
	docker run --rm -v ${PWD}/api:/app -w /app alpine sh -c 'rm -rf var/cache/* var/log/* var/test/*'

api-permissions:
	docker run --rm -v ${PWD}/api:/app -w /app alpine chmod 777 var/cache var/log var/test

api-composer-install:
	docker-compose run --rm api-php-cli composer install

api-wait-db:
	docker-compose run --rm api-php-cli wait-for-it api-postgres:5432 -t 30

api-migrations:
	docker-compose run --rm api-php-cli composer app migrations:migrate --no-interaction

api-fixtures:
	docker-compose run --rm api-php-cli composer app fixtures:load

########################################################################################################################

frontend-init: frontend-yarn-install

frontend-clear:
	docker run --rm -v ${PWD}/frontend:/app -w /app alpine sh -c 'rm -rf .ready build'

frontend-yarn-install:
	docker-compose run --rm frontend-node-cli yarn install

frontend-ready:
	docker run --rm -v ${PWD}/frontend:/app -w /app alpine touch .ready

frontend-test:
	docker-compose run --rm frontend-node-cli yarn test --watchAll=false

frontend-test-watch:
	docker-compose run --rm frontend-node-cli yarn test

frontend-lint:
	docker-compose run --rm frontend-node-cli yarn eslint
	docker-compose run --rm frontend-node-cli yarn stylelint

frontend-lint-fix:
	docker-compose run --rm frontend-node-cli yarn lint-fix

frontend-pretty:
	docker-compose run --rm frontend-node-cli yarn prettier

########################################################################################################################

cucumber-init: cucumber-yarn-install

cucumber-clear:
	docker run --rm -v ${PWD}/cucumber:/app -w /app alpine sh -c 'rm -rf var/*'

cucumber-yarn-install:
	docker-compose run --rm cucumber-node-cli yarn install

cucumber-yarn-upgrade:
	docker-compose run --rm cucumber-node-cli yarn upgrade

cucumber-e2e:
	docker-compose run --rm cucumber-node-cli yarn e2e

cucumber-lint:
	docker-compose run --rm cucumber-node-cli yarn lint

cucumber-lint-fix:
	docker-compose run --rm cucumber-node-cli yarn lint-fix

cucumber-report:
	docker-compose run --rm cucumber-node-cli yarn report

cucumber-smoke:
	docker-compose run --rm cucumber-node-cli yarn smoke

########################################################################################################################

testing: testing-build testing-init testing-smoke testing-e2e testing-down-clear
testing-build: testing-build-gateway testing-build-testing-api-php-cli testing-build-cucumber

testing-build-gateway:
	docker --log-level=debug build --pull --file=gateway/docker/testing/nginx/Dockerfile --tag=${REGISTRY}/auction-testing-gateway:${IMAGE_TAG} gateway/docker

testing-build-testing-api-php-cli:
	docker --log-level=debug build --pull --file=api/docker/testing/php-cli/Dockerfile --tag=${REGISTRY}/auction-testing-api-php-cli:${IMAGE_TAG} api

testing-build-cucumber:
	docker --log-level=debug build --pull --file=cucumber/docker/testing/node/Dockerfile --tag=${REGISTRY}/auction-cucumber-node-cli:${IMAGE_TAG} cucumber

testing-init:
	COMPOSE_PROJECT_NAME=testing docker-compose -f docker-compose-testing.yml up -d
	COMPOSE_PROJECT_NAME=testing docker-compose -f docker-compose-testing.yml run --rm api-php-cli wait-for-it api-postgres:5432 -t 60
	COMPOSE_PROJECT_NAME=testing docker-compose -f docker-compose-testing.yml run --rm api-php-cli php bin/app.php migrations:migrate --no-interaction
	COMPOSE_PROJECT_NAME=testing docker-compose -f docker-compose-testing.yml run --rm testing-api-php-cli php bin/app.php fixtures:load --no-interaction

testing-smoke:
	COMPOSE_PROJECT_NAME=testing docker-compose -f docker-compose-testing.yml run --rm cucumber-node-cli yarn smoke

testing-e2e:
	COMPOSE_PROJECT_NAME=testing docker-compose -f docker-compose-testing.yml run --rm cucumber-node-cli yarn e2e

testing-down-clear:
	COMPOSE_PROJECT_NAME=testing docker-compose -f docker-compose-testing.yml down -v --remove-orphans
