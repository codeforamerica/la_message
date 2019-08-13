# LA Message

A barebones Ruby on Rails application for sending and tracking SMS messages in Louisiana via Twilio.

## Usage

This application is intended to be used via the Rails console `bin/rails c` and does not have a web-based UI.

There are two database-backed models:
  - **Contact**: represents a name, phone number, and additional metadata such as whether they have opted-in.
  - **Message**: represents an inbound or outbound SMS, including receiving and sending phone numbers and message body.

There is one set of objects called [Campaign Messages](./app/campaign_messages) that define outbound messages, and can optionally handle responses. These all inherit from the base class `CampaignMessage`.

## Development Setup

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

## Example scripts

Some examples of scripts for running within Rails console (`$ bin/rails c`):

### Importing contacts

```ruby
require 'csv'
CSV_PATH = '/path/to/file.csv'
RENEWAL_DATE = 'August 31, 2019'.to_date
csv = CSV.open(CSV_PATH, headers: true)

csv.each.with_index do |row, index|
  next if row['CELLPH_NUM'] == 'NULL'

  contact = Contact.find_or_initialize_by(phone_number: PhoneNumber.format(row['CELLPH_NUM'])) do |c|
    c.first_name = row['FIRST_NAME']
    c.last_name = row['LAST_NAME']
  end

  # Filter out anyone whose name doesn't match an existing record
  next if contact.first_name != row['FIRST_NAME'] || contact.last_name != row['LAST_NAME']

  contact.renewal_date = RENEWAL_DATE
  contact.opted_in = true if row['NOTIFICATION_TYPE'] == 'TEXT'
  contact.save!

  puts "\n\n\n\n==== ROW #{index} ====\n\n\n\n" if index.multiple_of?(10)
end
```

### Validating mobile phone numbers

```ruby
twilio_client = Twilio::REST::Client.new

Contact.where(carrier_type: nil).find_each do |contact|
  response = twilio_client.lookups.phone_numbers(contact.phone_number).fetch(type: ['carrier']).carrier
  
  if response['type'].present?
    contact.update(carrier_type: response['type'])
  elsif response['error_code'].present?
    contact.update(carrier_type: 'error')
  end     
rescue Twilio::REST::RestError
  contact.update(carrier_type: 'error')
rescue
  next  
end

puts Contact.group(:carrier_type).count
```

## Deployment / Architecture

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
