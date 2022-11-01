terraform {
  backend "s3" {
    bucket         = "junglemeet-backend-tfstate"
    key            = "terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "junglemeet-backend-tfstate-table"
  }
}