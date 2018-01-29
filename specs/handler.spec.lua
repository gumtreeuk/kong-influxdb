package.path = package.path .. ";../src/?.lua"

require 'busted.runner'()

local match = require("luassert.match")

--Mocking dependencies
local BasePlugin = {
    extend = function() return {
        super = {
            new = function() end,
            init_worker = function() end,
            access = function() end,
            log = function() end
        }
    } end
}

package.loaded['kong.plugins.base_plugin'] = BasePlugin

local Errors = {}
local influx = {
    init = function() return true end,
    buffer = function() return true end,
    flush = function() return true end
}
package.loaded['kong.plugins.influxdb.buffer'] = influx
package.loaded['kong.dao.errors'] = Errors

--Globals
local callTimerFunc = false
_G.ngx = {
    req = {
        get_headers = function() return {} end,
        get_method = function() return 'GET' end,
        start_time = function() return 123 end
    },
    var = {
        request_time = 123
    },
    ctx = {
        api = {}
    },
    timer = {
        at = function(delay, f)
            if callTimerFunc == true then
                callTimerFunc = false
                f()
            end
        end
    },
    log = function() end,
    now = function() return 10 end
}

function setHeader(header, value)
    _G.ngx.req.get_headers = function()
        local tbl = {}
        tbl[header] = value
        return tbl
    end
end

-- Tests

local Handler = require "handler"

describe("handler", function()

    describe("new", function()
        it("calls super", function()
            local s = spy.on(Handler.super, 'new')
            Handler.new()

            assert.spy(s).was_called_with(_, "influxdb")
        end)
    end)

    describe("log", function()

        it("calls super", function()
            local s = spy.on(Handler.super, 'log')
            Handler.log(_, {})

            assert.spy(s).was_called_with(_)
        end)

        it("succeeds using default influx config", function()
            setHeader("X-Forwarded-For", "123.0.0.1")
            local s = spy.on(influx, 'buffer')
            local point = Handler.log(_, {})

            assert.are.same(point, true)
            assert.spy(s).was_called_with(match.is_table())
        end)

        it("succeeds using custom influx config", function()
            setHeader("X-Forwarded-For", "123.0.0.1")
            local point = Handler.log(_, {
                host = "example.org",
                port = "9999",
                proto = "html",
                ssl = true,
                db = "test-db",
                auth = "username:password"
            })
            assert.are.same(point, true)
        end)

        it("succeeds even if X-Forwarded-For header is missing", function()
            local point = Handler.log(_, {
                host = "example.org",
                port = "9999",
                proto = "html",
                ssl = true,
                db = "test-db",
                auth = "username:password"
            })
            assert.are.same(point, true)
        end)

        it("sets up timer to flush influx points", function()
            local s = spy.on(ngx.timer, 'at')
            Handler.flushHandlerRunning = false
            Handler.log(_, {})

            assert.spy(s).was_called_with(60, match.is_truthy()) --Unfortunalty there is no function matcher
        end)

        it("flushes after time over", function()
            local s = spy.on(influx, 'flush')
            callTimerFunc = true
            Handler.flushHandlerRunning = false
            Handler.log(_, {})

            assert.spy(s).called()
            callTimerFunc = false
        end)
    end)
end)