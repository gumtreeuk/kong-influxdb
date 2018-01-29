local http = {}

local http = require "resty.http"

function http.post(msg, params)
    local client = http.new()
    local useSSL = params.proto == 'https'
    local precision = params.precision or 'ms'

    local scheme = useSSL and 'https' or 'http'
    local path    = string.format('%s://%s:%s/write', scheme, params.host, params.port)
    local method  = 'POST'
    local headers = {}

    if params.auth then
        headers.Authorization = string.format("Basic %s", ngx.encode_base64(params.auth))
    end

    local res, err = client:request_uri(
        path,
        {
            query      = string.format("?db=%s&precision=%s", params.db, precision),
            method     = method,
            headers    = headers,
            body       = msg,
            ssl_verify = useSSL,
        }
    )

    if not res then
        return false, err
    end

    if res.status == ngx.HTTP_NO_CONTENT then
        return true
    else
        return false, res
    end
end

return http