#!/usr/bin/env lua
--- Example: Get current weather by location slug
-- Usage: API_KEY=your_key lua examples/current_by_slug.lua

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

-- Create location by slug
local loc = meteoflow.location.slug("united-kingdom-london")

-- Get current weather
local data, err = client:current(loc)

if err then
    print("Error: " .. err.message)
    if err.status then
        print("HTTP Status: " .. err.status)
    end
    if err.body then
        print("Response: " .. err.body)
    end
    os.exit(1)
end

-- Print results
print("Current Weather for London, UK")
print("==============================")
if data.place then
    print("Location: " .. (data.place.name or "N/A"))
    print("Country: " .. (data.place.country or "N/A"))
    print("Timezone: " .. (data.place.timezone or "N/A"))
end
if data.current then
    print("Temperature: " .. (data.current.temperature_air or "N/A"))
    print("Humidity: " .. (data.current.humidity or "N/A"))
    print("Wind Speed: " .. (data.current.wind_speed or "N/A"))
end
