--
-- Created by IntelliJ IDEA.
-- User: lee_xin
-- Date: 17/12/25
-- Time: 上午11:31
-- 检测string型redis key的value值 长度
--
local redis = require("resty.rediscli-speedgo")
local json = require("cjson")
local red = redis.new()
local res, err = red:exec(
    function(red)
        return red:keys('*')
    end
)
for key,value in pairs(res) do
    ngx.log(ngx.ERR,'key:'..value)
    local res2, err2 = red:exec(
        function(red)
            return red:strlen(''..value)
        end
    )
    ngx.log(ngx.ERR,json.encode('key:'..value..'---size:'..res2))
end


