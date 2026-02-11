#!/usr/bin/env lua
--- Example: Search cities by name
-- Usage: API_KEY=your_key lua examples/search_cities.lua

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

-- Search for cities matching "Berlin"
local data, err = client:searchCities("Berlin", 5)

if err then
    print("Error: " .. err.message)
    os.exit(1)
end

-- Print results
print("Search results for 'Berlin' (" .. #data .. " found)")
print("==============================")
for _, city in ipairs(data) do
    print(string.format("%-20s  %-20s  %-5s  (%.2f, %.2f)", city.city_name, city.country_name, city.country, city.latitude, city.longitude))
end
