#The intention of this task is to get lamp stack on AWS side.
# As IAC was used Terraform (1.2.4) vesrion
----------------USAGE------------------------
#conenct to aws
Insert your AWS access key & secret key as Environment Variables, In this way we're NOT setting them permanently, you'll need to run these commands again whenever you reopen your terminal
export AWS_ACCESS_KEY_ID=<your access key>
export AWS_SECRET_ACCESS_KEY=<your secret key>
#create keys
Create key for ec2 connection and troubleshooting 
ssh-keygen (all default)
#install git
yum -y install git
#clone repo
git clone https://github.com/lamp-with-terraform/lamp-repo.git
cd lamp-repo
# Downloading the Plugin for the AWS provider
terraform init
#create workspaces
terraform workspace new prod
terraform workspace new dev
#build the Lamp project for dev 
terraform apply (select dev environment, and will build environment in us-east-1 region)
#destroy the Lamp project
terraform destroy
#build the Lamp project for prod
terraform workspace select prod
terraform apply (select prod environment, and will build environment in us-east-2 region)
#destroy the Lamp project
terraform destroy
