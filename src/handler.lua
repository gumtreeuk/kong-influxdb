local BasePlugin = require "kong.plugins.base_plugin"
local buffer = require "kong.plugins.influxdb.buffer"

local function influxdb_point(ngx, conf)
  local var = ngx.var
  local ctx = ngx.ctx
  local authenticated_credential = ctx.authenticated_credential
  local method = ngx.req.get_method()
  local started_at = ngx.req.start_time()
  local measurement = conf.measurement or "kong"
  local client_ip_header = conf.client_ip_header or "X-Forwarded-For"

  return {
      measurement = measurement,
      tag = {
        scheme = var.scheme,
        host = var.host,
        uri = var.uri,
        request_method = method,
        response_status = ngx.status,
        client_ip_header = ngx.req.get_headers()[client_ip_header],
        client_ip = var.remote_addr,
        api_id = ctx.api.id,
        authenticated_entity_id = authenticated_credential and authenticated_credential.id,
        authenticated_entity_consumer_id = authenticated_credential and authenticated_credential.consumer_id
      },
      field = {
        request_size = var.request_length,
        response_size = var.bytes_sent,
        latency_upstream = (ctx.KONG_ACCESS_TIME or 0) + (ctx.KONG_RECEIVE_TIME or 0),
        latency_proxy = ctx.KONG_WAITING_TIME or -1,
        latency_request = var.request_time * 1000,
        started_at = started_at * 1000
      },
      timestamp = (ngx.now() * 1000)
    }
end

local FLUSH_DELAY = 60

local function flushHandler(premature)
    if premature == true then return end

    buffer.flush()

    local ok, err = ngx.timer.at(FLUSH_DELAY, flushHandler)
    if not ok then
        ngx.log(ngx.ERR, "failed to create the timer: ", err)
    end
end

local InfluxDB = BasePlugin:extend()

InfluxDB.PRIORITY = 992
InfluxDB.flushHandlerRunning = false

function InfluxDB:new()
    InfluxDB.super.new(self, "influxdb")
end

function InfluxDB:log(conf)
    InfluxDB.super.log(self)

    local ok, err = buffer.init({
        host = conf.host,
        port = conf.port,
        proto = conf.proto,
        db = conf.db,
        auth = conf.username and conf.password and conf.username.. ":" ..conf.password or Nil
    })

    if (not ok) then
        ngx.log(ngx.ERR, err)
        return false
    end

    InfluxDB.setupFlushHandler()

    local point = influxdb_point(ngx, conf)
    buffer.buffer(point)

    return true, point
end

function InfluxDB:setupFlushHandler()
    if InfluxDB.flushHandlerRunning == true then return end
    InfluxDB.flushHandlerRunning = true

    local ok, err = ngx.timer.at(FLUSH_DELAY, flushHandler)
    if not ok then
        ngx.log(ngx.ERR, "failed to create the timer: ", err)
    end
end

return InfluxDB
