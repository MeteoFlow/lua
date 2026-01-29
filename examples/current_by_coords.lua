#!/usr/bin/env lua
--- Example: Get current weather by coordinates
-- Usage: API_KEY=your_key lua examples/current_by_coords.lua

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

-- Create location by coordinates (London)
local loc, err = meteoflow.location.coords(51.5072, -0.1275)
if not loc then
    print("Error creating location: " .. err.message)
    os.exit(1)
end

-- Get current weather
local data, err = client:current(loc)

if err then
    print("Error: " .. err.message)
    if err.status then
        print("HTTP Status: " .. err.status)
    end
    os.exit(1)
end

-- Print results
print("Current Weather at 51.5072, -0.1275")
print("===================================")
if data.place then
    print("Location: " .. (data.place.city_name or "N/A"))
end
if data.current then
    print("Temperature: " .. (data.current.temperature_air or "N/A"))
end
