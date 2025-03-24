# terraform_example

A terraform example repo. Creates a multi-instance load balanced setup to run a basic web app.  Also adds an S3 bucket for general use.

No code was written with AI. Thanks to DevOps Directive for a helpful guide at https://www.youtube.com/watch?v=7xngnjfIlK4  
To run the Terraform configuration, use one of the following on the command line:
```terraform plan -var-file="vars_dev.tfvars"
terraform plan -var-file="vars_stg.tfvars"
terraform plan -var-file="vars_prd.tfvars"```

![setup](https://github.com/jamesapdx/terraform_example/raw/main/images/setup.png)
![graph](https://github.com/jamesapdx/terraform_example/raw/main/images/terraform_graph.png)
