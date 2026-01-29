--- WeatherClient for Meteoflow SDK
-- @module meteoflow.client

local http = require("meteoflow.http")
local location = require("meteoflow.location")
local options = require("meteoflow.options")
local errors = require("meteoflow.errors")

local Client = {}
Client.__index = Client

-- Default configuration
local DEFAULTS = {
    base_url = "https://api.meteoflow.com",
    timeout_ms = 5000,
    default_days = {
        hourly = 4,
        three_hourly = 4,
        daily = 4,
    },
    default_units = "metric",
    default_lang = "en",
}

--- Create a new WeatherClient
-- @param config Configuration table
-- @return WeatherClient instance or nil, error
function Client.new(config)
    if type(config) ~= "table" then
        return nil, errors.validation("config must be a table")
    end

    if not config.api_key or config.api_key == "" then
        return nil, errors.validation("api_key is required")
    end

    local self = setmetatable({}, Client)

    self.api_key = config.api_key
    self.base_url = config.base_url or DEFAULTS.base_url
    self.timeout_ms = config.timeout_ms or DEFAULTS.timeout_ms

    -- Merge default_days
    self.default_days = {}
    local cfg_days = config.default_days or {}
    self.default_days.hourly = cfg_days.hourly or DEFAULTS.default_days.hourly
    self.default_days.three_hourly = cfg_days.three_hourly or DEFAULTS.default_days.three_hourly
    self.default_days.daily = cfg_days.daily or DEFAULTS.default_days.daily

    self.default_units = config.default_units or DEFAULTS.default_units
    self.default_lang = config.default_lang or DEFAULTS.default_lang

    -- Create HTTP transport
    self.transport = http.new({
        base_url = self.base_url,
        timeout_ms = self.timeout_ms,
        api_key = self.api_key,
    })

    return self
end

--- Build query parameters from location and options
-- @param self Client instance
-- @param loc Location table
-- @param opts Options table (optional)
-- @param default_days_key Key for default days lookup
-- @return Query params table or nil, error
local function build_params(self, loc, opts, default_days_key)
    -- Validate location
    if not location.is_valid(loc) then
        return nil, errors.validation("invalid location: use meteoflow.location.slug() or meteoflow.location.coords()")
    end

    -- Get location params
    local params, err = location.to_query_params(loc)
    if not params then
        return nil, err
    end

    -- Validate and process options
    local validated_opts
    validated_opts, err = options.new(opts)
    if not validated_opts then
        return nil, err
    end

    -- Apply days (from options or default)
    if validated_opts.days then
        params.days = tostring(validated_opts.days)
    elseif default_days_key and self.default_days[default_days_key] then
        params.days = tostring(self.default_days[default_days_key])
    end

    -- Note: units and lang are in the spec but may not be supported by the API
    -- We include them if explicitly set in options
    if validated_opts.units then
        params.units = validated_opts.units
    end
    if validated_opts.lang then
        params.lang = validated_opts.lang
    end

    return params
end

--- Get current weather for a location
-- @param self Client instance
-- @param loc Location table (created with meteoflow.location.slug() or meteoflow.location.coords())
-- @return CurrentWeatherResponse table or nil, error
function Client:current(loc)
    local params, err = build_params(self, loc, nil, nil)
    if not params then
        return nil, err
    end

    return self.transport:get("/v2/current/", params)
end

--- Get hourly forecast for a location
-- @param self Client instance
-- @param loc Location table
-- @param opts ForecastOptions table (optional)
-- @return HourlyForecastResponse table or nil, error
function Client:forecastHourly(loc, opts)
    local params, err = build_params(self, loc, opts, "hourly")
    if not params then
        return nil, err
    end

    return self.transport:get("/v2/forecast/by-hours/", params)
end

--- Get 3-hourly forecast for a location
-- @param self Client instance
-- @param loc Location table
-- @param opts ForecastOptions table (optional)
-- @return ThreeHourlyForecastResponse table or nil, error
function Client:forecast3Hourly(loc, opts)
    local params, err = build_params(self, loc, opts, "three_hourly")
    if not params then
        return nil, err
    end

    return self.transport:get("/v2/forecast/by-3hours/", params)
end

--- Get daily forecast for a location
-- @param self Client instance
-- @param loc Location table
-- @param opts ForecastOptions table (optional)
-- @return DailyForecastResponse table or nil, error
function Client:forecastDaily(loc, opts)
    local params, err = build_params(self, loc, opts, "daily")
    if not params then
        return nil, err
    end

    return self.transport:get("/v2/forecast/by-days/", params)
end

return Client
