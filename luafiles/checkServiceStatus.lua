--
-- Created by IntelliJ IDEA.
-- User: lee_xin
-- Date: 17/12/27
-- Time: 下午4:19
-- 检测所有服务的tomcat是否正常

-- 从redis 服务的访问地址 ，然后就行wget ，如果能正常访问即为正常，否则发短信
local redis = require("resty.rediscli-speedgo")
local json = require("cjson")
local http = require("resty.http")
local socket = require("socket")
local httpc = http.new()
httpc:set_timeout(500)
local red = redis.new()
local rdskey = 'serversStatus'
local startms = os.time()
local nowtimestr = nil
local erronnum = nil
local table smsInfo = {}
--定义发短信的函数
function sendmsg(content)
    local res, err = httpc:request_uri("http://10.102.251.242/servletSend", {
        method = 'POST',
        body = 'msgTel=18510512189&msgType=HOME&msgContent=' .. content,
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
        }
    })
    return res, err
end
local repeattimes =0;
repeat
    repeattimes = repeattimes+1;
    erronnum = 0
    nowtimestr = os.date("%Y-%m-%d%H:%M:%S", os.time())
    --统计当前ipurl 数量
    local rest, errt = red:exec(function(red)
        return red:zcard(rdskey)
    end)
    local totalnum = rest
    local runnum = 0;

    local pagestart = 0
    local pageend = rest
    local res, err = red:exec(function(red)
        return red:zrevrange(rdskey, pagestart, pageend, withscores)
    end)
    local httpres, httperr = '';
    for i, url in ipairs(res) do
        local httpres, httperr = httpc:request_uri('' .. url, {
            method = 'GET',
            headers = {
                ["Content-Type"] = "application/json;charset=UTF-8",
            }
        })
        local content = url .. '' .. '当前不能正常访问' .. nowtimestr

        if httpres then
            ngx.log(ngx.ERR, 'http_body is :' .. httpres.body)
            local status = httpres.status
            if status ~= 200 then
                if (smsInfo[url] == nil or smsInfo[url] < 2) then
                    ontent = content .. 'status:' .. status
                    ngx.log(ngx.ERR, content .. '')
                    sendmsg(content)
                    erronnum = erronnum + 1
                    if (smsInfo[url] == nil) then
                        smsInfo[url] = 1
                    else
                        smsInfo[url] = smsInfo[url] + 1;
                    end
                end
            end
        end
        if not httpres then
            if (smsInfo[url] == nil or smsInfo[url] < 2) then
                content = content .. httperr .. ''
                sendmsg(content)
                if (smsInfo[url] == nil) then
                    smsInfo[url] = 1
                else
                    smsInfo[url] = smsInfo[url] + 1;
                end
            end
            --发送微信消息
            --从redis获取发微信url
            local res1 = ngx.location.capture_multi {
                { "/redis_get_set", { args = "key=sendWXMsgtoken" } }
            }
            local lenth = string.len(res1.body)
            local token = string.sub(res1.body, 1, lenth - 1)
            ngx.log(ngx.ERR, 'httpresponse is ERROR url:' .. content)
            local wxurl = 'wget --no-check-certificate https://sc.ftqq.com/' .. token .. '.send?text=' .. content
            ngx.log(ngx.ERR, 'wxurl' .. wxurl)
            local handle = io.popen(wxurl)
            local result = handle:read("*a")
            handle:close()

            erronnum = erronnum + 1
        end

        runnum = runnum + 1
        --暂停50毫秒
        socket.select(nil, nil, 0.05)
    end
    if (erronnum > 0) then
        socket.select(nil, nil, 1)
    end
until erronnum <= 1 or repeattimes>5
local endms = os.time()

ngx.say(nowtimestr .. '  checkservers  totalnum: ' .. runnum .. ' times  errnum: ' .. erronnum .. ' times  used: ' .. endms - startms .. ' ms')
