# Iteam-DR-TF
I Team Disaster Recovery Environment 

# Get Started


### Setup after clone

```
cd Terraform/v1 &&
echo 'tenancy_ocid = ""
user_ocid = ""
fingerprint = ""
private_key_path = ""
region = ""
starting_parent_compartment = ""' > terraform.tfvars
```
### Terraform Lifecycle
```
terraform init
terraform plan
terraform apply

```

### About `terraform.tfvars`
