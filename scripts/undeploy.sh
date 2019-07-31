#!/bin/bash
set -e
# Define Work directory
export WORKDIR='/opt'

# Get variables
cd ${WORKDIR}/terraform/00-vpc
terraform init
export NAT_RT_ID=$(terraform output -json nat-route-table-id | jq -r .[])
export RT_ID=$(terraform output -json route-table-id | jq -r .[])
export VPC_ID=$(terraform output -json vpc-id | jq -r .[])
cd ${WORKDIR}/terraform/module
sed -e s/NAT_RT_ID/${NAT_RT_ID}/g  -e s/RT_ID/${RT_ID}/g -e s/VPC_ID/${VPC_ID}/g default.tf-template > default.tf

# Destroy Worker
echo '### Worker'
cd ${WORKDIR}/terraform/04-worker
terraform init
terraform destroy -auto-approve

# Destroy Api Server
echo '### APIServer'
cd ${WORKDIR}/terraform/03-apiserver
terraform init
terraform destroy -auto-approve

# Destroy etcd
echo '### Etcd'
cd ${WORKDIR}/terraform/02-etcd
terraform init
terraform destroy -auto-approve

# Clean bucket
aws s3 rm --recursive s3://data-kubernetes

# Destroy base
cd ${WORKDIR}/terraform/01-base
terraform init
terraform destroy -auto-approve

# Destroy VPC Base
cd ${WORKDIR}/terraform/00-vpc
terraform init
terraform destroy -auto-approve

# delete terraform bucket
aws s3 rm --recursive s3://data-terraform
aws s3 rb s3://data-terraform --force  

echo "Finish cluster undeploy. Please verify the resources."
