#!/usr/bin/env lua
--- Example: Get 3-hourly forecast
-- Usage: API_KEY=your_key lua examples/forecast_3hourly.lua

package.path = package.path .. ";meteoflow/?.lua;?.lua"

local meteoflow = require("meteoflow")

-- Get API key from environment
local api_key = os.getenv("API_KEY") or os.getenv("METEOFLOW_API_KEY")
if not api_key then
    print("Error: Please set API_KEY or METEOFLOW_API_KEY environment variable")
    os.exit(1)
end

-- Create client
local client, err = meteoflow.new({
    api_key = api_key,
})

if not client then
    print("Error creating client: " .. err.message)
    os.exit(1)
end

-- Create location by coordinates
local loc = meteoflow.location.coords(51.5072, -0.1275)

-- Get 3-hourly forecast with options
local data, err = client:forecast3Hourly(loc, { days = 3 })

if err then
    print("Error: " .. err.message)
    os.exit(1)
end

-- Print results
print("3-Hourly Forecast")
print("=================")
if data.place then
    print("Location: " .. (data.place.city_name or "N/A"))
end
if data.forecast and type(data.forecast) == "table" then
    print("\nForecast entries: " .. #data.forecast)
    -- Print first 5 entries
    for i = 1, math.min(5, #data.forecast) do
        local entry = data.forecast[i]
        print(string.format("  [%d] %s - Temp: %s",
            i,
            entry.date or "N/A",
            entry.temperature_air  or "N/A"
        ))
    end
end
