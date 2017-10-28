--
-- Created by IntelliJ IDEA.
-- User: lee_xin
-- Date: 17/10/28
-- Time: 下午1:53
-- To change this template use File | Settings | File Templates.
--
local resty_lock = require "resty.lock"
local cache = ngx.shared.my_cache
local json = require("cjson")
local key =nil
args  = ngx.req.get_uri_args()
for akey,val in pairs(args) do
    if "key" == akey  then
        key = val
    end
end
ngx.log(ngx.ERR,"key:",key)

-- step 1:
local val, err = cache:get(key)
if val then
    ngx.say("result: ", val)
    return
end

if err then
    return fail("failed to get key from shm: ", err)
end

-- cache miss!
-- step 2:
local lock, err = resty_lock:new("my_locks")
if not lock then
    return fail("failed to create lock: ", err)
end

local elapsed, err = lock:lock(key)
if not elapsed then
    return fail("failed to acquire the lock: ", err)
end

-- lock successfully acquired!

-- step 3:
-- someone might have already put the value into the cache
-- so we check it here again:
val, err = cache:get(key)
if val then
    local ok, err = lock:unlock()
    if not ok then
        return fail("failed to unlock: ", err)
    end

    ngx.say("result: ", val)
    return
end

--- step 4:
local val = ngx.location.capture("/redis_get_set", {
    method = ngx.HTTP_GET,
    args = {key = key}

})

if not val then
    local ok, err = lock:unlock()
    if not ok then
        return fail("failed to unlock: ", err)
    end

    -- FIXME: we should handle the backend miss more carefully
    -- here, like inserting a stub value into the cache.

    ngx.say("no value found")
    return
end

-- update the shm cache with the newly fetched value
ngx.log(ngx.ERR,"key-value:",key.."-"..json.encode(val))
local ok, err = cache:set(key, val, 1)
if not ok then
    local ok, err = lock:unlock()
    if not ok then
        return fail("failed to unlock: ", err)
    end

    return fail("failed to update shm cache: ", err)
end

local ok, err = lock:unlock()
if not ok then
    return fail("failed to unlock: ", err)
end

ngx.say("result: ", val)

