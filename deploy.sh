#!/bin/bash
set -e

# Ensure script is run from the root project directory
if [ ! -d "terraform" ]; then
  echo "ERROR: 'terraform' directory not found. Please run the script from the root project directory."
  exit 1
fi

# Generate a secret key base
SECRET_KEY_BASE=$(openssl rand -base64 64)
ERLANG_COOKIE=$(openssl rand -base64 32)

# Initialize Terraform
cd terraform

echo "Initializing Terraform..."
terraform init
terraform refresh

echo "Checking Terraform Outputs..."
DB_USER=$(terraform output -raw db_username || echo "Error fetching db_username")
DB_PASSWORD=$(terraform output -raw db_password || echo "Error fetching db_password")
DB_ENDPOINT=$(terraform output -raw db_endpoint || echo "Error fetching db_endpoint")
DB_NAME=$(terraform output -raw db_name || echo "Error fetching db_name")

# Apply Terraform configuration
echo "Applying Terraform configuration..."
terraform apply -auto-approve

# Get outputs
APP_IP=$(terraform output -raw app_public_ip)
DB_HOST=$(echo $DB_ENDPOINT | cut -d':' -f1)

# Debug outputs
echo "DEBUG: DB_USER=$DB_USER"
echo "DEBUG: DB_PASSWORD=$DB_PASSWORD"
echo "DEBUG: DB_ENDPOINT=$DB_ENDPOINT"
echo "DEBUG: DB_NAME=$DB_NAME"
echo "DEBUG: APP_IP=$APP_IP"

# Check for missing variables and stop the script if any are empty
if [[ "$DB_USER" == "Error fetching db_username" || "$DB_PASSWORD" == "Error fetching db_password" || "$DB_HOST" == "Error fetching db_endpoint" || "$DB_NAME" == "Error fetching db_name" ]]; then
  echo "ERROR: One or more required database variables are missing. Exiting..."
  exit 1
fi

cd ../ansible

# Generate inventory file
echo "Generating Ansible inventory file..."
cat > inventory.ini << EOF
[webservers]
app ansible_host=${APP_IP} ansible_user=ubuntu
EOF

# Wait for SSH to become available
echo "Waiting for SSH to become available..."
while ! nc -z $APP_IP 22; do
  sleep 5
done

# Export environment variables for Ansible
export DB_USER=$DB_USER
export DB_PASSWORD=$DB_PASSWORD
export DB_HOST=$DB_HOST
export DB_NAME=$DB_NAME
export SECRET_KEY_BASE=$SECRET_KEY_BASE
export ERLANG_COOKIE=$ERLANG_COOKIE

# Debug exported variables
echo "DB_HOST=$DB_HOST"
echo "DB_NAME=$DB_NAME"
echo "DB_USER=$DB_USER"
echo "DB_PASSWORD=$DB_PASSWORD"
env | grep DB
env | grep SECRET_KEY_BASE
env | grep ERLANG_COOKIE

# Run Ansible playbook
echo "Running Ansible playbook..."
ansible-playbook playbook.yml

echo "Deployment completed successfully!"
echo "Application is available at: http://$APP_IP"
