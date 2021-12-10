terraform {
  backend "s3" {
    bucket         = "orquestacion-terraform-state"
    dynamodb_table = "orquestacion-terraform-table"
    key            = "terraform-aws.tfstate"
    region         = "eu-west-3"
    encrypt        = true
  }
}
