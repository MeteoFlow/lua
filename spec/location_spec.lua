--- Tests for meteoflow.location module
-- Run with: busted spec/location_spec.lua

package.path = package.path .. ";meteoflow/?.lua;?.lua"

describe("meteoflow.location", function()
    local location

    setup(function()
        location = require("meteoflow.location")
    end)

    describe("slug", function()
        it("should create a valid slug location", function()
            local loc, err = location.slug("united-kingdom-london")
            assert.is_nil(err)
            assert.is_table(loc)
            assert.equals("slug", loc.type)
            assert.equals("united-kingdom-london", loc.slug)
        end)

        it("should reject nil slug", function()
            local loc, err = location.slug(nil)
            assert.is_nil(loc)
            assert.is_table(err)
            assert.equals("validation", err.kind)
        end)

        it("should reject empty string slug", function()
            local loc, err = location.slug("")
            assert.is_nil(loc)
            assert.is_table(err)
            assert.equals("validation", err.kind)
            assert.matches("empty", err.message)
        end)

        it("should reject non-string slug", function()
            local loc, err = location.slug(123)
            assert.is_nil(loc)
            assert.is_table(err)
            assert.equals("validation", err.kind)
        end)
    end)

    describe("coords", function()
        it("should create valid coordinates", function()
            local loc, err = location.coords(51.5072, -0.1275)
            assert.is_nil(err)
            assert.is_table(loc)
            assert.equals("coords", loc.type)
            assert.equals(51.5072, loc.lat)
            assert.equals(-0.1275, loc.lon)
        end)

        it("should accept boundary values", function()
            local loc1, err1 = location.coords(90, 180)
            assert.is_nil(err1)
            assert.equals(90, loc1.lat)
            assert.equals(180, loc1.lon)

            local loc2, err2 = location.coords(-90, -180)
            assert.is_nil(err2)
            assert.equals(-90, loc2.lat)
            assert.equals(-180, loc2.lon)
        end)

        it("should reject latitude out of range", function()
            local loc, err = location.coords(91, 0)
            assert.is_nil(loc)
            assert.is_table(err)
            assert.equals("validation", err.kind)
            assert.matches("lat", err.message)
        end)

        it("should reject negative latitude out of range", function()
            local loc, err = location.coords(-91, 0)
            assert.is_nil(loc)
            assert.equals("validation", err.kind)
        end)

        it("should reject longitude out of range", function()
            local loc, err = location.coords(0, 181)
            assert.is_nil(loc)
            assert.equals("validation", err.kind)
            assert.matches("lon", err.message)
        end)

        it("should reject non-numeric latitude", function()
            local loc, err = location.coords("51", 0)
            assert.is_nil(loc)
            assert.equals("validation", err.kind)
        end)

        it("should reject non-numeric longitude", function()
            local loc, err = location.coords(0, "0")
            assert.is_nil(loc)
            assert.equals("validation", err.kind)
        end)
    end)

    describe("to_query_params", function()
        it("should convert slug to query params", function()
            local loc = { type = "slug", slug = "london" }
            local params, err = location.to_query_params(loc)
            assert.is_nil(err)
            assert.equals("london", params.slug)
        end)

        it("should convert coords to query params", function()
            local loc = { type = "coords", lat = 51.5, lon = -0.12 }
            local params, err = location.to_query_params(loc)
            assert.is_nil(err)
            assert.equals("51.5", params.lat)
            assert.equals("-0.12", params.lon)
        end)

        it("should reject invalid location type", function()
            local loc = { type = "invalid" }
            local params, err = location.to_query_params(loc)
            assert.is_nil(params)
            assert.equals("validation", err.kind)
        end)
    end)

    describe("is_valid", function()
        it("should return true for valid slug", function()
            local loc = location.slug("test")
            assert.is_true(location.is_valid(loc))
        end)

        it("should return true for valid coords", function()
            local loc = location.coords(0, 0)
            assert.is_true(location.is_valid(loc))
        end)

        it("should return false for nil", function()
            assert.is_false(location.is_valid(nil))
        end)

        it("should return false for empty table", function()
            assert.is_false(location.is_valid({}))
        end)
    end)
end)
