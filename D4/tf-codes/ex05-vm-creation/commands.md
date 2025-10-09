terraform init -backend-config="key=terraform.tfstate" -reconfigure
terraform apply -var-file="dev.tfvars"   


terraform init -backend-config="key=vishwa/terraform-test.tfstate" -reconfigure
terraform apply -var-file="test.tfvars"   


========================
terraform workspace select vishwa-dev
terraform apply -var-file="dev.tfvars"


terraform workspace select vishwa-test
terraform apply -var-file="test.tfvars"