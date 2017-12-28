--
-- Created by IntelliJ IDEA.
-- User: lee_xin
-- Date: 17/12/15
-- Time: 下午4:29
-- To change this template use File | Settings | File Templates.
--


--local handle =io.popen('curl -l -H "kbn-version:5.6.4" -X POST "http://10.102.4.254:5601/api/console/proxy?path=_search&method=POST" -d '..'{"version":true,"size":0,"sort":[{"@timestamp":{"order":"desc","unmapped_type":"boolean"}}],"query":{"bool":{"must":[{"query_string":{"analyze_wildcard":true,"query":"\"timed out\""}},{"match_phrase":{"path":{"query":"*errInvokerResult*"}}},{"range":{"@timestamp":{"gte":1513267200000,"lte":1513353599999,"format":"epoch_millis"}}}],"must_not":[]}},"_source":{"excludes":[]},"aggs":{"2":{"date_histogram":{"field":"@timestamp","interval":"30m","time_zone":"Asia/Shanghai","min_doc_count":1}}},"stored_fields":["*"],"script_fields":{},"docvalue_fields":["@timestamp"],"highlight":{"pre_tags":["@kibana-highlighted-field@"],"post_tags":["@/kibana-highlighted-field@"],"fields":{"*":{"highlight_query":{"bool":{"must":[{"query_string":{"analyze_wildcard":true,"query":"\"timed out\"","all_fields":true}},{"match_phrase":{"path":{"query":"*errInvokerResult*"}}},{"range":{"@timestamp":{"gte":1513267200000,"lte":1513353599999,"format":"epoch_millis"}}}],"must_not":[]}}}},"fragment_size":2147483647}}')
--local result = handle:read("*a")
--handle:close()
--ngx.say(result)
local http = require ("resty.http")
local httpc = http.new()
httpc:set_timeout(500)
local httpres, httperr = httpc:request_uri(''..'http://10.103.16.113/checkServiceStatus', {
    method = 'GET',
    headers = {
        ["Content-Type"] = "application/json;charset=UTF-8",
    }
})
if httpres then
    ngx.say(httpres.body..httpres.status..'')
end
if not httpres then
    ngx.say('11'..httperr)
end

