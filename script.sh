#!/bin/bash

#terraform
# wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
# echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
# sudo apt update && sudo apt install terraform

#ansible
# sudo apt install ansible -y


#terraform deployment
TERRAFORM_DIR="/home/ubuntu/terraform"
cd $TERRAFORM_DIR


# Initialize Terraform
echo "Initializing Terraform..."
terraform init
if [ $? -ne 0 ]; then
    echo "Terraform initialization failed"
    exit 1
fi

# Validate the Terraform configuration
echo "Validating Terraform configuration..."
terraform validate
if [ $? -ne 0 ]; then
    echo "Terraform validation failed"
    exit 1
fi

# Plan the Terraform deployment
echo "Planning Terraform deployment..."
terraform plan -out=tfplan
if [ $? -ne 0 ]; then
    echo "Terraform plan failed"
    exit 1
fi

# Apply the Terraform deployment
echo "Applying Terraform deployment..."
terraform apply -auto-approve tfplan
if [ $? -ne 0 ]; then
    echo "Terraform apply failed"
    exit 1
fi
terraform output -json > output.json

# Run Terraform and capture outputs
terraform output -json > $TERRAFORM_DIR/output.json

# Check if the JSON file was created successfully
if [ ! -f output.json ]; then
  echo "Failed to create output.json"
  exit 1
fi

sudo apt-get install jq

# Read Terraform output from JSON file
ec2_ip=$(jq -r '.ec2.value' output.json)

# Create the Ansible hosts file
cat <<EOF > hosts.yml
${ec2_ip}
EOF
# Print success message
echo "Ansible hosts.yml file created successfully."

ANSIBLE_DIR="/home/ubuntu/00/"
cd $ANSIBLE_DIR
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

# run Ansible playbook
ansible-playbook -i $TERRAFORM_DIR/hosts.yml main.yml