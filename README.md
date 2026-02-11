# Meteoflow Lua SDK

A Lua SDK for the [Meteoflow Weather API](https://api.meteoflow.com).

## Installation

### Via LuaRocks

```bash
luarocks install meteoflow
```

### From source

```bash
git clone https://github.com/meteoflow/lua.git meteoflow-lua
cd meteoflow-lua
luarocks make meteoflow-1.0.0.rockspec
```

### Dependencies

- Lua >= 5.1
- [LuaSocket](https://github.com/lunarmodules/luasocket) >= 3.0
- [LuaSec](https://github.com/lunarmodules/luasec) >= 1.0
- [lua-cjson](https://github.com/openresty/lua-cjson) >= 2.1

## Quick Start

```lua
local meteoflow = require("meteoflow")

-- Create client with your API key
local client = meteoflow.new({
    api_key = "YOUR_API_KEY",
})

-- Get current weather by location slug
local loc = meteoflow.location.slug("united-kingdom-london")
local data, err = client:current(loc)

if err then
    print("Error: " .. err.message)
else
    print("Temperature: " .. data.current.temperature_air)
end
```

## Configuration

```lua
local client = meteoflow.new({
    api_key = "YOUR_API_KEY",                -- Required
    base_url = "https://api.meteoflow.com",  -- Optional, default shown
    timeout_ms = 5000,                       -- Optional, request timeout in ms
    default_days = {                         -- Optional, default forecast days
        hourly = 4,
        three_hourly = 4,
        daily = 4,
    },
    default_unit = "metric",                -- Optional: "metric" or "imperial"
    default_lang = "en",                     -- Optional: BCP-47 language code
})
```

## Location

Locations can be specified by slug or coordinates:

```lua
-- By slug
local loc1 = meteoflow.location.slug("united-kingdom-london")

-- By coordinates
local loc2 = meteoflow.location.coords(51.5072, -0.1275)
```

### Validation

- **slug**: Must be a non-empty string
- **coords**: lat must be in [-90, 90], lon must be in [-180, 180]

## API Methods

### current(location)

Get current weather for a location.

```lua
local data, err = client:current(loc)
```

### forecastHourly(location, options)

Get hourly forecast for a location.

```lua
local data, err = client:forecastHourly(loc, { days = 4 })
```

### forecast3Hourly(location, options)

Get 3-hourly forecast for a location.

```lua
local data, err = client:forecast3Hourly(loc, { days = 4 })
```

### forecastDaily(location, options)

Get daily forecast for a location.

```lua
local data, err = client:forecastDaily(loc, { days = 7 })
```

## Forecast Options

```lua
local opts = {
    days = 4,           -- Number of days (integer >= 1)
    units = "metric",   -- "metric" or "imperial"
    lang = "en",        -- BCP-47 language code (e.g., "en", "ru", "de-AT")
}

local data, err = client:forecastDaily(loc, opts)
```

You can also use the options helper for validation:

```lua
local opts, err = meteoflow.options({ days = 4, units = "metric" })
if err then
    print("Invalid options: " .. err.message)
end
```

## Method to Endpoint Mapping

| Method | HTTP Endpoint |
|--------|--------------|
| `current(loc)` | `GET /v2/current/` |
| `forecastHourly(loc, opts)` | `GET /v2/forecast/by-hours/` |
| `forecast3Hourly(loc, opts)` | `GET /v2/forecast/by-3hours/` |
| `forecastDaily(loc, opts)` | `GET /v2/forecast/by-days/` |

## Error Handling

All methods return `data, nil` on success or `nil, err` on error.

The error table has the following structure:

```lua
{
    kind = "http" | "timeout" | "network" | "decode" | "validation",
    message = "Human-readable error message",
    status = 400,            -- HTTP status code (only for "http" errors)
    url = "https://...",     -- Request URL (when available)
    body = "...",            -- Response body as string (when available)
}
```

### Error Kinds

| Kind | Description |
|------|-------------|
| `http` | Non-200 HTTP response |
| `timeout` | Request timed out |
| `network` | Network/connection error |
| `decode` | JSON parsing failed |
| `validation` | Invalid input parameters |

### Example

```lua
local data, err = client:current(loc)

if err then
    if err.kind == "http" and err.status == 401 then
        print("Invalid API key")
    elseif err.kind == "timeout" then
        print("Request timed out, please try again")
    elseif err.kind == "validation" then
        print("Invalid input: " .. err.message)
    else
        print("Error: " .. err.message)
    end
    return
end

-- Use data...
```

## Response Structure

The SDK returns JSON responses from the API as-is (no field renaming). Common response fields include:

- `place` - Location information (country, timezone, coordinates, names)
- `current` - Current weather data (for `current()` method)
- `forecast` - Forecast array (for `forecastHourly()` and `forecast3Hourly()`)
- `daily` - Daily forecast array (for `forecastDaily()`)
- `astronomy` - Astronomical data (sunrise, sunset, moon phase)

## Examples

See the [examples/](examples/) directory for complete working examples.

## License

MIT License. See [LICENSE](LICENSE) for details.
