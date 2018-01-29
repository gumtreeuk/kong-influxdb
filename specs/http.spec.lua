package.path = package.path .. ";../src/?.lua"

require 'busted.runner'()

local match = require("luassert.match")

local httpResponse = {status = 204}
local http = {
    new = function() return {
        request_uri = function() return httpResponse end
    } end
}
package.loaded['resty.http'] = http

--Globals
_G.ngx = {
    encode_base64 = function(input) return input end,
    HTTP_NO_CONTENT = 204
}

local http = require 'http'

describe("http", function()
    describe("post", function()
        it("should execute http post and return true if successful", function()
            httpResponse = {status = 204}

            local res = http.post("testProto", {host = "testHost", port = 1234, db = "testDb"})
            assert.are.same(res, true)
        end)
        it("should execute http post and return false if error while executing", function()
            httpResponse = false

            local res = http.post("testProto", {host = "testHost", port = 1234, db = "testDb"})
            assert.are.same(res, false)
        end)
        it("should execute http post and return false if non 204 error code", function()
            httpResponse = {status = 400}

            local res = http.post("testProto", {host = "testHost", port = 1234, db = "testDb"})
            assert.are.same(res, false)
        end)
    end)
end)