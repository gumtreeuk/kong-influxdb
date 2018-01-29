local http = require 'kong.plugins.influxdb.http'

local buffer = {}
local options = {}
local bufferedMessages = {}

local function buildMsg(msg)
    local tags = ""
    if msg.tag then
        for k, v in pairs(msg.tag) do
            tags = tags .. "," .. k .. "=" .. v
        end
    end

    local fields = ""
    for k, v in pairs(msg.field) do
        fields = fields .. k .. "=" .. v .. ","
    end
    fields = fields:sub(1, -2) --Remove the last ,

    return msg.measurement .. tags .. " " .. fields .. " " .. msg.timestamp
end

function buffer.init(opts)
    options = opts
    return true
end

function buffer.buffer(msg)
    table.insert(bufferedMessages, msg)
end

function buffer.flush()
    local finalMsg = ""
    for i, msg in ipairs(bufferedMessages) do
        finalMsg = finalMsg .. buildMsg(msg) .. "\n"
    end
    finalMsg = finalMsg:sub(1, -2) --Remove the last \n

    bufferedMessages = {}

    if finalMsg ~= '' then
        http.post(finalMsg, options)
    end
end


return buffer