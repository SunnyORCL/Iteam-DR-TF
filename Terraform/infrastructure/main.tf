provider oci {
  tenancy_ocid = var.tenancy_ocid
  user_ocid = var.user_ocid
  fingerprint = var.fingerprint
  private_key_path = var.private_key_path
  region = var.region
}

module root_compartment {
  source = "./modules/compartments"
  compartment_id = var.starting_parent_compartment
  compartment_name = "Mark Smith"
  compartment_description = "Mark Smith"
}

module main_vcn {
  source = "./modules/vcns"
  vcn_cidr = "10.0.0.0/16"
  compartment_id = module.root_compartment.id
  vcn_display_name = "proactive-dr-vcn-20201026"
  vcn_dns_label = "prdrmainvcn"
  
  defined_tags = {}
  freeform_tags = {}
}

module main_vcn_internet_gateway {
  source = "./modules/network_resources/igw"
  compartment_id = module.root_compartment.id
  parent_vcn_id = module.main_vcn.id

  defined_tags = {}
  freeform_tags = {}
}

module main_vcn_security_list {
  source = "./modules/network_resources/security_list"
  compartment_id = module.root_compartment.id
  parent_vcn_id = module.main_vcn.id
  egress_rules = [{ protocol : "all", dst: "0.0.0.0/0"}]
  ingress_rules = [
    {protocol : "tcp", ports : ["80"], src: "0.0.0.0/0", description: "Allow HTTP Connections"},
    {protocol : "tcp", ports : ["22"], src: "0.0.0.0/0", description: "Allow SSH Connections"},
    {protocol : "icmp", src: "0.0.0.0/0"},
    {protocol : "icmp", src: "10.0.0.0/16"}]

  defined_tags = {}
  freeform_tags = {}
}

module main_vcn_internet_gateway_route_table {
  source = "./modules/network_resources/route_table"
  compartment_id = module.root_compartment.id
  parent_vcn_id = module.main_vcn.id
  internet_gateway_id = module.main_vcn_internet_gateway.id
  route_table_route_rules_destination = "0.0.0.0/0"

  defined_tags = {}
  freeform_tags = {}
}

module regional_subnet {
  source ="./modules/subnets"
  subnet_cidr_block = "10.0.1.0/24"
  compartment_container_id = module.root_compartment.id
  vcn_container_id = module.main_vcn.id
  subnet_display_name = "proactive-dr-subnet-20201026"
  subnet_dns_label = "prdrsubnet"
  security_list_ids = [module.main_vcn_security_list.id]
  route_table_id = module.main_vcn_internet_gateway_route_table.id

  defined_tags = {}
  freeform_tags = {}
}

module instance_a {
  source = "./modules/instances"
  compartment_id = module.root_compartment.id
  subnet_id = module.regional_subnet.id
  instance_shape = "VM.Standard.E2.1.Micro"
  instance_name = "proactive-dr-instance-20201026"
  source_image = local.linux_latest
  metadata = {
    ssh_authorized_keys = file("~/.ssh/ssh-test/id_rsa.pub")
  }

  defined_tags = {}
  freeform_tags = {}
}