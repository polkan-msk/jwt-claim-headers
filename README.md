# kong-jwt-claim-headers

Add unencrypted, base64-decoded claims from a JWT payload as request headers to
the upstream service.

## Installation

```bash
luarocks install https://github.com/polkan-msk/jwt-claim-headers/releases/download/v3.0.0/kong-plugin-jwt-claim-headers-3.0.0-24.all.rock
```

## How it works

When enabled, this plugin will add new headers to requests based on the claims
in the JWT provided in the request. It can pass each desired value of the JWT's
payload as a separate header or\and pass the whole payload within one header.

Plugin can get the JWT from uri, header or cookie.


For example, if the JWT payload object is

```json
{
  "uid" : "123456",
  "sub" : "johndoe@gmail.com",
  "aud" : "affiliate",
  "aid" : "323232",
  "pid" : "987654"
}
```

and configuratuin sets the following claims to be passed

```yaml
pass_fields:
  - uid
  - sub
  - aud
```

then the following headers would be added.

```
x-consumer-token-uid : "123456"
x-consumer-token-sub : "johndoe@gmail.com"
x-consumer-token-aud : "affiliate"
```
The prefix `x-consumer-token` is configurable.

## Configuration

Similar to the built-in JWT Kong plugin, you can associate the jwt-claim-headers
plugin with an API with the following request:

```bash
curl -X POST http://localhost:8001/apis/29414666-6b91-430a-9ff0-50d691b03a45/plugins \
  --data "name=jwt-claim-headers" \
  --data "config.uri_param_names=jwt"
```
db-less config:
```yaml
plugins:
  - name: jwt-claim-headers
    service: <service name>
    config:
      check_uri: true
      check_header: true
      check_cookie: true
      uri_param_names:
        - jwt
      cookie_names:
        - BEARER
      pass_whole_payload: true
      pass_fields:
        - userid
        - email
        - roles
      header_prefix: x-jwt-header
```

form parameter|required|description
---|---|---
`name`|*required*|The name of the plugin to use, in this case: `jwt-claim-headers`
`check_uri`|*optional*|The boolean option that defines if the plugin should try to get JWT from URI. Defaults to `true`.
`check_header`|*optional*|The boolean option that defines if the plugin should try to get JWT from Header. Defaults to `true`.
`check_cookie`|*optional*|The boolean option that defines if the plugin should try to get JWT from Cookie. Defaults to `true`.
`uri_param_names`|*optional*|A list of querystring parameters that Kong will inspect to retrieve JWTs. Defaults to `jwt`.
`cookie_names`|*optional*|A list of cookies that Kong will inspect to retrieve JWTs. Defaults to `BEARER`.
`pass_whole_payload`|*optional*|The boolean option that defines if the plugin should pass the whole payload section of JWT in one header. Defaults to `false`.
`pass_fields`|*optional*|An array of JWT claims that should be passed to upstream as a separate headers. Defaults to `uid`.
`header_prefix`|*optional*|The prefix to build Header names as {header_prefix}-{claim}. Defaults to `x-consumer-token`.

## How to build new version

- make required changes in plugin's code
- update VERSION in a handler.lua file
- update package_version and rockspec_revision in a .rockspec file
- rename the .rockspec file to match the versions you've just set
- install the package locally
```bash
luarocks make --local
```
- build the .rock file
```bash
luarocks pack kong-plugin-jwt-claim-headers <package_version>-<rockspec_revision>
```
- release the new version via GitHub

## Acknowledgements

Inspired by [kong-plugin-jwt-claims-headers](https://github.com/wshirey/kong-plugin-jwt-claims-headers), thanks **wshirey**!

Thanks [emaincourt](https://github.com/emaincourt/kong-jwt-claim-headers) for the Kong3 compatibility changes!
