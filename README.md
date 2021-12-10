# bootcamp-terraform-aws

## Pre-requisites
### Configure AWS CLI
1- Install AWS CLI
```shell
brew install aws-cli
```

2- Create an Access Key: Console -> IAM -> User -> Security Credentials

3- Configure AWS CLI
```shell
aws configure
```

4 Optional- Create user with access type only Programmatic Access : Console -> IAM -> Users -> Add User
```
TerraformAdmin
Policy: Administrator Access
```

## Exercise 1: Cluster creation
### Create all the AWS resources necessary for Terraform
1- Create a bucket to store the tfstate
```shell
# Credentials through env variables overwrite the file shared-credentials-file method created with aws configure
# Validate the current aws account (aws configure list)
# If we want to use TerraformAdmin SA
export AWS_ACCESS_KEY_ID="YOUR_KEY"
export AWS_SECRET_ACCESS_KEY="YOUR_ACCESS_KEY"
export AWS_DEFAULT_REGION="eu-west-3"
export AWS_TERRAFORM_BUCKET="orquestacion-terraform-state"
export AWS_TERRAFORM_TABLE="orquestacion-terraform-table"
```

```shell
aws s3api create-bucket --bucket $AWS_TERRAFORM_BUCKET --region $AWS_DEFAULT_REGION \
  --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION
aws s3api put-bucket-versioning --bucket $AWS_TERRAFORM_BUCKET --versioning-configuration Status=Enabled
aws s3api put-bucket-tagging --bucket $AWS_TERRAFORM_BUCKET \
 --tagging 'TagSet=[{Key=Bloque,Value=HerramientasOrquestacion},{Key=Terraform,Value=true},{Key=Usuario,Value=joherma1}]'
aws s3 ls
```

3- Create a DynamoDB table to lock the state
```shell
aws dynamodb create-table \
    --table-name $AWS_TERRAFORM_TABLE \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --tags Key=Name,Value=$AWS_TERRAFORM_TABLE Key=Bloque,Value=HerramientasOrquestacion Key=Terraform,Value=true, Key=Usuario,Value=joherma1
```

### Configure provider y backend
Files backend.tf y versions.tf
Modify with the proper values for the bucket and the table creation
Initialize
```shell
export AWS_ACCESS_KEY_ID="YOUR_KEY"
export AWS_SECRET_ACCESS_KEY="YOUR_ACCESS_KEY"
export AWS_DEFAULT_REGION="eu-west-3"
terraform init
```

### VPC
Use opinionated and verified module. Non-official version but highlty contributed by the community
https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest

File network.tf and modify cidr and subnets
```shell
terraform init
terraform fmt
terraform apply
```

### EKS
Use opinionated and verified module. Non-official version but highlty contributed by the community
https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest

File eks.tf
Modify: Users, cluster name
```shell
terraform init
terraform fmt
terraform apply
```

### Kubeconfig import
```shell
#aws eks --region $AWS_DEFAULT_REGION update-kubeconfig --name orquestacion
aws eks update-kubeconfig --name orquestacion
```
Useful commands
```shell
kubectl explanation
kubectl get nodes
k9s
kubens
```

## Clean up
terraform destroy
AWS Console -> EC2 -> Load Balancer -> Remove manually