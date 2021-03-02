# ---- Use variables defined in terraform.tfvars or bash profile file
variable  "tenancy_ocid" {}
variable  "user_ocid" {}
variable  "fingerprint" {}
variable  "private_key_path" {}
variable  "compartment_ocid" {}
variable  "region" {}
variable  "AD" {}
variable  "ssh_public_key" {}

# ---- Configure the Oracle Cloud Infrastructure provider with an API Key
provider "oci" {
  tenancy_ocid      = var.tenancy_ocid
  user_ocid         = var.user_ocid
  fingerprint       = var.fingerprint
  private_key_path  = var.private_key_path
  region            = var.region
}

# ---- Get a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id    = var.tenancy_ocid
}

# ---- Output the result
output "show-ADs" {
    value    = data.oci_identity_availability_domains.ADs.availability_domains
}

#######-------------------------------------


variable "instance_image_ocid" {
  type = map(string)

  default = {
    # See https://docs.us-phoenix-1.oraclecloud.com/images/
    # Oracle-provided image "Oracle-Linux-7.5-2018.10.16-0"
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaaoqj42sokaoh42l76wsyhn3k2beuntrh5maj3gmgmzeyr55zzrwwa"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaageeenzyuxgia726xur4ztaoxbxyjlxogdhreu3ngfj2gji3bayda"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaitzn6tdyjer7jl34h2ujz74jwy5nkbukbh55ekp6oyzwrtfa4zma"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaa32voyikkkzfxyo4xbdmadc2dmvorfxxgdhpnk6dw64fa3l4jh7wa"
  }
}

variable "instance_shape" {
  default = "VM.Standard2.1"
}

variable "availability_domain" {
  default = 3
}


/* Network */
##----  Configure Virtual Cloud Network
    resource "oci_core_virtual_network" "vcn-web" {
      cidr_block      = "10.0.0.0/16"
      display_name    = "vcn-web"
      compartment_id  = "ocid1.compartment.oc1..aaaaaaaauxckjdnrerya4dglsjovwzuxkjdt7sfuuj2ckmwyln3nqpd33fla"
      dns_label       = "vcnweb"
}

##---- Configure Security Rules
    resource "oci_core_security_list" "LB-Security-List" {
      display_name    = "LB-Security-List"
      compartment_id  = oci_core_virtual_network.vcn-web.compartment_id
      vcn_id          = oci_core_virtual_network.vcn-web.id

    egress_security_rules {
      protocol    = "all"
      destination = "0.0.0.0/0"
    }

    ingress_security_rules {
      protocol = "6"
      source   = "0.0.0.0/0"

      tcp_options {
        min = 80
        max = 80
      }
    }

    ingress_security_rules {
      protocol = "6"
      source   = "0.0.0.0/0"

      tcp_options {
        min = 443
        max = 443
      }
    }
}

##---- Default Security Rules
    resource "oci_core_default_security_list" "default-security-list" {
      manage_default_resource_id = oci_core_virtual_network.vcn-web.default_security_list_id

    egress_security_rules {
      protocol    = "all"
      destination = "0.0.0.0/0"
    }

    ingress_security_rules {
      protocol = "6"
      source   = "10.0.0.0/24"

      tcp_options {
        min = 80
        max = 80
      }
    }

    ingress_security_rules {
      protocol = "6"
      source   = "10.0.1.0/24"

      tcp_options {
        min = 80
        max = 80
      }
    }
}

##---- Route Tables
resource "oci_core_default_route_table" "default-route-table" {
  manage_default_resource_id = oci_core_virtual_network.vcn-web.default_route_table_id

  route_rules {
    destination                 = "0.0.0.0/0"
    destination_type            = "CIDR_BLOCK"
    network_entity_id           = oci_core_internet_gateway.internetgateway1.id
  }
}

##---- Create LB Route Table
    resource "oci_core_route_table" "LB-Route-Table" {
    #Required
        compartment_id          = var.compartment_ocid
        vcn_id                  = oci_core_virtual_network.vcn-web.id
    
    #Optional
        display_name            = "routetable1"

    route_rules {
        #Required
            destination         = "0.0.0.0/0"
            destination_type    = "CIDR_BLOCK"
            network_entity_id   = oci_core_internet_gateway.internetgateway1.id
  }
}

##---- Network Gateway(s)
resource "oci_core_internet_gateway" "internetgateway1" {
  compartment_id                = var.compartment_ocid
  display_name                  = "internetgateway1"
  vcn_id                        = oci_core_virtual_network.vcn-web.id
}

