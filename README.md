# Disaster Recovery on OCI

This codebase provides three different methods for exploring Disaster Recovery set-up through terraform. 

## orm_terraform_guide

**Method 1:** Exporting a stack's terraform script from Oracle Resource Manager and making changes to create a Standby Region.

This section walks you through creating a resource stack in Oracle Resource Manager, exporting the stack to obtain the terraform code, and then creating changes to the code in order to deploy it in your standby region. 

Assumes you have a basic set-up of a VCN, Compute, Primary DB, Object Storage, and Load Balancer.


## terraform_scripts

**Method 2:** Providing basic terraform scripts for customers to utilize.

This section includes two folders:

/basic_script/ - Basic terraform script to deploy a disaster recovery environment consisting of a VCN + Subnets, DB, App Server, and Load Balancer. Only requires filling in the vars.tf file but otherwise ready to be utilized.

/infrastructure/ - Code as reusable, scalable modules. Redesigning the basic terraform script to be more flexible.


## workshop_1

**Method 3:** Walking through use cases with various Workshops.

Currently includes one use case, a basic app server in a VCN with internet connectivity. Uses terraform modules and walks you through building a terraform script to deploy your app server built from a repository.  
