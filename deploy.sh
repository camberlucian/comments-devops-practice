#!/bin/bash

# Exit on any failure
set -e

echo "Step 1: Initializing Terraform..."
cd terraform
terraform init

echo "Step 2: Planning Terraform deployment..."
terraform plan

echo "Step 3: Applying Terraform deployment..."
terraform apply -auto-approve

echo "Step 4: Retrieving EC2 Instance IP and RDS Endpoint..."
APP_IP=$(terraform output -raw app_instance_public_ip)
DB_ENDPOINT=$(terraform output -raw db_endpoint)

echo "Step 5: Updating Ansible inventory..."
echo -e "[app]\n$APP_IP ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/comment_app_key_pair.pem" > ../ansible/inventory

echo "Step 6: Running Ansible playbook..."
cd ../ansible
ansible-playbook -i inventory site.yml

echo "Deployment Complete! Access your app at http://$APP_IP:4000"
