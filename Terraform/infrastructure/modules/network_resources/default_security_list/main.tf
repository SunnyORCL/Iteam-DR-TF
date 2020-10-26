resource oci_core_default_security_list "default_security_list" {
  manage_default_resource_id = var.resource_id

  dynamic egress_security_rules {
    for_each = [for rule in var.egress_rules : rule if rule.protocol == "all"]
    iterator = rule
    content {
      stateless   = try(rule.value.stateless, false)
      protocol    = local.protocols[rule.value.protocol]
      destination = rule.value.dst
      description = try(rule.value.description, null)
    }
  }

  dynamic egress_security_rules {
    for_each = flatten([for rule in var.egress_rules : [for port in rule.ports : merge(rule, { port : port }) if port == "all"] if rule.protocol == "tcp"])
    iterator = rule
    content {
      stateless   = try(rule.value.stateless, false)
      protocol    = local.protocols[rule.value.protocol]
      destination = rule.value.dst
      description = try(rule.value.description, null)
    }
  }

  dynamic egress_security_rules {
    for_each = flatten([for rule in var.egress_rules : [for port in rule.ports : merge(rule, { port : port }) if port != "all"] if rule.protocol == "tcp"])
    iterator = rule
    content {
      stateless   = try(rule.value.stateless, false)
      protocol    = local.protocols[rule.value.protocol]
      destination = rule.value.dst
      description = try(rule.value.description, null)
      tcp_options {
        min = parseint(split("-", rule.value.port)[0], 10)
        max = parseint(split("-", rule.value.port)[length(split("-", rule.value.port)) - 1], 10)
      }
    }
  }

  dynamic egress_security_rules {
    for_each = flatten([for rule in var.egress_rules : [for port in rule.ports : merge(rule, { port : port }) if port == "all"] if rule.protocol == "udp"])
    iterator = rule
    content {
      stateless   = try(rule.value.stateless, false)
      protocol    = local.protocols[rule.value.protocol]
      destination = rule.value.dst
      description = try(rule.value.description, null)
      udp_options {
        min = split("-", rule.value.port)[0]
        max = split("-", rule.value.port)[length(split("-", rule.value.port)) - 1]
      }
    }
  }

  dynamic egress_security_rules {
    for_each = flatten([for rule in var.egress_rules : [for port in rule.ports : merge(rule, { port : port }) if port != "all"] if rule.protocol == "udp"])
    iterator = rule
    content {
      stateless   = try(rule.value.stateless, false)
      protocol    = local.protocols[rule.value.protocol]
      destination = rule.value.dst
      description = try(rule.value.description, null)
      udp_options {
        min = split("-", rule.value.port)[0]
        max = split("-", rule.value.port)[length(split("-", rule.value.port)) - 1]
      }
    }
  }

  dynamic egress_security_rules {
    for_each = [for rule in var.egress_rules : rule if rule.protocol == "icmp"]
    iterator = rule
    content {
      stateless   = try(rule.value.stateless, false)
      protocol    = local.protocols[rule.value.protocol]
      destination = rule.value.dst
      description = try(rule.value.description, null)
      icmp_options {
        type = try(rule.value.type, null)
        code = try(rule.value.code, null)
      }
    }
  }

  dynamic ingress_security_rules {
    for_each = [for rule in var.ingress_rules : rule if rule.protocol == "all"]
    iterator = rule
    content {
      stateless   = try(rule.value.stateless, false)
      protocol    = local.protocols[rule.value.protocol]
      source      = rule.value.src
      description = try(rule.value.description, null)
    }
  }

  dynamic ingress_security_rules {
    for_each = flatten([for rule in var.ingress_rules : [for port in rule.ports : merge(rule, { port : port }) if port == "all"] if rule.protocol == "tcp"])
    iterator = rule
    content {
      stateless   = try(rule.value.stateless, false)
      protocol    = local.protocols[rule.value.protocol]
      source      = rule.value.src
      description = try(rule.value.description, null)
    }
  }

  dynamic ingress_security_rules {
    for_each = flatten([for rule in var.ingress_rules : [for port in rule.ports : merge(rule, { port : port }) if port != "all"] if rule.protocol == "tcp"])
    iterator = rule
    content {
      stateless   = try(rule.value.stateless, false)
      protocol    = local.protocols[rule.value.protocol]
      source      = rule.value.src
      description = try(rule.value.description, null)
      tcp_options {
        min = split("-", rule.value.port)[0]
        max = split("-", rule.value.port)[length(split("-", rule.value.port)) - 1]
      }
    }
  }

  dynamic ingress_security_rules {
    for_each = flatten([for rule in var.ingress_rules : [for port in rule.ports : merge(rule, { port : port }) if port == "all"] if rule.protocol == "udp"])
    iterator = rule
    content {
      stateless   = try(rule.value.stateless, false)
      protocol    = local.protocols[rule.value.protocol]
      source      = rule.value.src
      description = try(rule.value.description, null)
    }
  }

  dynamic ingress_security_rules {
    for_each = flatten([for rule in var.ingress_rules : [for port in rule.ports : merge(rule, { port : port }) if port != "all"] if rule.protocol == "udp"])
    iterator = rule
    content {
      stateless   = try(rule.value.stateless, false)
      protocol    = local.protocols[rule.value.protocol]
      source      = rule.value.src
      description = try(rule.value.description, null)
      udp_options {
        min = split("-", rule.value.port)[0]
        max = split("-", rule.value.port)[length(split("-", rule.value.port)) - 1]
      }
    }
  }

  dynamic ingress_security_rules {
    for_each = [for rule in var.ingress_rules : rule if rule.protocol == "icmp" && try(rule.type, null) == null]
    iterator = rule
    content {
      stateless   = try(rule.value.stateless, false)
      protocol    = local.protocols[rule.value.protocol]
      source      = rule.value.src
      description = try(rule.value.description, null)
    }
  }

  dynamic ingress_security_rules {
    for_each = [for rule in var.ingress_rules : rule if rule.protocol == "icmp" && try(rule.type, null) != null]
    iterator = rule
    content {
      stateless   = try(rule.value.stateless, false)
      protocol    = local.protocols[rule.value.protocol]
      source      = rule.value.src
      description = try(rule.value.description, null)
      icmp_options {
        type = rule.value.type
        code = rule.value.code
      }
    }
  }
}
