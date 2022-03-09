# Deploy EKS using Terraform

### Prerequisites
* Terraform (0.15.0)
* Kubectl
* Minikube (for testing)
* AWS Cli
* Git


### Deployment Pattern
##### 1. Building the APP
```
docker build -t go-server-repo .
docker tag go-server-repo:latest 027306934621.dkr.ecr.eu-west-1.amazonaws.com/go-server-repo:latest
docker push 027306934621.dkr.ecr.eu-west-1.amazonaws.com/go-server-repo:latest
```

##### 2. Deploying EKS Terraform
```
terraform-0.15.0 init
terraform-0.15.0 apply
```

##### 3. Deploy Jobs to EKS Cluster
```
aws eks --region eu-west-1 update-kubeconfig --name <cluster-name>
kubectl apply -f namespace.yaml
kubectl apply -f api.yaml -n=go-server
```

##### 4. Test the API Privately (needs seperate tabs)
```
kubectl proxy
kubectl port-forward service/go-server-svc 8080
```