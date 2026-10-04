// main.tf
resource "azurerm_application_gateway" "this" {
  for_each = var.application_gateways

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  enable_http2 = each.value.enable_http2
  tags         = each.value.tags

  dynamic "identity" {
    for_each = each.value.identity == null ? [] : [each.value.identity]
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  sku {
    name     = each.value.sku.name
    tier     = each.value.sku.tier
    capacity = each.value.sku.capacity
  }

  gateway_ip_configuration {
    name      = each.value.gateway_ip_configuration.name
    subnet_id = each.value.gateway_ip_configuration.subnet_id
  }

  dynamic "frontend_port" {
    for_each = each.value.frontend_port
    content {
      name = frontend_port.value.name
      port = frontend_port.value.port
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = each.value.frontend_ip_configuration
    content {
      name                          = frontend_ip_configuration.value.name
      subnet_id                     = frontend_ip_configuration.value.subnet_id
      private_ip_address            = frontend_ip_configuration.value.private_ip_address
      private_ip_address_allocation = frontend_ip_configuration.value.private_ip_address_allocation
      public_ip_address_id          = frontend_ip_configuration.value.public_ip_address_id
    }
  }

  dynamic "ssl_certificate" {
    for_each = each.value.ssl_certificate
    content {
      name                = ssl_certificate.value.name
      data                = ssl_certificate.value.data
      password            = ssl_certificate.value.password
      key_vault_secret_id = ssl_certificate.value.key_vault_secret_id
    }
  }

  dynamic "ssl_policy" {
    for_each = each.value.ssl_policy == null ? [] : [each.value.ssl_policy]
    content {
      policy_type          = ssl_policy.value.policy_type
      policy_name          = ssl_policy.value.policy_name
      cipher_suites        = ssl_policy.value.cipher_suites
      min_protocol_version = ssl_policy.value.min_protocol_version
      disabled_protocols   = ssl_policy.value.disabled_protocols
    }
  }

  dynamic "trusted_root_certificate" {
    for_each = each.value.trusted_root_certificate
    content {
      name                = trusted_root_certificate.value.name
      data                = trusted_root_certificate.value.data
      key_vault_secret_id = trusted_root_certificate.value.key_vault_secret_id
    }
  }

  dynamic "backend_address_pool" {
    for_each = each.value.backend_address_pool
    content {
      name         = backend_address_pool.value.name
      fqdns        = backend_address_pool.value.fqdns
      ip_addresses = backend_address_pool.value.ip_addresses
    }
  }

  dynamic "backend_http_settings" {
    for_each = each.value.backend_http_settings
    content {
      name                                = backend_http_settings.value.name
      cookie_based_affinity               = backend_http_settings.value.cookie_based_affinity
      port                                = backend_http_settings.value.port
      protocol                            = backend_http_settings.value.protocol
      request_timeout                     = backend_http_settings.value.request_timeout
      host_name                           = backend_http_settings.value.host_name
      pick_host_name_from_backend_address = backend_http_settings.value.pick_host_name_from_backend_address
      probe_name                          = backend_http_settings.value.probe_name
      path                                = backend_http_settings.value.path
      affinity_cookie_name                = backend_http_settings.value.affinity_cookie_name
      trusted_root_certificate_names      = backend_http_settings.value.trusted_root_certificate_names

      dynamic "connection_draining" {
        for_each = backend_http_settings.value.connection_draining == null ? [] : [backend_http_settings.value.connection_draining]
        content {
          enabled           = connection_draining.value.enabled
          drain_timeout_sec = connection_draining.value.drain_timeout_sec
        }
      }
    }
  }

  dynamic "probe" {
    for_each = each.value.probe
    content {
      name                                      = probe.value.name
      protocol                                  = probe.value.protocol
      path                                      = probe.value.path
      host                                      = probe.value.host
      interval                                  = probe.value.interval
      timeout                                   = probe.value.timeout
      unhealthy_threshold                       = probe.value.unhealthy_threshold
      port                                      = probe.value.port
      pick_host_name_from_backend_http_settings = probe.value.pick_host_name_from_backend_http_settings
      minimum_servers                           = probe.value.minimum_servers

      dynamic "match" {
        for_each = probe.value.match == null ? [] : [probe.value.match]
        content {
          status_code = match.value.status_code
          body        = match.value.body
        }
      }
    }
  }

  dynamic "http_listener" {
    for_each = each.value.http_listener
    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = http_listener.value.frontend_ip_configuration_name
      frontend_port_name             = http_listener.value.frontend_port_name
      protocol                       = http_listener.value.protocol
      host_name                      = http_listener.value.host_name
      host_names                     = http_listener.value.host_names
      require_sni                    = http_listener.value.require_sni
      ssl_certificate_name           = http_listener.value.ssl_certificate_name
      firewall_policy_id             = http_listener.value.firewall_policy_id
    }
  }

  dynamic "request_routing_rule" {
    for_each = each.value.request_routing_rule
    content {
      name                       = request_routing_rule.value.name
      rule_type                  = request_routing_rule.value.rule_type
      http_listener_name         = request_routing_rule.value.http_listener_name
      backend_address_pool_name  = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name = request_routing_rule.value.backend_http_settings_name
      priority                   = request_routing_rule.value.priority
      url_path_map_name          = request_routing_rule.value.url_path_map_name
      redirect_configuration_name = request_routing_rule.value.redirect_configuration_name
      rewrite_rule_set_name      = request_routing_rule.value.rewrite_rule_set_name
    }
  }

  dynamic "redirect_configuration" {
    for_each = each.value.redirect_configuration
    content {
      name                 = redirect_configuration.value.name
      redirect_type        = redirect_configuration.value.redirect_type
      target_listener_name = redirect_configuration.value.target_listener_name
      target_url           = redirect_configuration.value.target_url
      include_path         = redirect_configuration.value.include_path
      include_query_string = redirect_configuration.value.include_query_string
    }
  }

  dynamic "url_path_map" {
    for_each = each.value.url_path_map
    content {
      name                               = url_path_map.value.name
      default_backend_address_pool_name  = url_path_map.value.default_backend_address_pool_name
      default_backend_http_settings_name = url_path_map.value.default_backend_http_settings_name
      default_redirect_configuration_name = url_path_map.value.default_redirect_configuration_name
      default_rewrite_rule_set_name      = url_path_map.value.default_rewrite_rule_set_name

      dynamic "path_rule" {
        for_each = url_path_map.value.path_rule
        content {
          name                       = path_rule.value.name
          paths                      = path_rule.value.paths
          backend_address_pool_name  = path_rule.value.backend_address_pool_name
          backend_http_settings_name = path_rule.value.backend_http_settings_name
          redirect_configuration_name = path_rule.value.redirect_configuration_name
          rewrite_rule_set_name      = path_rule.value.rewrite_rule_set_name
        }
      }
    }
  }

  dynamic "rewrite_rule_set" {
    for_each = each.value.rewrite_rule_set
    content {
      name = rewrite_rule_set.value.name

      dynamic "rewrite_rule" {
        for_each = rewrite_rule_set.value.rewrite_rule
        content {
          name          = rewrite_rule.value.name
          rule_sequence = rewrite_rule.value.rule_sequence

          dynamic "condition" {
            for_each = rewrite_rule.value.condition
            content {
              variable    = condition.value.variable
              pattern     = condition.value.pattern
              ignore_case = condition.value.ignore_case
              negate      = condition.value.negate
            }
          }

          dynamic "request_header_configuration" {
            for_each = rewrite_rule.value.request_header_configuration
            content {
              header_name  = request_header_configuration.value.header_name
              header_value = request_header_configuration.value.header_value
            }
          }

          dynamic "response_header_configuration" {
            for_each = rewrite_rule.value.response_header_configuration
            content {
              header_name  = response_header_configuration.value.header_name
              header_value = response_header_configuration.value.header_value
            }
          }

          dynamic "url" {
            for_each = rewrite_rule.value.url == null ? [] : [rewrite_rule.value.url]
            content {
              path         = url.value.path
              query_string = url.value.query_string
              reroute      = url.value.reroute
            }
          }
        }
      }
    }
  }

  dynamic "waf_configuration" {
    for_each = each.value.waf_configuration == null ? [] : [each.value.waf_configuration]
    content {
      enabled          = waf_configuration.value.enabled
      firewall_mode    = waf_configuration.value.firewall_mode
      rule_set_type    = waf_configuration.value.rule_set_type
      rule_set_version = waf_configuration.value.rule_set_version

      file_upload_limit_mb     = waf_configuration.value.file_upload_limit_mb
      request_body_check       = waf_configuration.value.request_body_check
      max_request_body_size_kb = waf_configuration.value.max_request_body_size_kb

      dynamic "disabled_rule_group" {
        for_each = waf_configuration.value.disabled_rule_group
        content {
          rule_group_name = disabled_rule_group.value.rule_group_name
          rules           = disabled_rule_group.value.rules
        }
      }

      dynamic "exclusion" {
        for_each = waf_configuration.value.exclusion
        content {
          match_variable          = exclusion.value.match_variable
          selector_match_operator = exclusion.value.selector_match_operator
          selector                = exclusion.value.selector
        }
      }
    }
  }

  lifecycle {
    precondition {
      condition     = each.value.sku.tier == "WAF_v2" || each.value.sku.tier == "WAF"
      error_message = "To enable WAF, sku.tier must be 'WAF_v2' (recommended) or 'WAF'."
    }
    precondition {
      condition     = each.value.waf_configuration != null && each.value.waf_configuration.enabled == true
      error_message = "waf_configuration.enabled must be true to create an Application Gateway with WAF enabled."
    }
  }
}
// outputs.tf
output "application_gateway_ids" {
  description = "Application Gateway resource IDs keyed by input map key."
  value       = { for k, v in azurerm_application_gateway.this : k => v.id }
}

output "application_gateway_names" {
  description = "Application Gateway names keyed by input map key."
  value       = { for k, v in azurerm_application_gateway.this : k => v.name }
}

output "application_gateway_frontend_ip_configuration_private_ips" {
  description = "Private IPs for frontend IP configurations (if any), keyed by AppGW key."
  value = {
    for k, v in azurerm_application_gateway.this :
    k => [for f in v.frontend_ip_configuration : f.private_ip_address]
  }
}

module "appgw" {
  source = "./modules/appgw-waf"

  application_gateways = {
    gw1 = {
      name                = "appgw-waf-01"
      resource_group_name = azurerm_resource_group.rg.name
      location            = azurerm_resource_group.rg.location
      tags = { env = "dev" }

      sku = {
        name     = "WAF_v2"
        tier     = "WAF_v2"
        capacity = 2
      }

      gateway_ip_configuration = {
        name      = "gwipcfg"
        subnet_id = azurerm_subnet.appgw.id
      }

      frontend_port = {
        https = { name = "feport-443", port = 443 }
      }

      frontend_ip_configuration = {
        public = {
          name                 = "feip-public"
          public_ip_address_id = azurerm_public_ip.appgw.id
        }
      }

      ssl_certificate = {
        cert1 = {
          name                = "listener-cert"
          key_vault_secret_id = azurerm_key_vault_certificate.appgw.secret_id
        }
      }

      backend_address_pool = {
        pool1 = {
          name         = "be-pool"
          ip_addresses = ["10.10.1.4"]
        }
      }

      backend_http_settings = {
        bhs1 = {
          name     = "bhs-https"
          port     = 443
          protocol = "Https"
          request_timeout = 30
        }
      }

      http_listener = {
        lis1 = {
          name                           = "https-listener"
          frontend_ip_configuration_name = "feip-public"
          frontend_port_name             = "feport-443"
          protocol                       = "Https"
          ssl_certificate_name           = "listener-cert"
        }
      }

      request_routing_rule = {
        r1 = {
          name                       = "rule-basic"
          rule_type                  = "Basic"
          http_listener_name         = "https-listener"
          backend_address_pool_name  = "be-pool"
          backend_http_settings_name = "bhs-https"
          priority                   = 10
        }
      }

      waf_configuration = {
        enabled          = true
        firewall_mode    = "Prevention"
        rule_set_type    = "OWASP"
        rule_set_version = "3.2"
      }
    }
  }
}


