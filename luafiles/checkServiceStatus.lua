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
httpc:set_timeout(500)
local red = redis.new()
local rdskey = 'serversStatus'
--统计当前ipurl 数量
    local rest, errt = red:exec(
        function(red)
            return red:zcard(rdskey)
        end
    )
    local totalnum = rest
    local erronnum =0
    local pagestart = 0
    local pageend = rest
   local res, err = red:exec(
        function(red)
            return red:zrevrange(rdskey ,pagestart,pageend,withscores)
        end
    )
    local httpres, httperr = '';
    for i, url in ipairs(res) do
        local httpres, httperr = httpc:request_uri(''..url, {
            method = 'GET',
            headers = {
                ["Content-Type"] = "application/json;charset=UTF-8",
            }
        })

        if httpres then
            ngx.log(ngx.ERR,'http_body is :'..httpres.body)
            local status = httpres.status
            if status ~= 200 then
                local content = url..''..'当前不能正常访问'
                ngx.log(ngx.ERR,content..'')
                local res, err = httpc:request_uri("http://10.102.251.242/servletSend", {
                    method = 'POST',
                    body = 'msgTel=18510512189&msgType=HOME&msgContent='..content,
                    headers = {
                        ["Content-Type"] = "application/x-www-form-urlencoded",

                    }
                })
                erronnum= erronnum+1
            end
        end
        if not httpres then
            ngx.log(ngx.ERR,'httpresponse is ERROR url:'..url)
            local content = url..''..'当前不能正常访问'
            local res, err = httpc:request_uri("http://10.102.251.242/servletSend", {
                method = 'POST',
                body = 'msgTel=18510512189&msgType=HOME&msgContent='..content,
                headers = {
                    ["Content-Type"] = "application/x-www-form-urlencoded",

                }
            })
            erronnum= erronnum+1
        end


    end
ngx.say('checkservers  totalnum: '..totalnum..' times  errnum: '..erronnum..' times')
