--
-- Created by IntelliJ IDEA.
-- User: lee_xin
-- Date: 17/12/25
-- Time: 上午11:31
-- To change this template use File | Settings | File Templates.
--
local redis = require("resty.rediscli-speedgo")
local json = require("cjson")
local red = redis.new()
local res, err = red:exec(
    function(red)
        return red:keys('*')
    end
)
for key in pairs(json.encode(res)) do
    ngx.log(ngx.ERR,key)
    local res2, err2 = red:exec(
        function(red)
            return red:strlen(key)
        end
    )
    ngx.log(ngx.ERR,json.encode(res2))
end


