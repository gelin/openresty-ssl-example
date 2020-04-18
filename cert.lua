-- TODO
-- certificate files
local cert_files = {
    ["a"] = "/etc/nginx/certs/a.pem",
    ["b"] = "/etc/nginx/certs/b.pem",
    ["c"] = "/etc/nginx/certs/c.pem"
}

-- TODO
-- define logic to get private key and certificate file from the server name here
local function get_cert_file(server_name)
    local m, err = ngx.re.match(server_name, "([^\\.]+)\\.([^\\.]+)$")
    if m then
        return cert_files[m[1]]
    end
    return nil
end

local ssl = require "ngx.ssl"

-- caches for keys and certificate chains
local keys_cache = ngx.shared.keys
local certs_cache = ngx.shared.certs

-- get SNI server name
local server_name, err = ssl.server_name()
if err ~= nil then
    ngx.log(ngx.ERR, "failed to get server name: ", err)
    return ngx.exit(ngx.ERROR)
end

-- if server name is unknown do nothing (i.e. use default cert)
if server_name == nil then
    return
end

-- get cert file name
local cert_file = get_cert_file(server_name)

-- if no special cert file is defined do nothing (i.e. use default cert)
if cert_file == nil then
    return
end

-- get files from cache
local key = keys_cache:get(cert_file)
local cert = certs_cache:get(cert_file)

if key == nil or cert == nil then

    -- reading key and certificate file
    ngx.log(ngx.INFO, "loading file ", cert_file)

    local file, err = io.open(cert_file, "r")
    if err ~= nil then
        ngx.log(ngx.ERR, "failed to open file: ", err)
        return ngx.exit(ngx.ERROR)
    end

    local data, err = file:read("*all")
    if err ~= nil then
        ngx.log(ngx.ERR, "failed to read file: ", err)
        return ngx.exit(ngx.ERROR)
    end

    key, err = ssl.parse_pem_priv_key(data)
    if err ~= nil then
        ngx.log(ngx.ERR, "failed to parse private key: ", err)
        return ngx.exit(ngx.ERROR)
    end

    cert, err = ssl.parse_pem_cert(data)
    if err ~= nil then
        ngx.log(ngx.ERR, "failed to parse cert chain: ", err)
        return ngx.exit(ngx.ERROR)
    end

    -- save keys and certificates to cache
    success, err, forcible = keys_cache:set(cert_file, key)
    if err ~= nil then
        ngx.log(ngx.ERR, "failed to store private key to cache: ", err)
    end
    success, err, forcible = certs_cache:set(cert_file, cert)
    if err ~= nil then
        ngx.log(ngx.ERR, "failed to store cert chain to cache: ", err)
    end

end

-- clear the default certificates and private keys
local ok, err = ssl.clear_certs()
if not ok then
    ngx.log(ngx.ERR, "failed to clear existing (default) certificates: ", err)
    return ngx.exit(ngx.ERROR)
end

-- set private key
local ok, err = ssl.set_priv_key(key)
if not ok then
    ngx.log(ngx.ERR, "failed to set private key: ", err)
    return ngx.exit(ngx.ERROR)
end

-- set certificate chain
local ok, err = ssl.set_cert(cert)
if not ok then
    ngx.log(ngx.ERR, "failed to set cert: ", err)
    return ngx.exit(ngx.ERROR)
end
