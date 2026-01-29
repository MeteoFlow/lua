--- Error constructors for Meteoflow SDK
-- @module meteoflow.errors

local errors = {}

--- Create an HTTP error
-- @param status HTTP status code
-- @param url Request URL
-- @param body Response body (string)
-- @param message Error message
-- @return Error table
function errors.http(status, url, body, message)
    return {
        kind = "http",
        message = message or ("HTTP error: " .. tostring(status)),
        status = status,
        url = url,
        body = body,
    }
end

--- Create a timeout error
-- @param url Request URL
-- @param message Error message
-- @return Error table
function errors.timeout(url, message)
    return {
        kind = "timeout",
        message = message or "Request timed out",
        url = url,
    }
end

--- Create a network error
-- @param url Request URL
-- @param message Error message
-- @return Error table
function errors.network(url, message)
    return {
        kind = "network",
        message = message or "Network error",
        url = url,
    }
end

--- Create a JSON decode error
-- @param url Request URL
-- @param body Response body (string)
-- @param message Error message
-- @return Error table
function errors.decode(url, body, message)
    return {
        kind = "decode",
        message = message or "Failed to decode JSON response",
        url = url,
        body = body,
    }
end

--- Create a validation error
-- @param message Error message
-- @return Error table
function errors.validation(message)
    return {
        kind = "validation",
        message = message or "Validation error",
    }
end

return errors
