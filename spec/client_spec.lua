--- Tests for meteoflow.client module
-- Run with: busted spec/client_spec.lua

package.path = package.path .. ";meteoflow/?.lua;?.lua"

describe("meteoflow.client", function()
    local Client
    local location

    setup(function()
        Client = require("meteoflow.client")
        location = require("meteoflow.location")
    end)

    describe("new", function()
        it("should create client with valid config", function()
            local client, err = Client.new({
                api_key = "test-key",
            })
            assert.is_nil(err)
            assert.is_table(client)
            assert.equals("test-key", client.api_key)
        end)

        it("should use default base_url", function()
            local client = Client.new({ api_key = "test" })
            assert.equals("https://api.meteoflow.com", client.base_url)
        end)

        it("should use custom base_url", function()
            local client = Client.new({
                api_key = "test",
                base_url = "https://custom.api.com",
            })
            assert.equals("https://custom.api.com", client.base_url)
        end)

        it("should use default timeout", function()
            local client = Client.new({ api_key = "test" })
            assert.equals(5000, client.timeout_ms)
        end)

        it("should use custom timeout", function()
            local client = Client.new({
                api_key = "test",
                timeout_ms = 10000,
            })
            assert.equals(10000, client.timeout_ms)
        end)

        it("should use default days", function()
            local client = Client.new({ api_key = "test" })
            assert.equals(4, client.default_days.hourly)
            assert.equals(4, client.default_days.three_hourly)
            assert.equals(4, client.default_days.daily)
        end)

        it("should merge custom default_days", function()
            local client = Client.new({
                api_key = "test",
                default_days = { hourly = 2 },
            })
            assert.equals(2, client.default_days.hourly)
            assert.equals(4, client.default_days.three_hourly)
            assert.equals(4, client.default_days.daily)
        end)

        it("should require api_key", function()
            local client, err = Client.new({})
            assert.is_nil(client)
            assert.is_table(err)
            assert.equals("validation", err.kind)
            assert.matches("api_key", err.message)
        end)

        it("should reject empty api_key", function()
            local client, err = Client.new({ api_key = "" })
            assert.is_nil(client)
            assert.equals("validation", err.kind)
        end)

        it("should reject non-table config", function()
            local client, err = Client.new("invalid")
            assert.is_nil(client)
            assert.equals("validation", err.kind)
        end)
    end)

    describe("methods exist", function()
        local client

        setup(function()
            client = Client.new({ api_key = "test" })
        end)

        it("should have current method", function()
            assert.is_function(client.current)
        end)

        it("should have forecastHourly method", function()
            assert.is_function(client.forecastHourly)
        end)

        it("should have forecast3Hourly method", function()
            assert.is_function(client.forecast3Hourly)
        end)

        it("should have forecastDaily method", function()
            assert.is_function(client.forecastDaily)
        end)
    end)

    describe("input validation", function()
        local client

        setup(function()
            client = Client.new({ api_key = "test" })
        end)

        it("should reject invalid location for current", function()
            local data, err = client:current({})
            assert.is_nil(data)
            assert.equals("validation", err.kind)
        end)

        it("should reject invalid location for forecastHourly", function()
            local data, err = client:forecastHourly({})
            assert.is_nil(data)
            assert.equals("validation", err.kind)
        end)

        it("should reject invalid options for forecastDaily", function()
            local loc = location.slug("test")
            local data, err = client:forecastDaily(loc, { days = 0 })
            assert.is_nil(data)
            assert.equals("validation", err.kind)
        end)
    end)
end)
