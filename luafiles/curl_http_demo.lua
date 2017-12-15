--
-- Created by IntelliJ IDEA.
-- User: lee_xin
-- Date: 17/12/15
-- Time: 下午4:29
-- To change this template use File | Settings | File Templates.
--

local handle =io.popen("curl http://baidu.com")
local result = handle:read("*a")
handle:close()
ngx.say(result)