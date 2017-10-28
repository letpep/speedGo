--
-- Created by IntelliJ IDEA.
-- User: lee_xin
-- Date: 17/10/28
-- Time: 下午1:27
-- To change this template use File | Settings | File Templates.
--
local res1,res2 = ngx.location.capture_multi{
    {"/redis_get_set", {args="key=lixin"}},
    {"/orderservice-orderSuccess"}
}

ngx.header.content_type="text/plain"
ngx.say(res1.body)
ngx.say(res2.body)

ngx.say(res2.status)
ngx.say(res2.header["Set-Cookie"])
