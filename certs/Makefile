.PHONY: gen
gen:
	openssl req -x509 -newkey rsa:4096 -keyout default.key -out default.crt -days 365 -nodes -subj '/CN=localhost'
	cat default.key default.crt > default.pem
	rm default.key default.crt
	openssl req -x509 -newkey rsa:4096 -keyout a.key -out a.crt -days 365 -nodes -subj '/CN=a.local'
	cat a.key a.crt > a.pem
	rm a.key a.crt
	openssl req -x509 -newkey rsa:4096 -keyout b.key -out b.crt -days 365 -nodes -subj '/CN=b.local'
	cat b.key b.crt > b.pem
	rm b.key b.crt
	openssl req -x509 -newkey rsa:4096 -keyout c.key -out c.crt -days 365 -nodes -subj '/CN=c.local'
	cat c.key c.crt > c.pem
	rm c.key c.crt
