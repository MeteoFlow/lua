--- Meteoflow SDK for Lua
-- A Lua SDK for the Meteoflow Weather API
-- @module meteoflow

local Client = require("meteoflow.client")
local location = require("meteoflow.location")
local options = require("meteoflow.options")
local version = require("meteoflow.version")

local meteoflow = {}

--- SDK version
meteoflow.VERSION = version

--- Location factories
-- @field slug Create location from slug string
-- @field coords Create location from coordinates
meteoflow.location = location

--- Options factory
-- @usage local opts = meteoflow.options({ days = 4, units = "metric", lang = "en" })
meteoflow.options = options

--- Create a new WeatherClient
-- @param config Configuration table
-- @param config.api_key API key (required)
-- @param config.base_url Base URL (default: "https://api.meteoflow.com")
-- @param config.timeout_ms Request timeout in milliseconds (default: 5000)
-- @param config.default_days Default days for forecasts (table with hourly, three_hourly, daily keys)
-- @param config.default_units Default units ("metric" or "imperial", default: "metric")
-- @param config.default_lang Default language (BCP-47 code, default: "en")
-- @return WeatherClient instance or nil, error
-- @usage
-- local client = meteoflow.new({
--     api_key = "YOUR_API_KEY",
--     base_url = "https://api.meteoflow.com",
--     timeout_ms = 5000,
--     default_days = { hourly = 4, three_hourly = 4, daily = 4 },
--     default_units = "metric",
--     default_lang = "en",
-- })
function meteoflow.new(config)
    return Client.new(config)
end

return meteoflow
