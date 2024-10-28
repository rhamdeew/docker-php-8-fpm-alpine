build:
	docker build -t rhamdeew/docker-php-8-fpm-alpine .
run:
	docker run --rm -it rhamdeew/docker-php-8-fpm-alpine /bin/ash
