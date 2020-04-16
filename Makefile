.PHONY: build
build:
	docker build -t openresty-ssl-example .

.PHONY: run
run:
	docker run -it --rm -p 8443:443 openresty-ssl-example

.PHONY: test
test:
	openssl s_client -showcerts -brief -connect localhost:8443 < /dev/null
