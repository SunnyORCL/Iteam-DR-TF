
resource oci_load_balancer_load_balancer standby_lb {
  compartment_id = var.compartment_ocid
  display_name = var.load_balancer_display_name
  shape = "flexible"
  shape_details {
    maximum_bandwidth_in_mbps = "10"
    minimum_bandwidth_in_mbps = "10"
  }
  subnet_ids = [
    oci_core_subnet.lbSubnet1.id,
  ]
  ip_mode    = "IPV4"
  is_private = "false"
}

resource oci_load_balancer_backend_set backend_set_1 {
  health_checker {
    interval_ms         = "10000"
    port                = "22"
    protocol            = "TCP"
    response_body_regex = ""
    retries             = "3"
    return_code         = "200"
    timeout_in_millis   = "3000"
    url_path            = "/"
  }
  load_balancer_id = oci_load_balancer_load_balancer.standby_lb.id
  name             = "backend_set_1"
  policy           = "ROUND_ROBIN"
}

resource oci_load_balancer_listener lb-listener-1 {
  connection_configuration {
    backend_tcp_proxy_protocol_version = "0"
    idle_timeout_in_seconds            = "60"
  }
  default_backend_set_name = oci_load_balancer_backend_set.backend_set_1.name
  load_balancer_id = oci_load_balancer_load_balancer.standby_lb.id
  name             = "lb-listener-1"
  port     = "80"
  protocol = "HTTP"
}

resource oci_load_balancer_backend backend {
  backendset_name  = oci_load_balancer_backend_set.backend_set_1.name
  backup           = "false"
  drain            = "false"
  ip_address       = oci_core_instance.compute_1.private_ip
  load_balancer_id = oci_load_balancer_load_balancer.standby_lb.id
  offline          = "false"
  port             = "80"
  weight           = "1"
}


