package = "kong-influxdb"
version = "1.0-1"
source = {
  url = "https://github.com/gumtreeuk/kong-influxdb"
}
description = {
  summary = "A plugin for Kong to push metrics to InfluxDB"
}
dependencies = {
}
build = {
  type = "builtin",
  modules = {
    ["kong.plugins.influxdb.handler"] = "src/handler.lua",
    ["kong.plugins.influxdb.schema"] = "src/schema.lua",
    ["kong.plugins.influxdb.buffer"] = "src/buffer.lua",
    ["kong.plugins.influxdb.http"] = "src/http.lua"
  }
}
