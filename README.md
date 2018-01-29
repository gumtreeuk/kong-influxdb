# kong-influxdb [![Build Status](https://travis-ci.org/gumtreeuk/kong-influxdb.svg?branch=master)](https://travis-ci.org/gumtreeuk/kong-influxdb)
A plugin for Kong to push metrics to InfluxDB

## Installation
This plugin can be installed via luarocks as follow:
```
luarocks install kong-influxdb
```

## Configuration
This plugin needs to be added to an existing API route in Kong using a request against the admin api.
For example:

```
$ curl -X POST http://kong:8001/apis/{api}/plugins \
    --data "name=kong-influxdb" \
    --data "config.host: http://myinfluxdb.com" \
    --data "config.port: 8086" \
    --data "config.db: myDB" \
    --data "config.username: myUsername" \
    --data "config.password: myPassword" \
    --data "config.measurement: myMeasurement" \
    --data "config.client_ip_header: MyHeader"
```

| Parameter  | Description |
| ------------- | ------------- |
| `name`  | Name of the plugin: `kong-influxdb`  |
| `config.host` | InfluxDB host  |
| `config.port`  | InfluxDB port  |
| `config.db`  | The db in InfluxDB to push the metrics to  |
| `config.username`  | Username to authenticate against InfluxDB if required |
| `config.password`  | Password to authenticate against InfluxDB if required  |
| `config.measurement`  | The name of the measurement to push metrics to; defaults to `kong`  |
| `config.client_ip_header`  | The header that contains the client ip; defaults to `X-Forwarded-For`  |
