# TO DO: MAKE SECURITY LIST DYNAMIC

resource oci_core_vcn standbyVCN {
  cidr_blocks = [
    var.vcn_cidr,
  ]
  compartment_id = var.compartment_ocid
  display_name = var.vcn_display_name
  dns_label    = var.vcn_dns
}

resource oci_core_subnet standbySubnet1 {
  cidr_block     = var.subnet_cidr
  compartment_id = var.compartment_ocid
  dhcp_options_id = oci_core_vcn.standbyVCN.default_dhcp_options_id
  display_name    = var.subnet_display_name
  dns_label       = var.subnet_dns
  freeform_tags = {
  }
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_vcn.standbyVCN.default_route_table_id
  security_list_ids = [
    oci_core_vcn.standbyVCN.default_security_list_id,
    oci_core_security_list.DB-Security-List.id
  ]
  vcn_id = oci_core_vcn.standbyVCN.id
}

resource oci_core_default_dhcp_options default-DHCP-options-for-standbyVCN {
  display_name = "Default DHCP Options for ${var.vcn_display_name}"
  freeform_tags = {
  }
  manage_default_resource_id = oci_core_vcn.standbyVCN.default_dhcp_options_id
  options {
    custom_dns_servers = [
    ]
    server_type = "VcnLocalPlusInternet"
    type        = "DomainNameServer"
  }
  options {
    search_domain_names = [
      "${var.vcn_dns}.oraclevcn.com",
    ]
    type = "SearchDomain"
  }
}


resource oci_core_default_route_table default-route-table-for-standbyVCN {
  display_name = "Default Route Table for ${var.vcn_display_name}"
  freeform_tags = {
  }
  manage_default_resource_id = oci_core_vcn.standbyVCN.default_route_table_id
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.standbyInternetGW.id
  }
  route_rules {
    destination       = var.primary_vcn_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.standby_region_drg.id
  }
}

resource oci_core_default_security_list default-security-list-for-standbyVCN {
  display_name = "Default Security List for ${var.vcn_display_name}"
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol  = "all"
    stateless = "false"
  }
  freeform_tags = {
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "22"
      min = "22"
    }
  }
  ingress_security_rules {
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    icmp_options {
      code = "-1"
      type = "3"
    }
    protocol    = "1"
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  manage_default_resource_id = oci_core_vcn.standbyVCN.default_security_list_id
}

resource oci_core_internet_gateway standbyInternetGW {
  compartment_id = var.compartment_ocid
  display_name = var.internet_gateway_display_name
  enabled      = "true"
  vcn_id = oci_core_vcn.standbyVCN.id
}

# REMOTE PEERING GATEWAY

# # TO DO: DECIDE IF WE NEED TO DO THE DRG PART HERE?
# resource oci_core_drg primary_region_drg {
#   provider = oci.primary_region
#   compartment_id = var.compartment_ocid
#   display_name = var.primary_drg_display_name
# }

# resource oci_core_drg_attachment primary_region_drg_attachment {
#   provider = oci.primary_region
#   drg_id = oci_core_drg.primary_region_drg.id
#   vcn_id = var.primary_vcn_ocid
# }


resource oci_core_drg standby_region_drg {
  compartment_id = var.compartment_ocid
  display_name = var.standby_drg_display_name
}

resource oci_core_drg_attachment standby_region_drg_attachment {
  drg_id = oci_core_drg.standby_region_drg.id
  vcn_id = oci_core_vcn.standbyVCN.id
}

# Create Primary RPC
resource oci_core_remote_peering_connection primary_rpc {
  provider = oci.primary_region
  compartment_id = var.compartment_ocid
  #drg_id = oci_core_drg.primary_region_drg.id
  drg_id = var.primary_drg_ocid
  display_name = var.primary_rpc_display_name
}

# Create Standby RPC and Connect the RPCs
resource oci_core_remote_peering_connection standby_rpc {
  compartment_id = var.compartment_ocid
  drg_id = oci_core_drg.standby_region_drg.id
  display_name = var.standby_rpc_display_name
  
  peer_id = oci_core_remote_peering_connection.primary_rpc.id
  peer_region_name = var.primary_region
}


# DB SPECIFIC NETWORKING

resource oci_core_security_list DB-Security-List {
  compartment_id = var.compartment_ocid
  display_name = var.db_security_list_display_name
  ingress_security_rules {
    description = "For Standby Peering"
    protocol    = "all"
    source      = var.primary_vcn_cidr
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Connecting to DB"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "1521"
      min = "1521"
    }
  }
  vcn_id = oci_core_vcn.standbyVCN.id
}

# LOAD BALANCER SPECIFIC NETWORKING

resource oci_core_security_list LB-security-list {
  compartment_id = var.compartment_ocid
  display_name = var.lb_security_list_display_name
  egress_security_rules {
    destination      = var.subnet_cidr
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
  vcn_id = oci_core_vcn.standbyVCN.id
}

resource oci_core_subnet lbSubnet1 {
  cidr_block     = var.lb_subnet_cidr
  compartment_id = var.compartment_ocid
  dhcp_options_id = oci_core_vcn.standbyVCN.default_dhcp_options_id
  display_name    = var.lb_subnet_display_name
  dns_label       = var.lb_subnet_dns
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_vcn.standbyVCN.default_route_table_id
  security_list_ids = [
    oci_core_security_list.LB-security-list.id,
  ]
  vcn_id = oci_core_vcn.standbyVCN.id
}