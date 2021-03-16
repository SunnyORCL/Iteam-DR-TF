

# Resource Stack Edits for Compute

## Necessary Information

### Variables to pull from the OCI Console

- Identification: This information allows the user to apply the terraform commands to create these resources from the terminal. If you would rather upload the terraform files directly to the OCI console, you do not need these values and do not need to update them in provider.tf or vars.tf
    - Tenancy OCID
    - Compartment OCID
    - Region Name (ex: eu-amsterdam-1)              
    - Subnet IP     
    - Subnet CIDR             

### New Variables

 - Standby Region Networking
    - Standby Subnet CIDR       
 - instance name
 - instance shape
 - Subnet Used
 - Image Used
 - specify OCPU and RAM count                                      


## OCI Console Steps

 Download Resource Stack. Include availability_domain, core, and Instance modules.
 
## Changes to make to .tf files

### Generic Changes

1. Remove Defined Tags exported with each resource. They have been automatically marked with the time the resource was created which will not be accurate for the standby environment.

2. Change Resource Names and Display Names. This is optional. If you choose to change the resource names, be sure to change them throughout the files since the resources often refer to each other. 

### CORE.TF

Create Compute Instance

 Fill in variables for:
 - availability domain
 - compartment
 - instance name
 - instance shape
 - Subnet Used
 - Image Used
 - specify OCPU and RAM count
   
```
   
resource oci_core_instance < Instance Name > {

    availability_config {
        recovery_action = "RESTORE_INSTANCE"
    }

    availability_domain = < Standby Availability Domain >
    compartment_id = < Standby Compartment ID >

    create_vnic_details {
        subnet_id = < Subnet ID >
    }


    shape = <Instance Shape>
    shape_config {
    
        #Specify Memory
        memory_in_gbs = "1"
       
        #Specify OCPU Count
        ocpus = "1"
        
    }
    source_details {
        source_id = < Source Image
        for Instance >
            source_type = "image"
    }
    state = "RUNNING"
}

```

###Customizations (with public IP)


```resource "oci_core_instance" "generated_oci_core_instance" {
	agent_config {
    
        #specify if management service should be disabled
		is_management_disabled = "false"
        
        #specify if monitoring service should be disabled
		is_monitoring_disabled = "false"
        
        #specify plugins for instance
        #can have multiple plugins
		plugins_config {
			desired_state = "ENABLED"
			name = "OS Management Service Agent"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Custom Logs Monitoring"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Compute Instance Run Command"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Compute Instance Monitoring"
		}
	}
	availability_config {
		recovery_action = "RESTORE_INSTANCE"
	}
    
	availability_domain = < Standby Availability Domain >
	compartment_id = < Standby Compartment ID >
	create_vnic_details {
        #enable and specify a public IP address
		assign_public_ip = "true"
		subnet_id = < Public Subnet ID >
	}
    
    #tags can be used to organize resources
	defined_tags = {
		< namespace >. < tag > = < key >
	}
    
    #specify the display name of your instance
	display_name = "terraformOptions"
	
	shape = < Instance Shape >
    
    #Customize the specs of your instance
	shape_config {
    
        #specify memory
		memory_in_gbs = "16"
        
        #specify OCPU count
		ocpus = "1"
	}
    
    #this is the image which will be used to create the instance
	source_details {
		source_id = < Source Image
        for Instance >
		source_type = "image"
	}
}

```
