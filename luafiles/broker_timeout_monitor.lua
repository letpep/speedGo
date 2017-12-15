--
-- Created by IntelliJ IDEA.
-- User: lee_xin
-- Date: 17/12/15
-- Time: 下午2:57
-- To change this template use File | Settings | File Templates.
--
local json = require("cjson")
local http = require "resty.http"
local req_body= '{"version":true,"size":500,"sort":[{"@timestamp":{"order":"desc","unmapped_type":"boolean"}}],"query":{"bool":{"must":[{"query_string":{"analyze_wildcard":true,"query":"\"timed out\""}},{"match_phrase":{"path":{"query":"*errInvokerResult*"}}},{"range":{"@timestamp":{"gte":1513267200000,"lte":1513353599999,"format":"epoch_millis"}}}],"must_not":[]}},"_source":{"excludes":[]},"aggs":{"2":{"date_histogram":{"field":"@timestamp","interval":"30m","time_zone":"Asia/Shanghai","min_doc_count":1}}},"stored_fields":["*"],"script_fields":{},"docvalue_fields":["@timestamp"],"highlight":{"pre_tags":["@kibana-highlighted-field@"],"post_tags":["@/kibana-highlighted-field@"],"fields":{"*":{"highlight_query":{"bool":{"must":[{"query_string":{"analyze_wildcard":true,"query":"\"timed out\"","all_fields":true}},{"match_phrase":{"path":{"query":"*errInvokerResult*"}}},{"range":{"@timestamp":{"gte":1513267200000,"lte":1513353599999,"format":"epoch_millis"}}}],"must_not":[]}}}},"fragment_size":2147483647}}'
local res, err = httpc:request_uri("http://10.102.4.254:5601/api/console/proxy?path=_search&method=POST", {
    method = 'POST',
    body = '$req_body',
    headers = {
        ["Content-Type"] = "application/json",
        ["kbn-version"] = "5.6.4",
    }
})

if not res then
    ngx.say("failed to request: ", err)
    return
end
ngx.log(ngx.ERR,json.encode(res.body))
ngx.say(json.encode(res.body))