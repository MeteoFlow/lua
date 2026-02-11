#!/usr/bin/env lua
--- Example: Get list of all countries
-- Usage: API_KEY=your_key lua examples/countries.lua

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

-- Get all countries
local data, err = client:countries()

if err then
    print("Error: " .. err.message)
    os.exit(1)
end

-- Print results
print("Countries (" .. #data .. " total)")
print("==============================")
for i, country in ipairs(data) do
    print(string.format("%-3s  %-40s  %s", country.country_code, country.country_name, country.country_slug))
    if i >= 10 then
        print("... and " .. (#data - 10) .. " more")
        break
    end
end
