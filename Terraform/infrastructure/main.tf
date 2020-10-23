provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid = var.user_ocid
  fingerprint = var.fingerprint
  private_key_path = var.private_key_path
  region = var.region
}

module root_compartment {
  source = "./modules/compartments"
  compartment_id = var.starting_parent_compartment
  compartment_name = "MarkSmith"
  compartment_description = "MarkSmith"
}

module main_vcn {
  source = "./modules/vcns"
  vcn_cidr = "10.0.0.0/16"
  compartment_id = module.root_compartment.id
  vcn_display_name = "proactive-dr-vcn-20201022"
  vcn_dns_label = "pdrmainvcn"
  provisioned_by = var.provisioned_by
  
  defined_tags = {"SE_Details.Resource_Purpose": "PoC", "SE_Details.SE_Email": var.provisioned_by}
  freeform_tags = {"pdr-poc": "networks-vcn-main"}
}

module main_vcn_internet_gateway {
  source = "./modules/network_resources/igw"
  compartment_id = module.root_compartment.id
  parent_vcn_id = module.main_vcn.id
  defined_tags = {"SE_Details.Resource_Purpose": "PoC", "SE_Details.SE_Email": var.provisioned_by}
  freeform_tags = {"pdr-poc": "networks-vcn-main-igw"}
}

module main_vcn_security_list {
  source = "./modules/network_resources/security_list"
  compartment_id = module.root_compartment.id
  parent_vcn_id = module.main_vcn.id
  egress_rules = [{ protocol : "all", dst: "0.0.0.0/0"}]
  ingress_rules = [{ protocol : "tcp", ports : ["80"], src: "0.0.0.0/0", description: "Allow HTTP Connections"}, 
  { protocol : "tcp", ports : ["22"], src: "0.0.0.0/0"}]
  defined_tags = {"SE_Details.Resource_Purpose": "PoC", "SE_Details.SE_Email": var.provisioned_by}
  freeform_tags = {"pdr-poc": "networks-vcn-main-sl"}
}

module main_vcn_internet_gateway_route_table {
  source = "./modules/network_resources/route_table"
  compartment_id = module.root_compartment.id
  parent_vcn_id = module.main_vcn.id
  internet_gateway_id = module.main_vcn_internet_gateway.id
  route_table_route_rules_destination = "0.0.0.0/0"
  defined_tags = {"SE_Details.Resource_Purpose": "PoC", "SE_Details.SE_Email": var.provisioned_by}
  freeform_tags = {"pdr-poc": "networks-vcn-main-rt"}
}

module regional_subnet_a {
  source ="./modules/subnets"
  subnet_cidr_block = "10.0.1.0/24"
  compartment_container_id = module.root_compartment.id
  vcn_container_id = module.main_vcn.id
  subnet_display_name = "proactive-dr-subnet-20201022"
  subnet_dns_label = "pdrsubneta"
  provisioned_by = var.provisioned_by
  security_list_ids = [module.main_vcn_security_list.id]
  defined_tags = {"SE_Details.Resource_Purpose": "PoC", "SE_Details.SE_Email": var.provisioned_by}
  freeform_tags = {"pdr-poc": "networks-subnet-a"}
}

module instance_a {
  source = "./modules/instances"
  compartment_id = module.root_compartment.id
  subnet_id = module.regional_subnet_a.id
  instance_shape = "VM.Standard2.1"
  instance_name = "proactive-dr-instance-20201022"
  source_image = local.linux_latest
  metadata = {
    ssh_authorized_keys = file(var.public_key_location)
  }
  defined_tags = {"SE_Details.Resource_Purpose": "PoC", "SE_Details.SE_Email": var.provisioned_by}
  freeform_tags = {"pdr-poc": "computes-instance-a"}
}