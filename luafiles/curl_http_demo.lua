--
-- Created by IntelliJ IDEA.
-- User: lee_xin
-- Date: 17/12/15
-- Time: 下午4:29
-- To change this template use File | Settings | File Templates.
--

curl = require("luacurl")

function get_html(url, c)
    local result = { }
    if c == nil then
        c = curl.new()
    end
    c:setopt(curl.OPT_URL, url)
    c:setopt(curl.OPT_WRITEDATA, result)
    c:setopt(curl.OPT_WRITEFUNCTION, function(tab, buffer)     --call back函数，必须有
        table.insert(tab, buffer)                      --tab参数即为result，参考http://luacurl.luaforge.net/

        return #buffer
    end)
    local ok = c:perform()
    return ok, table.concat(result)             --此table非上一个table，作用域不同
end

ok, html = get_html("http://www.baidu.com/")
if ok then
    ngx.say(html)

else

    ngx.say("Error" )
end