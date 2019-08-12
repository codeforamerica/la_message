Ops
===

Briefly:

1. Docker is used to create an image
2. Docker images are stored in an ECR repository
3. EKS is used to manage a Kubernetes Cluster 
4. The application is deployed to the cluster with an ELB-backed service
5. Some common workflows are captured in the [Makefile](../Makefile)

EKS
---

To authorize:

```bash
# Sign in with the cluster-authorized IAM user
aws configure

# Set up ~/.kube/config to connect to the cluster
aws eks --region us-east-1 update-kubeconfig --name ibi-production

# Check that you can connect to the cluster
kubectl get svc
```

### Creating a new cluster

The Kubernetes cluster is created with [`eksctl`](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html) which shouldn't be needed once the initial cluster is set up:

```bash
eksctl create cluster \
  --name ibi-production \
  --nodegroup-name standard-workers \
  --node-type m5.large \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 4 \
  --node-ami auto \
  --region us-east-1 \
  --zones "us-east-1a,us-east-1b"
```
