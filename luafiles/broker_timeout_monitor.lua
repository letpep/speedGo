--
-- Created by IntelliJ IDEA.
-- User: lee_xin
-- Date: 17/12/15
-- Time: 下午2:57
-- To change this template use File | Settings | File Templates.
--
local json = require("cjson")
local http = require "resty.http"
local httpc = http.new()
local queryjson = '"query":{"bool":{"must":[{"query_string":{"analyze_wildcard":true,"query":"\"timed out\""}},{"match_phrase":{"path":{"query":"*errInvokerResult*"}}},{"range":{"@timestamp":{"gte":1513267200000,"lte":1513353599999,"format":"epoch_millis"}}}],"must_not":[]}}';

local res, err = httpc:request_uri("http://10.102.4.254:5601/api/console/proxy?path=_search&method=POST", {
    method = 'POST',
    body = '{"version":true,"size":0,'..queryjson..'}',
    headers = {
        ["Content-Type"] = "application/json;charset=UTF-8",
        ["kbn-version"] = "5.6.4",
    }
})

if not res then
    ngx.say("failed to request: ", err)
    return
end
local resultd = json.decode(res.body)
local hits = resultd["hits"]["total"]

ngx.say(hits)
