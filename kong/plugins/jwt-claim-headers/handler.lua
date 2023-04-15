local jwt_decoder = require "kong.plugins.jwt.jwt_parser"
local luna = require 'lunajson'
local JWT_PLUGIN_PRIORITY = (require "kong.plugins.jwt.handler").PRIORITY

local kong = kong
local ngx_re_gmatch = ngx.re.gmatch

local JwtClaimHeadersHandler = {
  VERSION = "3.0.0",
  PRIORITY = JWT_PLUGIN_PRIORITY - 100,
}

local function is_table(t) return type(t) == 'table' end

local function in_table (value, table)
  for _, v in ipairs(table) do
    if v == value then
      return true
    end
  end
  return false
end

local function retrieve_token(conf)
  local uri_parameters = kong.request.get_query()

  if (conf.check_uri) then
    for _, v in ipairs(conf.uri_param_names) do
      if uri_parameters[v] then
        return uri_parameters[v]
      end
    end
  end

  if (conf.check_header) then
    local authorization_header = kong.request.get_headers()["authorization"]
    if authorization_header then
      local iterator, iter_err = ngx_re_gmatch(authorization_header, "\\s*[Bb]earer\\s+(.+)")
      if not iterator then
        return nil, iter_err
      end

      local m, err = iterator()
      if err then
        return nil, err
      end

      if m and #m > 0 then
        return m[1]
      end
    end
  end

  if (conf.check_cookie) then
    for _, v in ipairs(conf.cookie_names) do
      local cookie_header = kong.request.get_headers()["cookie"]
      if cookie_header then
        local iterator, iter_err = ngx_re_gmatch(cookie_header, ".*?" .. v .. "=([^;\\s]+)")
        if not iterator then
          return nil, iter_err
        end

        local m, err = iterator()
        if err then
          return nil, err
        end

        if m and #m > 0 then
          return m[1]
        end
      end
    end
  end
end

function JwtClaimHeadersHandler:access(conf)
  local token, err = retrieve_token(conf)
  if err then
    kong.log.warn("unable to retrieve token: ", err)
    return
  end

  local token_type = type(token)
  if token_type ~= "string" then
    if token_type == "nil" then
      kong.log.warn("missing token")
      return
    else
      kong.log.err("unrecognizable token")
      return
    end
  end

  local jwt, err = jwt_decoder:new(token)
  if err then
    kong.log.err("bad token: ", err)
    return
  end

  local claims = jwt.claims

  if (conf.pass_whole_payload) then
    local request_header = conf.header_prefix .. '-payload'
    kong.service.request.set_header(request_header, luna.encode( claims ))
  end

  for claim_key, claim_value in pairs(claims) do
    if (in_table(claim_key, conf.pass_fields)) then
      local request_header = conf.header_prefix .. '-' .. claim_key
      if (is_table(claim_value)) then
        claim_value = luna.encode(claim_value)
      end
      kong.service.request.set_header(request_header, claim_value)
    end
  end
end

return JwtClaimHeadersHandler
