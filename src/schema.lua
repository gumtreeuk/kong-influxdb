local Errors = require "kong.dao.errors"

return {
    fields = {
        host = {type = "string"},
        port = {type = "number"},
        proto = {type = "string"},
        db = {type = "string"},
        username = {type = "string"},
        password = {type = "string"},
        measurement = {type = "string"},
        client_ip_header = {type = "string"}
    },
    self_check = function(schema, plugin_t, dao, is_update)

        if not plugin_t.host or #plugin_t.host == 0 then
            return false, Errors.schema "you must provide the host"
        end

        if not plugin_t.port or plugin_t.port == 0 then
            return false, Errors.schema "you must provide the port"
        end

        if not plugin_t.db or #plugin_t.db == 0 then
            return false, Errors.schema "you must provide the db"
        end

        return true
    end
}