--
-- Created by IntelliJ IDEA.
-- User: lee_xin
-- Date: 17/12/15
-- Time: 下午2:57
-- To change this template use File | Settings | File Templates.
--监控超时次数
local json = require("cjson")
local http = require "resty.http"
local httpc = http.new()
--只需要从请求串中json里的到quer属性
--切记查询字符串中加的双引号在这里要去掉，如下"timed out"
local querypre = '"query":{"bool":{"must":[';
local queryend = '],"must_not":[]}}';
local queryString = '{"query_string":{"analyze_wildcard":true,"query":"timed out"}}'
local querymatch = '{"match_phrase":{"path":{"query":"*errInvokerResult*"}}}'
local nowtime = os.time(); --时间戳 秒
local nowtimestr = os.date("%Y-%m-%d %H:%M", os.time())
local last1hour = nowtime - 60 * 60; --一小时前

local querytime = '{"range":{"@timestamp":{"gte":' .. 1000 * last1hour .. ',"format":"epoch_millis"}}}'
local queryjson = querypre .. queryString .. ',' .. querymatch .. ',' .. querytime .. queryend;
local request_boby = '{"version":true,"size":0,' .. queryjson .. '}'
ngx.log(ngx.ERR, request_boby)
local res, err = httpc:request_uri("http://10.102.4.254:5601/api/console/proxy?path=_search&method=POST", {
    method = 'POST',
    body = '' .. request_boby,
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
--将数据写入有序队列
local  rdskey_timeout = "timeoutLine"
local  rdskey_score =nowtime
local  rdskey_value = nowtimestr.." occured  "..hits..' times'
if hits > 0 then
    local content = '当前超时' .. hits .. '次'
    local res, err = httpc:request_uri("http://letpep.com/redis_zadd", {
        method = 'POST',
        body = 'key='..rdskey_timeout..'&value='..rdskey_value..'&score=' ..rdskey_score,
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
        }
    })
end

if hits > 50 then
    local content = '当前超时' .. hits .. '次'
    local res, err = httpc:request_uri("http://10.102.251.242/servletSend", {
        method = 'POST',
        body = 'msgTel=18510512189&msgType=HOME&msgContent=' .. content,
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
        }
    })
end

ngx.say(nowtimestr .. ' ' .. hits .. ' times')
