local plugin_name = "jwt-claim-headers"
local package_name = "kong-plugin-" .. plugin_name
local package_version = "3.0.0"
local rockspec_revision = "4"

local github_account_name = "polkan-msk"
local github_repo_name = "jwt-claim-headers"
local git_checkout = package_version == "dev" and "master" or package_version


package = package_name
version = package_version .. "-" .. rockspec_revision

source = {
  url = "git+https://github.com/"..github_account_name.."/"..github_repo_name..".git",
  branch = git_checkout,
}

description = {
  summary = "A Kong plugin to map JWT claims to request headers ",
  license = "MIT",
  homepage = "https://github.com/polkan-msk/jwt-claim-headers"
}
dependencies = {
  --"lua ~> 5.1",
  --"kong >= 3.0.0"
}
build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..plugin_name..".handler"] = "kong/plugins/"..plugin_name.."/handler.lua",
    ["kong.plugins."..plugin_name..".schema"] = "kong/plugins/"..plugin_name.."/schema.lua",      
    ["kong.plugins."..plugin_name..".claim_headers"] = "kong/plugins/"..plugin_name.."/claim_headers.lua",      
  }
}
