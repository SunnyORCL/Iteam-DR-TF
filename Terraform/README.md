# Iteam-DR-TF
I Team Disaster Recovery Environment 

# Getting Started


## Setup after git clone
Run the following commands to create a terraform .tfvars `right after git clone`
```
cd Terraform/v1 &&
echo 'tenancy_ocid = ""
user_ocid = ""
fingerprint = ""
private_key_path = ""
region = ""
starting_parent_compartment = ""' > terraform.tfvars
```

## About `terraform.tfvars`
The `.tfvars` file is used to define where this solution will be running. The user whose user_ocid is included in the `.tfvars` must be in a group that has the right policies to create OCI objects.


## Terraform Lifecycle
```
terraform init
terraform plan
terraform apply
```
