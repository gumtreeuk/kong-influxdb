package.path = package.path .. ";../src/?.lua"

require 'busted.runner'()

local match = require("luassert.match")

local Errors = {}
package.loaded['kong.dao.errors'] = Errors

describe("schema", function()
    describe("table", function()
        it("contains fields", function()
            local tbl = require "schema"
            assert.are.same(tbl.fields.host, {type = "string"})
            assert.are.same(tbl.fields.port, {type = "number"})
            assert.are.same(tbl.fields.proto.type, "string")
            assert.are.same(tbl.fields.db.type, "string")
            assert.are.same(tbl.fields.username.type, "string")
            assert.are.same(tbl.fields.password.type, "string")
            assert.are.same(tbl.fields.measurement.type, "string")
            assert.are.same(tbl.fields.client_ip_header.type, "string")
        end)
    end)

    describe("self check", function()

        it("returns true if host, port and db properly set", function()
            local tbl = require "schema"
            local plugin_t = {
                host = "example.com",
                port = "9999",
                db = "test-db"
            }
            local result = tbl.self_check(_, plugin_t, _, _)
            assert.True(result)
        end)

        it("returns false if host is not set", function()
            Errors.schema = function() end

            local tbl = require "schema"
            local plugin_t = {
                port = "9999",
                db = "test-db"
            }
            local result = tbl.self_check(_, plugin_t, _, _)
            assert.False(result)
        end)

        it("returns false if host is empty", function()
            Errors.schema = function() end

            local tbl = require "schema"
            local plugin_t = {
                host = "",
                port = "9999",
                db = "test-db"
            }
            local result = tbl.self_check(_, plugin_t, _, _)
            assert.False(result)
        end)

        it("returns false if port is not set", function()
            Errors.schema = function() end

            local tbl = require "schema"
            local plugin_t = {
                host = "example.com",
                db = "test-db"
            }
            local result = tbl.self_check(_, plugin_t, _, _)
            assert.False(result)
        end)

        it("returns false if port is zero", function()
            Errors.schema = function() end

            local tbl = require "schema"
            local plugin_t = {
                host = "example.com",
                port = 0,
                db = "test-db"
            }
            local result = tbl.self_check(_, plugin_t, _, _)
            assert.False(result)
        end)

        it("returns false if db is not set", function()
            Errors.schema = function() end

            local tbl = require "schema"
            local plugin_t = {
                host = "example.com",
                port = "9999"
            }
            local result = tbl.self_check(_, plugin_t, _, _)
            assert.False(result)
        end)

        it("returns false if db is empty", function()
            Errors.schema = function() end

            local tbl = require "schema"
            local plugin_t = {
                host = "example.com",
                port = "9999",
                db = ""
            }
            local result = tbl.self_check(_, plugin_t, _, _)
            assert.False(result)
        end)
    end)
end)