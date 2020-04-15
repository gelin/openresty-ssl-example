.PHONY: build
build:
	docker build -t openresty-ssl-example .

.PHONY: run
run:
	docker run -it --rm -p 8080:80 openresty-ssl-example
