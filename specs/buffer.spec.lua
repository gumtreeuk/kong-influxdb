package.path = package.path .. ";../src/?.lua"

require 'busted.runner'()

local match = require("luassert.match")

local http = {
    post = function() return true end
}
package.loaded['kong.plugins.influxdb.http'] = http

local buffer = require 'buffer'

describe("buffer", function()
    describe("init, buffer, flush", function()
        it("should http post when flushing and msg existing", function()
            local s = spy.on(http, 'post')
            buffer.buffer({measurement= "test", field={testField=123}, timestamp = 10000})
            buffer.flush()

            assert.spy(s).was_called_with("test testField=123 10000", match.is_table())
        end)
        it("should not http post when flushing if msg not existing", function()
            local s = spy.on(http, 'post')
            buffer.flush()

            assert.spy(s).was_not_called_with(_, _)
        end)
        it("should use options from init when flushing", function()
            local s = spy.on(http, 'post')
            buffer.init({testOption=2345})
            buffer.buffer({measurement= "test", field={testField=123}, timestamp = 10000})
            buffer.flush()

            assert.spy(s).was_called_with("test testField=123 10000", {testOption=2345})
        end)
        it("should use multiple buffered msgs when flushing", function()
            local s = spy.on(http, 'post')
            buffer.buffer({measurement= "test", field={testField=1}, timestamp = 10000})
            buffer.buffer({measurement= "test", field={testField=2}, timestamp = 10000})
            buffer.buffer({measurement= "testOther", field={testFieldString="test"}, timestamp = 10000})
            buffer.buffer({measurement= "testOther", field={testFieldString="test"}, timestamp = 10000})
            buffer.buffer({measurement= "testTagsAndFields",
                           tag={testTag="tag1"},
                           field={testFieldString="test"},
                           timestamp = 10000})
            buffer.flush()

            assert.spy(s).was_called_with(
                    "test testField=1 10000\n" ..
                    "test testField=2 10000\n" ..
                    "testOther testFieldString=test 10000\n" ..
                    "testOther testFieldString=test 10000\n" ..
                    "testTagsAndFields,testTag=tag1 testFieldString=test 10000"
                , match.is_table())
        end)
    end)
end)