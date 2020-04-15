.PHONY: gen
gen:
	openssl req -x509 -newkey rsa:4096 -keyout default_key.pem -out default_crt.pem -days 365 -nodes -subj '/CN=localhost'
	openssl req -x509 -newkey rsa:4096 -keyout a_key.pem -out a_crt.pem -days 365 -nodes -subj '/CN=a.local'
	openssl req -x509 -newkey rsa:4096 -keyout b_key.pem -out b_crt.pem -days 365 -nodes -subj '/CN=b.local'
	openssl req -x509 -newkey rsa:4096 -keyout c_key.pem -out c_crt.pem -days 365 -nodes -subj '/CN=c.local'
