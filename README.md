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
### Requirements ###
- VPC created with CIDR 172.31.0.0/16
- Internet Gateway created
- Nat Gateway created
- Route tables to Internet Gateway and Nat Gateway

Is necessary edit the file [module/default.tf](terraform/module/default.tf) to configure the VPC id and Route tables. Carefully revised the file and parameters.

Terraform binary is need with version 0.12

The steps are:

01 - Deploy the base configuration
```
cd terraform/01-base
terraform apply -auto-approve
```

02 - Copy the configurations in data-kubernetes to bucket created
```
aws s3 cp --recursive data-kubernetes/ca s3://data-kubernetes/ca/
aws s3 cp --recursive data-kubernetes/etcd s3://data-kubernetes/etcd/
aws s3 cp --recursive data-kubernetes/apiserver s3://data-kubernetes/apiserver/
aws s3 cp --recursive data-kubernetes/worker s3://data-kubernetes/worker/
```

PS.: The directory already have a CA file. If you want generate your own execute the command:
```
openssl genrsa -out data-kubernetes/ca/ca.key 4096
openssl req -x509 -new -nodes -key data-kubernetes/ca/ca.key -subj "/CN=kubernetes" -days 365 -reqexts v3_req -extensions v3_ca -out data-kubernetes/ca/ca.crt
```

03 - Deploy the Etcd cluster
```
cd terraform/02-etcd
terraform apply -auto-approve
```

04 - Deploy Kubernetes Cluster
```
cd terraform/03-apiserver
terraform apply -autoapprove
```

05 - Apply the RBACs to permit kubelet bootstrap
In this step a access to cluster is need. The simple form is access a Apiserver node. Copy the file /etc/kubernetes/admin-confg.yaml to ~/.kube/config as root user:
```
mkdir -p ~/.kube/
cp /etc/kubernetes/admin.conf ~/.kube/admin.conf
kubectl create -f base-kubernetes/00-bootstrap-kubelet
```

06 - Deploy the Workers
```
cd terraform/04-worker
terraform apply -autoapprove
```

06 - Apply the plugins to cluster
```
cd base-kubernetes
kubectl create -f 02-weave/*  
kubectl create -f 03-ingress/*
kubectl create -f 04-storage-class/*
kubectl create -f 05-external-dns/*
```

PS.: To deploy External DNS we have to create a Zone and specify the zone-id in external-dns.yaml

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
01 - Access the directory and export the PATH variable with istioctl binary
```
cd 06-istio/istio-1.2.0
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