/* Subnets */
#---- Create 3 subnets - 1 web server & 2 LB subnets
    resource "oci_core_subnet" "lb-subnet1" {
    #Required
        cidr_block              = "10.0.0.0/24"
        compartment_id          = var.compartment_ocid
        vcn_id                  = oci_core_virtual_network.vcn-web.id
        availability_domain     = lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD -1], "name")

    #Optional
        display_name            = "lb-subnet1"
        dns_label               = "lbsubnet1"
        route_table_id          = oci_core_route_table.LB-Route-Table.id
        dhcp_options_id         = oci_core_virtual_network.vcn-web.default_dhcp_options_id
        security_list_ids       = [oci_core_security_list.LB-Security-List.id]

  provisioner "local-exec" {
    command = "sleep 5"
  }        
}

resource "oci_core_subnet" "lb-subnet2" {
  availability_domain           = lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD -3], "name")
  cidr_block                    = "10.0.1.0/24"
  display_name                  = "lb-subnet2"
  dns_label                     = "lbsubnet2"
  security_list_ids             = [oci_core_security_list.LB-Security-List.id]
  compartment_id                = var.compartment_ocid
  vcn_id                        = oci_core_virtual_network.vcn-web.id
  route_table_id                = oci_core_route_table.LB-Route-Table.id
  dhcp_options_id               = oci_core_virtual_network.vcn-web.default_dhcp_options_id

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

resource "oci_core_subnet" "web-server" {
  availability_domain           = lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD -1], "name")
  cidr_block                    = "10.0.2.0/24"
  display_name                  = "web-server"
  dns_label                     = "webserver"
  # security_list_ids             = [oci_core_security_list.default-security-list_id]
  compartment_id                = var.compartment_ocid
  vcn_id                        = oci_core_virtual_network.vcn-web.id
  # route_table_id                = oci_core_route_table.LB-Route-Table.id
  dhcp_options_id               = oci_core_virtual_network.vcn-web.default_dhcp_options_id

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

/* Instances */
resource "oci_core_instance" "websrv1" {
#Required
    availability_domain         = lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1], "name")
    compartment_id              = var.compartment_ocid
    shape                       = var.instance_shape
  
#Optional  
    display_name                = "websrv1"
    metadata = {
      ssh_authorized_keys       = var.ssh_public_key
  }

  create_vnic_details {
    subnet_id                   = oci_core_subnet.web-server.id
    hostname_label              = "websrv1"
  }

  source_details {
    #Required
    source_type                 = "image"
    source_id                   = var.instance_image_ocid[var.region]
   }
}

resource "oci_core_instance" "websrv2" {
#Required
    availability_domain         = lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1], "name")
    compartment_id              = var.compartment_ocid
    shape                       = var.instance_shape
  
#Optional  
    display_name                = "websrv2"
    metadata = {
      ssh_authorized_keys       = var.ssh_public_key
  }

  create_vnic_details {
    subnet_id                   = oci_core_subnet.web-server.id
    hostname_label              = "websrv2"
  }

  source_details {
    #Required
    source_type                 = "image"
    source_id                   = var.instance_image_ocid[var.region]
   }
}

/* Load Balancer */
resource "oci_load_balancer" "lb-emm" {
  shape                         = "100Mbps"
  compartment_id                = var.compartment_ocid

  subnet_ids = [
    oci_core_subnet.lb-subnet1.id,
    oci_core_subnet.lb-subnet2.id,
  ]

  display_name = "LB-Web-Servers"
}

#---- Backend Sets
resource "oci_load_balancer_backend_set" "lb-bes1" {
  name                          = "lb-bes1"
  load_balancer_id              = oci_load_balancer.lb-emm.id
  policy                        = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}

#---- Listeners
resource "oci_load_balancer_listener" "lb-listener1" {
  load_balancer_id         = oci_load_balancer.lb-emm.id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.lb-bes1.name
  port                     = 80
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "8"
  }
}


#---- Backend
resource "oci_load_balancer_backend" "lb-be1" {
  load_balancer_id = oci_load_balancer.lb-emm.id
  backendset_name  = oci_load_balancer_backend_set.lb-bes1.name
  ip_address       = oci_core_instance.websrv1.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "oci_load_balancer_backend" "lb-be2" {
  load_balancer_id = oci_load_balancer.lb-emm.id
  backendset_name  = oci_load_balancer_backend_set.lb-bes1.name
  ip_address       = oci_core_instance.websrv2.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

# ---- Output the IP
output "lb_public_ip" {
    value    = [oci_load_balancer.lb-emm.ip_addresses]
}