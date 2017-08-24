# Knowledgearc k8s cluster

## Prerequisites

## Install kops

**_Linux_**

    wget -O /usr/local/bin/kops https://github.com/kubernetes/kops/releases/download/1.7.0/kops-linux-amd64
    sudo chmod +x /usr/local/bin/kops

**_macOS_**
```
    brew update && brew install kops
```
## Install kubectl

**_Linux_**
```
    wget -O /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    sudo chmod +x /usr/local/bin/kubectl
```
**_macOS_**
```
    brew install kubectl
```
## Install awscli
```
    pip install awscli
```
## Deploying a Kubernetes cluster on AWS with kops


**1.** Create an S3 bucket to store state
```
aws s3api create-bucket --bucket kops-knowledgearc-state-store --region eu-west-1 --create-bucket-configuration LocationConstraint=eu-west-1
```
**2.** Enable versioning for the bucket
```
aws s3api put-bucket-versioning --bucket kops-knowledgearc-state-store  --versioning-configuration Status=Enabled
```
**3.** Set the name of the cluster
```
export NAME=knowledgearc.k8s.local
```
**4.** Set the storage bucket
```
export KOPS_STATE_STORE=s3://kops-knowledgearc-state-store
```
**5.** Create the cluster configuration
```
kops create cluster --zones=eu-west-1a --name=$NAME\
                            --node-count=2 --node-size=t2.small --master-size=t2.small
```
**6.** Actually create the cluster
```
kops update cluster $NAME --yes
```