# LA Message

A barebones Ruby on Rails application for sending and tracking SMS messages in Louisiana via Twilio.

## Usage

This application is intended to be used via the Rails console `bin/rails c` and does not have a web-based UI.

There are two database-backed models:
  - **Contact**: represents a name, phone number, and additional metadata such as whether they have opted-in.
  - **Message**: represents an inbound or outbound SMS, including receiving and sending phone numbers and message body.

There is one set of objects called [Campaign Messages](./app/campaign_messages) that define outbound messages, and can optionally handle responses. These all inherit from the base class `CampaignMessage`.

## Developmnent Setup

This Ruby on Rails application tries to be as boring as possible. 

Run [`$ bin/setup`](bin/setup).

### More details

You will need, assuming a standard Mac setup:

1. [Homebrew](https://brew.sh/) for MacOS.
2. A ruby version manager, like [rbenv](https://github.com/rbenv/rbenv#homebrew-on-macos).
3. Locally installed Ruby of the version defined in `.ruby-version`. e.g. `$ rbenv install 2.6.3`
4. Postgres, like [Postgres.app](https://postgresapp.com/).
    - If setting up Postgres.app, you will also need to add the binary to your path. e.g. Add to your `~/.bashrc`: `export PATH="$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin"`
5. Install system dependencies defined in [Brewfile](./Brewfile) with `$ brew bundle`

## Deployment and Operations

Briefly:

1. Docker is used to create an image.
2. Docker images are stored in an ECR repository.
3. EKS is used to manage a Kubernetes Cluster.
4. The application is deployed to the cluster with an ELB-backed [Ingress Service](./ops/kubernetes/service.yml).
5. The application uses an RDS database whose credentials are stored in a Kubernetes [Secret](./ops/kubernetes/secrets.yml).
6. Some common workflows are captured in the [Makefile](./Makefile):
    - `$ make deploy`: creates a new docker image, pushes it to ECR, creates a migration job, waits and cleans it up, and issues a rollout.
    - `$ make kube-bash`: Creates an interactive bash shell on one of the web pods.

### EKS

To authorize:

```bash
# Sign in with the cluster-authorized IAM user
aws configure

# Set up ~/.kube/config to connect to the cluster
aws eks --region us-east-1 update-kubeconfig --name ibi-production

# Check that you can connect to the cluster
kubectl get svc

# For convenience, create a context to set the namespace for this application
kubectl config set-context la-message --cluster=ibi-production.us-east-1.eksctl.io --user=kube-production@ibi-production.us-east-1.eksctl.io --namespace la-message \
  && kubectl config use-context la-message
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
