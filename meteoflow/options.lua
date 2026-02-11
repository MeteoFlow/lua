--- ForecastOptions validation for Meteoflow SDK
-- @module meteoflow.options

local errors = require("meteoflow.errors")

local options = {}

-- BCP-47 language tag pattern (simplified)
local BCP47_PATTERN = "^[A-Za-z][A-Za-z][A-Za-z]?%-?[A-Za-z0-9%-]*$"

-- Valid units values
local VALID_UNITS = {
    metric = true,
    imperial = true,
}

--- Validate and create forecast options
-- @param opts Options table (optional)
-- @return Validated options table or nil, error
function options.new(opts)
    if opts == nil then
        return {}
    end

    if type(opts) ~= "table" then
        return nil, errors.validation("options must be a table or nil")
    end

    local result = {}

    -- Validate days
    if opts.days ~= nil then
        if type(opts.days) ~= "number" then
            return nil, errors.validation("days must be a number")
        end
        if opts.days ~= math.floor(opts.days) then
            return nil, errors.validation("days must be an integer")
        end
        if opts.days < 1 then
            return nil, errors.validation("days must be >= 1")
        end
        result.days = opts.days
    end

    -- Validate unit
    if opts.unit ~= nil then
        if type(opts.unit) ~= "string" then
            return nil, errors.validation("unit must be a string")
        end
        if not VALID_UNITS[opts.unit] then
            return nil, errors.validation("unit must be 'metric' or 'imperial'")
        end
        result.unit = opts.unit
    end

    -- Validate lang (BCP-47)
    if opts.lang ~= nil then
        if type(opts.lang) ~= "string" then
            return nil, errors.validation("lang must be a string")
        end
        if opts.lang == "" then
            return nil, errors.validation("lang cannot be empty")
        end
        -- Simple BCP-47 validation: 2-3 letter primary tag, optional subtags
        if not opts.lang:match(BCP47_PATTERN) then
            return nil, errors.validation("lang must be a valid BCP-47 language tag (e.g., 'en', 'ru', 'de-AT')")
        end
        result.lang = opts.lang
    end

    return result
end

--- Shorthand for options.new (allows calling module as function)
setmetatable(options, {
    __call = function(_, opts)
        return options.new(opts)
    end
})

return options
