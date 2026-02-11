--- HTTP transport for Meteoflow SDK
-- @module meteoflow.http

local errors = require("meteoflow.errors")

-- Try to load JSON library (prefer cjson, fallback to dkjson)
local json
local json_loaded, cjson = pcall(require, "cjson")
if json_loaded then
    json = cjson
else
    local dkjson_loaded, dkjson = pcall(require, "dkjson")
    if dkjson_loaded then
        json = dkjson
    else
        error("No JSON library found. Please install lua-cjson or dkjson.")
    end
end

-- Load socket libraries
local socket = require("socket")
local http = require("socket.http")
local ltn12 = require("ltn12")

-- Try to load HTTPS support
local https_loaded, https = pcall(require, "ssl.https")

local transport = {}
transport.__index = transport

--- Create a new HTTP transport
-- @param config Configuration table
-- @return HTTP transport instance
function transport.new(config)
    local self = setmetatable({}, transport)
    self.base_url = config.base_url or "https://api.meteoflow.com"
    self.timeout = (config.timeout_ms or 5000) / 1000 -- Convert to seconds
    self.api_key = config.api_key
    return self
end

--- URL encode a string
-- @param str String to encode
-- @return Encoded string
local function url_encode(str)
    if str then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w%-%.%_%~])", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
    end
    return str
end

--- Build query string from parameters table
-- @param params Parameters table
-- @return Query string
local function build_query_string(params)
    if not params or next(params) == nil then
        return ""
    end

    local parts = {}
    -- Sort keys for consistent ordering
    local keys = {}
    for k in pairs(params) do
        table.insert(keys, k)
    end
    table.sort(keys)

    for _, k in ipairs(keys) do
        local v = params[k]
        if v ~= nil then
            table.insert(parts, url_encode(tostring(k)) .. "=" .. url_encode(tostring(v)))
        end
    end

    return table.concat(parts, "&")
end

--- Perform an HTTP GET request
-- @param self Transport instance
-- @param path API path (e.g., "/v2/current/")
-- @param params Query parameters table
-- @return Response data table or nil, error
function transport:get(path, params)
    -- Add API key to params
    params = params or {}
    params.key = self.api_key

    -- Build full URL
    local query = build_query_string(params)
    local url = self.base_url .. path
    if query ~= "" then
        url = url .. "?" .. query
    end

    -- Determine if HTTPS
    local is_https = url:match("^https://")

    if is_https and not https_loaded then
        return nil, errors.network(url, "HTTPS not supported: LuaSec not installed")
    end

    -- Choose HTTP library
    local http_lib = is_https and https or http

    -- Prepare request
    local response_body = {}
    local request_params = {
        url = url,
        method = "GET",
        sink = ltn12.sink.table(response_body),
        headers = {
            ["Accept"] = "application/json",
            ["User-Agent"] = "meteoflow-lua/1.0.3",
        },
    }

    -- Set timeout
    if self.timeout then
        socket.TIMEOUT = self.timeout
    end

    -- Make request
    local result, status_code, response_headers, status_line = http_lib.request(request_params)

    -- Handle errors
    if not result then
        -- status_code contains error message when result is nil
        local err_msg = tostring(status_code)
        if err_msg:match("timeout") or err_msg:match("wantread") or err_msg:match("wantwrite") then
            return nil, errors.timeout(url, "Request timed out: " .. err_msg)
        else
            return nil, errors.network(url, "Network error: " .. err_msg)
        end
    end

    -- Get response body as string
    local body = table.concat(response_body)

    -- Check HTTP status
    if status_code ~= 200 then
        return nil, errors.http(status_code, url, body, "HTTP " .. tostring(status_code))
    end

    -- Decode JSON
    local ok, data = pcall(json.decode, body)
    if not ok then
        return nil, errors.decode(url, body, "Failed to decode JSON: " .. tostring(data))
    end

    if data == nil then
        return nil, errors.decode(url, body, "JSON decoded to nil")
    end

    return data, nil
end

return transport
