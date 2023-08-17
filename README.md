# das-pre-infra-aws
Scripts/assets to provision and instantiate required hardware in AWS

## resources:

- ECR
- S3
- Cluster MemoryDB (Redis)
- Cluster DocumentDB (Mongo)
- API Gateway

## objective:

- ECR to store docker image to OpenFaas functions deploy
- S3 to store the zip file to AWS Lambda Functions deploy
- Redis and Mongo DB to graph database used on functions
- API Gateway to recieve calls to lambda functions

## Configuration

Copy the `secret.tf.example` file to `secret.tf`:

- Configure the Terraform S3 backend by adding the `AWS_ACCESS_KEY` and `AWS_SECRET_KEY` of the `tfstate` user.

## Commands

```shell
# init providers and backend
terraform init

# validate configuration
terraform validate
```

## Create/update stack

```shell
# plan
terraform plan -var-file=config.tfvars -out tfplan

# apply
terraform apply tfplan
```
## Destroy stack

```shell
# plan destroy
terraform plan -destroy -var-file=config.tfvars -out tfplan-destroy

# apply destroy
terraform apply tfplan-destroy
```