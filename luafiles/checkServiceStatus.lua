--
-- Created by IntelliJ IDEA.
-- User: lee_xin
-- Date: 17/12/27
-- Time: 下午4:19
-- 检测所有服务的tomcat是否正常
-- 从redis 服务的访问地址 ，然后就行wget ，如果能正常访问即为正常，否则发短信
--将监控的url添入到有序队列
-- -- curl url/redis_zadd  -d 'key=serversStatus&value=127.0.0.1/status&score=100'
--设置短信 微信的发送开关 0 代表关 1 代表开 curl url/redis_get_set -d 'key=smsSwitch&value=1'
-- curl url/redis_get_set -d 'key=WXSwitch&value=1'

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
local runnum = nil
local table smsInfo = {}
--定义从redis 获取指定key的值
function getRedisValue(rdskey)

    local res, err = ngx.location.capture('/redis_get_set',
        { args = { key = '' .. rdskey } })
    return res, err
end

--定义发短信的函数
function sendmsg(content)
    local resswitch, errswitch = getRedisValue('smsSwitch')
    if resswitch['body'] == '0' then
        return nil
    end
    local res, err = httpc:request_uri("http://10.102.251.242/servletSend", {
        method = 'POST',
        body = 'msgTel=18510512189&msgType=HOME&msgContent=' .. content,
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
        }
    })
    return res, err
end

--定义发微信信的函数
function sendwxmsg(content)
    local resswitch, errswitch = getRedisValue('WXSwitch')

    if resswitch['body'] == '0' then
        return nil
    end
    local res1, err1 = getRedisValue('sendWXMsgtoken')
    local token = res1.body .. ''
    local wxurl = 'wget --no-check-certificate https://sc.ftqq.com/' .. token .. '.send?text=' .. content
    --ngx.log(ngx.ERR, 'wxurl' .. wxurl)
    local handle = io.popen(wxurl)
    local result = handle:read("*a")
    handle:close()
    return result
end

local repeattimes = 0;
repeat
    repeattimes = repeattimes + 1;
    erronnum = 0
    runnum = 0
    nowtimestr = os.date("%Y-%m-%d%H:%M:%S", os.time())
    --统计当前ipurl 数量
    local rest, errt = red:exec(function(red)
        return red:zcard(rdskey)
    end)
    local totalnum = rest


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
        local content = '报警' .. url .. '' .. '当前不能正常访问' .. nowtimestr
--        if(httpres) then
--        local rpsbody =httpres.body..''
            --string.find(rpsbody,'startTime:2018-01-1',1,true) 1,从下标1开始，true代表不使用匹配符
--        local  matchres = string.find(rpsbody,'startTime:2018-01-1',1,true)
--        if(matchres == nil)then
--            ngx.log(ngx.ERR,'nott.'..rpsbody)
--            httpres.status=500
--        end
--        end
        if httpres then
            local status = httpres.status
            if status ~= 200 then
                erronnum = erronnum + 1
                if (smsInfo[url] == nil) then
                    smsInfo[url] = 1
                else
                    smsInfo[url] = smsInfo[url] + 1
                    content = '重要'..content
                end
                ontent = content .. 'status:' .. status.. '当前失败次数：'..smsInfo[url]
                if (smsInfo[url] ~= nil and  smsInfo[url] > 2 and smsInfo[url] < 4) then

                    ngx.log(ngx.ERR, 'status is error : ' .. status .. '消息内容: ' .. content .. 'http返回值: ' .. httpres.body)

                    sendmsg(content)
                end
                sendwxmsg(content)
            end
        end
        if not httpres then
            if (smsInfo[url] == nil) then
                smsInfo[url] = 1
            else
                smsInfo[url] = smsInfo[url] + 1
                content = '重要' .. content
            end
            content = content .. httperr .. '当前失败次数：'..smsInfo[url]
            ngx.log(ngx.ERR, '请求失败：' .. content)
            if (smsInfo[url] ~= nil and  smsInfo[url] > 1  and smsInfo[url] < 4) then


                sendmsg(content)
            end
            --发送微信消息
            --从redis获取发微信url
            ngx.log(ngx.ERR, 'httpresponse is ERROR url:' .. content)
            sendwxmsg(content)

            erronnum = erronnum + 1
        end

        runnum = runnum + 1
        --暂停50毫秒
        socket.select(nil, nil, 0.05)
    end
    if (erronnum > 0) then
        socket.select(nil, nil, 1)
    end
until erronnum < 1 or repeattimes > 4
local endms = os.time()

ngx.say(nowtimestr .. '  checkservers  totalnum: ' .. runnum .. ' times  errnum: ' .. erronnum .. ' times  used: ' .. endms - startms .. ' ms')
