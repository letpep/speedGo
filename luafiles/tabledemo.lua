--
-- Created by IntelliJ IDEA.
-- User: lee_xin
-- Date: 17/10/28
-- Time: 下午5:39
-- To change this template use File | Settings | File Templates.
--
    local json = require("cjson")
  local  tablea = {key1="value1",key2=3 }
    local jsonstr = json.encode(tablea)
    ngx.say(jsonstr)
