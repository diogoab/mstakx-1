## ENVIRONMENT ##
Cloud provider: AWS

Kubernetes version: 1.14.3

Cluster deploy method: Kubeadm

Infrastructure deploy method: Terraform

## DEPLOY STRUCTURE ##
- **base-kubernetes**
    
      Files to deploy RBAC's, CNI, Ingress and other items 

- **data-kubernetes**
    
      Configuration files to bootstrap the cluster. Need to be copied to data-kubernetes bucket.

- **terraform**
    
      Files to deploy the infrastructure


The terraform directory have the structure:
- **module**
    
      Configurations definitions to deploy

- **01-base**
    
      Creation of DNS, Subnets and S3 buckets. Support to other deploys
    
- **02-etcd**

      Deploy the Etcd Cluster

- **03-apiserver**
    
      Deploy Kubernetes Master Servers

- **04-worker**
      
      Deploy Worker nodes


## HOW TO DEPLOY ##
### AUTOMATIC METHOD ###
### Requirements ###
- docker 
 
A docker image can be build to automatizate deploy process. Before execute the build two steps should be execute:
 
01 - Copy ssh key to access the bastion instance need to be copy to directory "key" inside project whit name ssh-key:
```
cp ~/keys/kube-dns.pem keys/ssh-key
```

02 - Export the absolute path (not relative "~") to aws configs. Is necessary do a bind volume from "${HOME}/.aws" configuration. If you wish, can use throught variables:
```
export AWS_PATH='/home/user/.aws'
```
or 
``` 
export AWS_ACCESS_ID
export AWS_ACCESS_KEY_ID
export AWS_DEFAULT_REGION
```

To build the image:
```
build-image.sh
```

To deploy cluster:
```
./deploy-cluster.sh
```

To destroy cluster:
```
./undeploy-cluster.sh
```

### MANUAL METHOD ###
### Requirements ###
- terraformi (0.12), awscli, ssh tools, git and jq binary

If you do not have a VPC, Internet Gateway/Nat Gateway and route tables can be use terraform 00-vpc. Execute the follow commands:
```
aws s3api create-bucket --bucket data-terraform
git clone https://github.com/jbaojunior/mstakx
cd mstakx
export WORKDIR=$(pwd)

cd ${WORKDIR}/terraform/00-vpc
terraform init
terraform apply -auto-approve
export NAT_RT_ID=$(terraform output -json nat-route-table-id | jq -r .[])
export RT_ID=$(terraform output -json route-table-id | jq -r .[])
export VPC_ID=$(terraform output -json vpc-id | jq -r .[])

cd ${WORKDIR}/terraform/module
sed -e s/NAT_RT_ID/${NAT_RT_ID}/g  -e s/RT_ID/${RT_ID}/g -e s/VPC_ID/${VPC_ID}/g default.tf-template > default.tf
```
If you have is necessary edit the file [module/default.tf](terraform/module/default.tf) to configure the VPC id and Route tables. Carefully revised the file and parameters.

The following steps are:

01 - Create the bucket to terraform
```
aws s3api create-bucket --bucket data-terraform
```

02 - Deploy the base configuration
```
cd ${WORKDIR}/terraform/01-base
terraform init
terraform apply -auto-approve
export BASTION_IP=$(terraform output -json bastion_ip | jq -r .[][])
```
PS1.: A script in 01-base will copy the directory CA. If you want generate your own execute the command before step 02:
```
cd ${WORKDIR}/data-kubernetes/ca
openssl genrsa -out data-kubernetes/ca/ca.key 4096
openssl req -x509 -new -nodes -key data-kubernetes/ca/ca.key -subj "/CN=kubernetes" -days 365 -reqexts v3_req -extensions v3_ca -out data-kubernetes/ca/ca.crt
```
PS2.: Is a output show the public IP of bastion instance. In step 06 we use this instance to access the cluster, finish the installation and configure other modules.

03 - Deploy the Etcd cluster
```
cd ${WORKDIR}/terraform/02-etcd
terraform init
terraform apply -auto-approve
```
PS1.: The etcd create the DNS entry to discovery automatically. If you need destroy etcd resource remeber of erase this entries.

04 - Deploy Kubernetes Cluster
```
cd ${WORKDIR}/terraform/03-apiserver
terraform init
terraform apply -autoapprove
```

05 - Deploy the Workers
```
cd ${WORKDIR}/terraform/04-worker
terraform init
terraform apply -autoapprove
```

06 - The next steps is access to cluster using kubectl binary. Is need access the bastion server and copy the file s3://data-kubernetes/bastion/config to ~/.kube/config:
```
export KEY="key to access the server"
scp -i ${KEY} -r ${WORKDIR}/base-kubernetes ubuntu@${BASTION_IP}:~/
ssh -i ${KEY} ubuntu@${BASTION_IP} "sudo apt-get update && \
    sudo apt-get install -y apt-transport-https curl && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
    echo 'deb https://apt.kubernetes.io/ kubernetes-xenial main' > /tmp/kubernetes.list && \
    sudo mv /tmp/kubernetes.list /etc/apt/sources.list.d/kubernetes.list && \
    sudo apt-get update && \
    sudo apt-get install -y kubectl git awscli && \
    mkdir -p ~/.kube/ && \
    aws s3 cp s3://data-kubernetes/bastion/config ~/.kube/config"
```

07 - Apply the plugins to cluster. Is necessary clone the project inside the bastion to deploy this resources:
```
ssh -i ${KEY} ubuntu@${BASTION_IP} "kubectl create -f base-kubernetes/00-bootstrap-kubelet && \
  kubectl create -f base-kubernetes/02-weave && \
  kubectl create -f base-kubernetes/03-ingress && \
  kubectl create -f base-kubernetes/04-storage-class && \
  kubectl create -f base-kubernetes/05-external-dns
```

PS.: To deploy External DNS we have to create a Zone and specify the zone-id in external-dns.yaml. To verify the zone is execute the command:
```
aws route53 list-hosted-zones-by-name --output json --dns-name "external.mstakx" | jq -r '.HostedZones[0].Id'
```

Now the cluster is functional and is prepare to received applications.


## DEPLOY APPLICATIONS ##

### **Media Wiki** ###

Steps to deploy:

01 - Create Namespace
```
kubectl create namespace mediawiki
```

02 - Deploy yaml files
```
cd mediawiki
kubectl create -f .
```

03 - Create services
```
kubectl expose deploy mysql --port 3306
kubectl expose deploy mediawiki --port 80
```


### **Istio** ###
### Requirements ###
- [Helm](https://helm.sh/docs/using_helm/#installing-helm) installed with a version higher than 2.10

The step are:
01 - Download Istio, access the directory and export the PATH variable with istioctl binary
```
curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.2.0 sh -
cd istio-1.2.0
export PATH=$PWD/bin:$PATH
```

03 - Create Namespace
```
kubectl create namespace istio-system
```

04 - Install Istio
```
helm template install/kubernetes/helm/istio-init --name istio-init --namespace istio-system | kubectl apply -f -
```

05 - Wait some jobs completed and verify that all 23 Istio CRDs
```
kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l 
```

### **Kiali** ###
** Miss enable the jaeger =S
To deploy Kiali:
01 - Create a secret
```
kubectl create secret generic kiali --from-literal=username=kiali --from-literal=passphrase=kiali123
```
PS.: Change Passphrase, please

02 - Generate Yaml file to deploy and apply
```
helm template --set kiali.enabled=true install/kubernetes/helm/istio --name istio --namespace istio-system > istio-kiali.yaml
kubectl create -f istio-kiali.yaml
```








