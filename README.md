A small example how to use OpenReady ssl module.
Based on the official [synopsis](https://github.com/openresty/lua-resty-core/blob/master/lib/ngx/ssl.md).

# Issue

There are multiple certificates for some set of domains which should be served by the single `server` Nginx configuration block.
It's necessary to choose the correct certificate based on the [SNI](https://en.wikipedia.org/wiki/Server_Name_Indication) domain name.

To solve the issue it's necessary to use [OpenResty](https://openresty.org/en/): the Nginx with Lua support.
It's necessary to use [`ssl_certificate_by_lua_block`](https://openresty-reference.readthedocs.io/en/latest/Directives/#ssl_certificate_by_lua_block) or `ssl_certificate_by_lua_file` directive and a Lua script to load the necessary certificate.

In this example OpenResty is run in a Docker container. 

# Run

## Requirements

* Docker
* openssl

## Run Docker container

```console
$ make

docker build -t openresty-ssl-example .
Sending build context to Docker daemon  36.35kB
Step 1/4 : FROM openresty/openresty:1.15.8.3-1-alpine
 ---> c864abc21f27
Step 2/4 : COPY ./certs/ /etc/nginx/certs/
 ---> Using cache
 ---> cc1e0b1947bb
Step 3/4 : COPY ./nginx.conf /etc/nginx/conf.d/default.conf
 ---> Using cache
 ---> 9db698a6a409
Step 4/4 : COPY ./cert.lua /etc/nginx/
 ---> cf316076ac51
Successfully built cf316076ac51
Successfully tagged openresty-ssl-example:latest

$ make run

docker run -it --rm -p 8443:443 openresty-ssl-example
```

## Test

```console
$ make test
 
openssl s_client -brief -connect localhost:8443 < /dev/null 2>&1 | head -1
depth=0 CN = localhost
openssl s_client -brief -connect localhost:8443 -servername a.local < /dev/null 2>&1 | head -1
depth=0 CN = a.local
openssl s_client -brief -connect localhost:8443 -servername b.local < /dev/null 2>&1 | head -1
depth=0 CN = b.local
openssl s_client -brief -connect localhost:8443 -servername c.local < /dev/null 2>&1 | head -1
depth=0 CN = c.local
openssl s_client -brief -connect localhost:8443 -servername d.local < /dev/null 2>&1 | head -1
depth=0 CN = localhost
```

# Details

The private key and the whole certificate chain should be stored in a single PEM file.
This can be done by a simple concatenation of the PEM files with the key, and the certificate chain.
All these files for each certificate should be stored in a single known directory.

[Lua script](cert.lua) has a special function to map SNI server name to the path to the key with certificate file.
This function should be customized for the real usage. 

If no PEM file is mapped for the domain, or no SNI in the request, a default certificate is used.
The default certificate is defined as usual with `ssl_certificate` and `ssl_certificate_key` directives.

The PEM file is read, the private key and the certificate chain are extracted from the file (in DER format).
They are stored to in-memory cache to avoid rereading of the file when the same domain is requested next time.
The cache key is the same as the file name.

The cache for keys and certificates is defined statically in Nginx configuration by [`lua_shared_dict`](https://openresty-reference.readthedocs.io/en/latest/Directives/#lua_shared_dict) directive.
The size of the caches should be enough to hold all the necessary keys and certificates,
otherwise the PEM files will be reread on each request.

The key and certificate chain loaded from the cache of the chosen file are replaced to be used in the current request.
