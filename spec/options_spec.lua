--- Tests for meteoflow.options module
-- Run with: busted spec/options_spec.lua

package.path = package.path .. ";meteoflow/?.lua;?.lua"

describe("meteoflow.options", function()
    local options

    setup(function()
        options = require("meteoflow.options")
    end)

    describe("new", function()
        it("should return empty table for nil options", function()
            local opts, err = options.new(nil)
            assert.is_nil(err)
            assert.is_table(opts)
            assert.is_nil(opts.days)
            assert.is_nil(opts.unit)
            assert.is_nil(opts.lang)
        end)

        it("should return empty table for empty options", function()
            local opts, err = options.new({})
            assert.is_nil(err)
            assert.is_table(opts)
        end)

        it("should accept valid days", function()
            local opts, err = options.new({ days = 5 })
            assert.is_nil(err)
            assert.equals(5, opts.days)
        end)

        it("should reject days less than 1", function()
            local opts, err = options.new({ days = 0 })
            assert.is_nil(opts)
            assert.equals("validation", err.kind)
            assert.matches("days", err.message)
        end)

        it("should reject non-integer days", function()
            local opts, err = options.new({ days = 1.5 })
            assert.is_nil(opts)
            assert.equals("validation", err.kind)
            assert.matches("integer", err.message)
        end)

        it("should reject negative days", function()
            local opts, err = options.new({ days = -1 })
            assert.is_nil(opts)
            assert.equals("validation", err.kind)
        end)

        it("should accept metric unit", function()
            local opts, err = options.new({ unit = "metric" })
            assert.is_nil(err)
            assert.equals("metric", opts.unit)
        end)

        it("should accept imperial unit", function()
            local opts, err = options.new({ unit = "imperial" })
            assert.is_nil(err)
            assert.equals("imperial", opts.unit)
        end)

        it("should reject invalid unit", function()
            local opts, err = options.new({ unit = "kelvin" })
            assert.is_nil(opts)
            assert.equals("validation", err.kind)
            assert.matches("metric", err.message)
        end)

        it("should accept valid BCP-47 lang codes", function()
            local test_cases = { "en", "ru", "de", "en-US", "de-AT", "zh-Hans" }
            for _, lang in ipairs(test_cases) do
                local opts, err = options.new({ lang = lang })
                assert.is_nil(err, "Failed for: " .. lang)
                assert.equals(lang, opts.lang)
            end
        end)

        it("should reject empty lang", function()
            local opts, err = options.new({ lang = "" })
            assert.is_nil(opts)
            assert.equals("validation", err.kind)
        end)

        it("should reject invalid lang format", function()
            local opts, err = options.new({ lang = "123" })
            assert.is_nil(opts)
            assert.equals("validation", err.kind)
            assert.matches("BCP-47", err.message)
        end)

        it("should accept combined options", function()
            local opts, err = options.new({
                days = 7,
                unit = "imperial",
                lang = "en-US",
            })
            assert.is_nil(err)
            assert.equals(7, opts.days)
            assert.equals("imperial", opts.unit)
            assert.equals("en-US", opts.lang)
        end)

        it("should reject non-table input", function()
            local opts, err = options.new("invalid")
            assert.is_nil(opts)
            assert.equals("validation", err.kind)
        end)
    end)

    describe("callable", function()
        it("should work as a callable", function()
            local opts, err = options({ days = 3 })
            assert.is_nil(err)
            assert.equals(3, opts.days)
        end)
    end)
end)
