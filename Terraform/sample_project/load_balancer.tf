/* Sample script for load balancer. This script uses Protocol TCP on port 22 for Health Checks. 
    Assumes (1) that port 22 should already be open with default security list set up and
    (2) route table already configured with internet gateway. 
*/ 

resource oci_core_security_list LB-Security-List {
  compartment_id = var.compartment_ocid
  display_name = "LB Security List"
  egress_security_rules {
    destination      = "10.1.0.0/24"
    destination_type = "CIDR_BLOCK"
    protocol  = "6"
    stateless = "false"
    tcp_options {
      max = "22"
      min = "22"
    }
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "80"
      min = "80"
    }
  }
  vcn_id = oci_core_vcn.standbydr1.id
}


resource oci_core_subnet lbSubnet1 {
  cidr_block     = "10.1.1.0/24"
  compartment_id = var.compartment_ocid
  dhcp_options_id = oci_core_vcn.standbydr1.default_dhcp_options_id
  display_name    = "lbSubnet1"
  dns_label       = "lbSubnet1"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_vcn.standbydr1.default_route_table_id
  security_list_ids = [
    oci_core_security_list.LB-Security-List.id,
  ]
  vcn_id = oci_core_vcn.standbydr1.id
}


resource oci_load_balancer_load_balancer dr-lb-tf {
  compartment_id = var.compartment_ocid
  display_name = "dr-lb-tf"
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

resource oci_load_balancer_backend_set bs_lb_1 {
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
  load_balancer_id = oci_load_balancer_load_balancer.dr-lb-tf.id
  name             = "bs_lb_1"
  policy           = "ROUND_ROBIN"
}

resource oci_load_balancer_listener lb-listener-1 {
  connection_configuration {
    backend_tcp_proxy_protocol_version = "0"
    idle_timeout_in_seconds            = "60"
  }
  default_backend_set_name = oci_load_balancer_backend_set.bs_lb_1.name
  load_balancer_id = oci_load_balancer_load_balancer.dr-lb-tf.id
  name             = "lb-listener-1"
  port     = "80"
  protocol = "HTTP"
}

resource oci_load_balancer_backend backend1 {
  backendset_name  = oci_load_balancer_backend_set.bs_lb_1.name
  backup           = "false"
  drain            = "false"
  #ip_address       = oci_core_instance.<INSTANCE RESOURCE NAME>.private_ip
  ip_address       = "10.1.0.4"
  load_balancer_id = oci_load_balancer_load_balancer.dr-lb-tf.id
  offline          = "false"
  port             = "22"
  weight           = "1"
}

