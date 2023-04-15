local typedefs = require "kong.db.schema.typedefs"

local PLUGIN_NAME = "jwt-claim-headers"

return {
    name = PLUGIN_NAME.
    fields = {{
        consumer = typedefs.no_consumer
    }, {
        protocols = typedefs.protocols_http
    }, {
        config = {
            type = "record",
            fields = {
                {
                    uri_param_names = {
                        type = "set",
                        elements = {
                            type = "string"
                        },
                        default = {"jwt"}
                    }
                }, {
                    cookie_names = {
                        type = "set",
                        elements = {
                            type = "string"
                        },
                        default = {"BEARER"}
                    }
                }, {
                    check_uri = {
                        type = "boolean",
                        default = true,
                    },
                }, {
                    check_header = {
                        type = "boolean",
                        default = true,
                    },
                }, {
                    check_cookie = {
                        type = "boolean",
                        default = true,
                    },
                }
            }
        }
    }},
}
