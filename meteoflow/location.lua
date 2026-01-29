--- Location factories for Meteoflow SDK
-- @module meteoflow.location

local errors = require("meteoflow.errors")

local location = {}

--- Create a location from a slug
-- @param slug Location slug string (e.g., "united-kingdom-london")
-- @return Location table or nil, error
function location.slug(slug)
    if type(slug) ~= "string" then
        return nil, errors.validation("slug must be a string")
    end
    if slug == "" then
        return nil, errors.validation("slug cannot be empty")
    end
    return {
        type = "slug",
        slug = slug,
    }
end

--- Create a location from coordinates
-- @param lat Latitude (-90 to 90)
-- @param lon Longitude (-180 to 180)
-- @return Location table or nil, error
function location.coords(lat, lon)
    if type(lat) ~= "number" then
        return nil, errors.validation("lat must be a number")
    end
    if type(lon) ~= "number" then
        return nil, errors.validation("lon must be a number")
    end
    if lat < -90 or lat > 90 then
        return nil, errors.validation("lat must be between -90 and 90")
    end
    if lon < -180 or lon > 180 then
        return nil, errors.validation("lon must be between -180 and 180")
    end
    return {
        type = "coords",
        lat = lat,
        lon = lon,
    }
end

--- Convert location to query parameters table
-- @param loc Location table
-- @return Query params table or nil, error
function location.to_query_params(loc)
    if type(loc) ~= "table" then
        return nil, errors.validation("location must be a table")
    end
    if loc.type == "slug" then
        return { slug = loc.slug }
    elseif loc.type == "coords" then
        return { lat = tostring(loc.lat), lon = tostring(loc.lon) }
    else
        return nil, errors.validation("invalid location type: must be created with location.slug() or location.coords()")
    end
end

--- Check if a table is a valid location
-- @param loc Location table
-- @return boolean
function location.is_valid(loc)
    if type(loc) ~= "table" then
        return false
    end
    if loc.type == "slug" then
        return type(loc.slug) == "string" and loc.slug ~= ""
    elseif loc.type == "coords" then
        return type(loc.lat) == "number" and type(loc.lon) == "number"
            and loc.lat >= -90 and loc.lat <= 90
            and loc.lon >= -180 and loc.lon <= 180
    end
    return false
end

return location
