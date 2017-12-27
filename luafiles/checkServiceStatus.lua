--
-- Created by IntelliJ IDEA.
-- User: lee_xin
-- Date: 17/12/27
-- Time: 下午4:19
-- 检测所有服务的tomcat是否正常

-- 从redis 服务的访问地址 ，然后就行wget ，如果能正常访问即为正常，否则发短信
local redis = require("resty.rediscli-speedgo")
local json = require("cjson")
local http = require "resty.http"
local httpc = http.new()
local red = redis.new()
local rdskey = 'serversStatus'
--统计当前ipurl 数量
    local rest, errt = red:exec(
        function(red)
            return red:zcard(rdskey)
        end
    )
    local totalnum = rest
    local pagestart = 0
    local pageend = rest
   local res, err = red:exec(
        function(red)
            return red:zrevrange(rdskey ,pagestart,pageend,withscores)
        end
    )
    local httpres, httperr = '';
    for i, url in ipairs(res) do
        url = 'http://10.102.4.178:8080/serviceStatus'..''
        local httpres, httperr = httpc:request_uri(''..v, {
            method = 'GET',
            headers = {
                ["Content-Type"] = "application/json;charset=UTF-8",
            }
        })
        if not httpres then
         ngx.log(ngx.ERR,'http error')
        end
    end
