#!/usr/bin/env lua
--- Example: Get daily forecast
-- Usage: API_KEY=your_key lua examples/forecast_daily.lua

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

-- Create location
local loc = meteoflow.location.slug("united-kingdom-london")

-- Get daily forecast
local data, err = client:forecastDaily(loc, { days = 7 })

if err then
    print("Error: " .. err.message)
    os.exit(1)
end

-- Print results
print("Daily Forecast for London, UK")
print("=============================")
if data.place then
    print("Location: " .. (data.place.name or "N/A"))
end
if data.daily and type(data.daily) == "table" then
    print("\nDaily entries: " .. #data.daily)
    for i, day in ipairs(data.daily) do
        print(string.format("  [%d] %s - High: %s, Low: %s",
            i,
            day.date or day.datetime or "N/A",
            day.temperature_max or day.temp_max or "N/A",
            day.temperature_min or day.temp_min or "N/A"
        ))
    end
end

-- Print astronomy data if available
if data.astronomy then
    print("\nAstronomy data available")
end
