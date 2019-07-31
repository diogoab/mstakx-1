#!/bin/bash
set -e
# Define Work directory
export WORKDIR='/opt'

# Create buckets
aws s3api create-bucket --bucket data-terraform
aws s3api create-bucket --bucket data-terraform

# Create VPC Base
cd ${WORKDIR}/terraform/00-vpc
terraform init
terraform apply -auto-approve
export NAT_RT_ID=$(terraform output -json nat-route-table-id | jq -r .[])
export RT_ID=$(terraform output -json route-table-id | jq -r .[])
export VPC_ID=$(terraform output -json vpc-id | jq -r .[])

# Configure modules with VPC, Nat route and route
cd ${WORKDIR}/terraform/module
sed -e s/NAT_RT_ID/${NAT_RT_ID}/g  -e s/RT_ID/${RT_ID}/g -e s/VPC_ID/${VPC_ID}/g default.tf-template > default.tf

# Deploy base
cd ${WORKDIR}/terraform/01-base
terraform init
terraform apply -auto-approve

# Get Bastion IP
export BASTION_IP=$(terraform output -json bastion_ip | jq -r '.[]')

# Deploy etcd
echo '### Etcd'
cd ${WORKDIR}/terraform/02-etcd
terraform init
terraform apply -auto-approve
echo -e "sleeping 300...\n"
sleep 300

# Deploy Api Server
echo '### APIServer'
cd ${WORKDIR}/terraform/03-apiserver
terraform init
terraform apply -auto-approve
echo -e "sleeping 180...\n"
sleep 180

# Deploy Worker
echo '### Worker'
cd ${WORKDIR}/terraform/04-worker
terraform init
terraform apply -auto-approve
echo -e "sleeping 180...\n"
sleep 180

# Configure access to k8s to bastion instance
export KEY="$WORKDIR/key/ssh-key"
scp -o StrictHostKeyChecking=false -i ${KEY} -r ${WORKDIR}/base-kubernetes ubuntu@${BASTION_IP}:~/
ssh -i ${KEY} ubuntu@${BASTION_IP} "sudo apt-get update && \
    sudo apt-get install -y apt-transport-https curl && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
    echo 'deb https://apt.kubernetes.io/ kubernetes-xenial main' > /tmp/kubernetes.list && \
    sudo mv /tmp/kubernetes.list /etc/apt/sources.list.d/kubernetes.list && \
    sudo apt-get update && \
    sudo apt-get install -y kubectl git awscli && \
    mkdir -p ~/.kube/ && \
    aws s3 cp s3://data-kubernetes/bastion/config ~/.kube/config"

# Create resource to k8s
ssh -i ${KEY} ubuntu@${BASTION_IP} "kubectl create -f base-kubernetes/00-bootstrap-kubelet"
ssh -i ${KEY} ubuntu@${BASTION_IP} "kubectl create -f base-kubernetes/02-weave"
ssh -i ${KEY} ubuntu@${BASTION_IP} "kubectl create -f base-kubernetes/03-ingress"
ssh -i ${KEY} ubuntu@${BASTION_IP} "kubectl create -f base-kubernetes/04-storage-class"
ssh -i ${KEY} ubuntu@${BASTION_IP} "kubectl create -f base-kubernetes/05-external-dns"

echo "Finish cluster deploy. Please verify the resources."
echo "To access the bastion instance"
echo 'export BASTION_IP='$BASTION_IP
