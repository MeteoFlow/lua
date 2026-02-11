#!/usr/bin/env lua
--- Example: Get list of cities by country code
-- Usage: API_KEY=your_key lua examples/cities.lua

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

-- Get cities for Georgia
local data, err = client:cities("GE")

if err then
    print("Error: " .. err.message)
    os.exit(1)
end

-- Print results
print("Cities in Georgia (" .. #data .. " total)")
print("==============================")
for i, city in ipairs(data) do
    print(string.format("%-30s  %-30s  (%.2f, %.2f)", city.city_name, city.region_name or "", city.latitude, city.longitude))
    if i >= 10 then
        print("... and " .. (#data - 10) .. " more")
        break
    end
end
