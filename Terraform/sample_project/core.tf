/* Sample script for networking. 
    Values used: Standby VCN has CIDR 10.1.0.0/16, Primary VCN has CIDR 10.0.0.0/16.
    Additional steps: Will have to create primary region's route in route table to DRG from OCI Console after script has been run. 
*/


# BASIC NETWORKING

resource oci_core_internet_gateway StandbyInternetGW {
  compartment_id = var.compartment_ocid
  display_name = "StandbyInternetGW"
  enabled      = "true"
  freeform_tags = {
  }
  vcn_id = oci_core_vcn.standbydr1.id
}

resource oci_core_subnet standbysubnet1 {
  cidr_block     = "10.1.0.0/24"
  compartment_id = var.compartment_ocid
  dhcp_options_id = oci_core_vcn.standbydr1.default_dhcp_options_id
  display_name    = "standbysubnet1"
  dns_label       = "standbysubnet1"
  freeform_tags = {
  }
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_vcn.standbydr1.default_route_table_id
  security_list_ids = [
    oci_core_vcn.standbydr1.default_security_list_id,
    oci_core_security_list.DB-Security-List.id,
  ]
  vcn_id = oci_core_vcn.standbydr1.id
}

resource oci_core_vcn standbydr1 {
  cidr_blocks = [
    "10.1.0.0/16",
  ]
  compartment_id = var.compartment_ocid
  display_name = "standbydr1"
  dns_label    = "standbydr1"
}

resource oci_core_default_dhcp_options Default-DHCP-Options-for-standbydr1 {
  display_name = "Default DHCP Options for standbydr1"
  freeform_tags = {
  }
  manage_default_resource_id = oci_core_vcn.standbydr1.default_dhcp_options_id
  options {
    custom_dns_servers = [
    ]
    server_type = "VcnLocalPlusInternet"
    type        = "DomainNameServer"
  }
  options {
    search_domain_names = [
      "standbydr1.oraclevcn.com",
    ]
    type = "SearchDomain"
  }
}

resource oci_core_default_route_table Default-Route-Table-for-standbydr1 {
  display_name = "Default Route Table for standbydr1"
  freeform_tags = {
  }
  manage_default_resource_id = oci_core_vcn.standbydr1.default_route_table_id
  route_rules {
    #description = <<Optional value not found in discovery>>
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.StandbyInternetGW.id
  }
  route_rules {
    destination       = "10.0.0.0/16"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.standby_region_drg.id
  }
}

resource oci_core_default_security_list Default-Security-List-for-standbydr1 {
  display_name = "Default Security List for standbydr1"
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol  = "all"
    stateless = "false"
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
    source      = "10.1.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  manage_default_resource_id = oci_core_vcn.standbydr1.default_security_list_id
}

# DB SECURITY LIST
resource oci_core_security_list DB-Security-List {
  compartment_id = var.compartment_ocid
  display_name = "DB Security List"
  ingress_security_rules {
    description = "For Standby Peering"
    protocol    = "all"
    source      = "10.0.0.0/16"
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
  vcn_id = oci_core_vcn.standbydr1.id
}

# REMOTE PEERING GATEWAY

resource oci_core_drg primary_region_drg {
  provider = oci.sanjose
  compartment_id = var.compartment_ocid
  display_name = "PrimaryRegionDRG"
}

resource oci_core_drg_attachment primary_region_drg_attachment {
  provider = oci.sanjose
  drg_id = oci_core_drg.primary_region_drg.id
  vcn_id = "ocid1.vcn.oc1.us-sanjose-1.amaaaaaantxkdlyaze57vxthzjolubkdcu2tslaukdtp3z5emqmsk57dsi7a"
}

resource oci_core_drg standby_region_drg {
  compartment_id = var.compartment_ocid
  display_name = "StandbyRegionDRG"
}

resource oci_core_drg_attachment standby_region_drg_attachment {
  drg_id = oci_core_drg.standby_region_drg.id
  vcn_id = oci_core_vcn.standbydr1.id
}

# Create Primary RPC
resource oci_core_remote_peering_connection primary_rpc {
  provider = oci.sanjose
  compartment_id = var.compartment_ocid
  drg_id = oci_core_drg.primary_region_drg.id
  display_name = "primary rpc"  #Optional
}

# Create Standby RPC and Connect the RPCs
resource oci_core_remote_peering_connection standby_rpc {
  compartment_id = var.compartment_ocid
  drg_id = oci_core_drg.standby_region_drg.id
  display_name = "standbyrpc" #Optional
  
  peer_id = oci_core_remote_peering_connection.primary_rpc.id
  peer_region_name = var.primary_region
}