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

### Architecture
```
The Application is bundled into an Image using a Dockerfile. The Dockerfile runs the Go server exposing the ports necessary for interaction.
The Terraform then provisions the infrastructure and all the components for an EKS cluster to run.
The Image is then exported to an ECR repo which will version and store it.
Once the cluster is running and the Image is stored in the cloud, then we can use the Kubernetes yaml files to deploy the jobs to the cluster using a namespace.
When we want to test the implementation, we can use the proxy to test locally.
```

### CICD for future reference
```
1. A gitlab repository for versioning and source control.
    a. We would need to control the versions of plugins, software and internal tools deployed
    b. We would also need to control the core part of the application deployed.
2. Using Gitlab CICD we can create different stages in which the code base must pass through in order to be deployed.
3. In these different stages, we can conduct some testing to assure that the steps have succeeeded.
4. Once it has passed through these stages, the final built image can be deployed to the cloud repo.
5. Then the final step, using the designed infrastuture as an example, is to just alter the deployed image version.
6. The process should be idempotent so that if the same process can be executed multiple times and the result comes out the same.
7. It should also provide a known state, such that it can be deployed out of sequence of versions, and with little changes be functional.
```

### Rolling back a CICD Change
```
1. The CICD pipeline should simply be able to rollback to another version.
2. In an environment that uses images containing their application, considering that the images have been versioned, it might be a case where re-running the image pipeline wont be nessisary but re-running the deployment pipeline would. In the case of the above application, editing the deployment yaml with a specific version will deploy that version of the image.
```

### Futher improvements
```
1. Control plugin and software versions in terraform. (not just immediately pulling latest)
2. Create a makefile to simplfy the deployment pattern
3. Create a CICD pipeline to auto build the image once code is pushed to the gitlab repo.
4. Add options for better monitoring.
5. Better tagging too would be a good idea.
```
