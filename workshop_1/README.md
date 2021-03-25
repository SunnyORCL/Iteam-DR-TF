# Workshop: Simple App
In this workshop, you have a simple containerized React App as a frontend on a compute that is accessible from the internet.

Components are: **core**(Network, Compute, Security List, IGW, Route Table)

__Disclaimer__: The following is for demo purposes only. Since this is only to show that we can deploy an app and immediately see the results, the security list has port 80 open to 0.0.0.0/0.

# Getting Started
Inside the infrastructure directory. Run the following to generate the needed `terraform.tfvars`.


```bash
echo '''
starting_parent_compartment = ""

tenancy_ocid = ""

user_ocid = ""

fingerprint = ""

private_key_path = ""

region = ""
''' > terraform.tfvars
```

## Network Resources
Then we can create a `network.tf` file to add our network resources. Below, we will need a VCN and Subnet for a network to put our instance in.

 Internet Gateway, Subnet,
```python
module main_vcn {
  source = "./modules/network_blocks/vcns"
  vcn_cidr = "10.0.0.0/16"
  compartment_id = var.starting_parent_compartment
  vcn_display_name = "proactive-dr-vcn-20210323"
  vcn_dns_label = "prdrmainvcn"
}

module main_vcn_internet_gateway {
  source = "./modules/network_gateways/igw"
  compartment_id = var.starting_parent_compartment
  parent_vcn_id = module.main_vcn.id
}

module main_vcn_security_list {
  source = "./modules/network_resources/security_list"
  compartment_id = var.starting_parent_compartment
  parent_vcn_id = module.main_vcn.id
  egress_rules = [{ protocol : "all", dst: "0.0.0.0/0"}]
  ingress_rules = [
    {protocol : "tcp", ports : ["80"], src: "0.0.0.0/0", description: "Allow HTTP Connections"},
    {protocol : "tcp", ports : ["22"], src: "0.0.0.0/0", description: "Allow SSH Connections"},
    {protocol : "icmp", src: "0.0.0.0/0"},
    {protocol : "icmp", src: "10.0.0.0/16"}]
}

module main_vcn_internet_gateway_route_table {
  source = "./modules/network_resources/route_table"
  compartment_id = var.starting_parent_compartment
  parent_vcn_id = module.main_vcn.id
  internet_gateway_id = module.main_vcn_internet_gateway.id
  route_table_route_rules_destination = "0.0.0.0/0"
}

module regional_subnet {
  source ="./modules/network_blocks/subnets"
  subnet_cidr_block = "10.0.1.0/24"
  compartment_container_id = var.starting_parent_compartment
  vcn_container_id = module.main_vcn.id
  security_list_ids = [module.main_vcn_security_list.id]
  route_table_id = module.main_vcn_internet_gateway_route_table.id
}
```

## Compute Resources
Then we can create a `compute.tf` file to add our compute resources.

```python
module instance_a {
  source = "./modules/computes"
  compartment_id = var.starting_parent_compartment
  subnet_id = module.regional_subnet.id
  instance_shape = <SHAPE>
  instance_name = <COMPUTE_NAME>
  source_image = local.linux_latest
  metadata = {
    ssh_authorized_keys = file("<PATH_TO_PUBLIC_KEY>")
  }
}
```

## Setting up our Compute Instance
Then we can create a `app.tf` file to add our null_resources to do remote-exec.

Below we are installing Docker and Git (although we can just resort to Docker)

```python
module "setup_compute_instance" {
  source = "./modules/null_resource_ssh"
  dependent_on = [module.instance_a]
  host = module.instance_a.ip
  private_key = file("<PATH_TO_PRIVATE_KEY>")
  inline_commands = [
        "sudo yum install docker-engine -y",
        "sudo yum install git-all -y",
        "sudo systemctl start docker",
        "sudo usermod -aG docker opc"
      ]
}

module "setup_app" {
  source = "./modules/null_resource_ssh"
  dependent_on = [module.setup_compute_instance]
  host = module.instance_a.ip
  private_key = file("<PATH_TO_PRIVATE_KEY>")
  inline_commands = [
        "rm -rf oracle.r2r.simple-app",
        "git clone https://github.com/naberin/oracle.r2r.simple-app.git && cd oracle.r2r.simple-app",
        "docker build -t simpleapp:latest .",
        "docker run -d -p 80:3000 simpleapp"
      ]
}
```