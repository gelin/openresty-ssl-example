.PHONY: build
build:
	docker build -t openresty-ssl-example .

.PHONY: run
run:
	docker run -it --rm -p 8443:443 openresty-ssl-example

.PHONY: test
test:
	echo "GET / HTTP/1.0\r\n" | openssl s_client -brief -connect localhost:8443 2>&1 | head -1
	echo "GET / HTTP/1.0\r\n" | openssl s_client -brief -connect localhost:8443 -servername a.local 2>&1 | head -1
	echo "GET / HTTP/1.0\r\n" | openssl s_client -brief -connect localhost:8443 -servername b.local 2>&1 | head -1
	echo "GET / HTTP/1.0\r\n" | openssl s_client -brief -connect localhost:8443 -servername c.local 2>&1 | head -1
	echo "GET / HTTP/1.0\r\n" | openssl s_client -brief -connect localhost:8443 -servername d.local 2>&1 | head -1
