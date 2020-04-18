.PHONY: build
build:
	docker build -t openresty-ssl-example .

.PHONY: run
run:
	docker run -it --rm -p 8443:443 openresty-ssl-example

.PHONY: test
test:
	openssl s_client -brief -connect localhost:8443 < /dev/null 2>&1 | head -1
	openssl s_client -brief -connect localhost:8443 -servername a.local < /dev/null 2>&1 | head -1
	openssl s_client -brief -connect localhost:8443 -servername b.local < /dev/null 2>&1 | head -1
	openssl s_client -brief -connect localhost:8443 -servername c.local < /dev/null 2>&1 | head -1
	openssl s_client -brief -connect localhost:8443 -servername d.local < /dev/null 2>&1 | head -1
