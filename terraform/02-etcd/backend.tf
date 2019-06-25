terraform {
  backend "s3" {
    bucket = "data-terraform"
    key    = "etcd"
    region = "us-east-1"
  }
}


provider "aws" {
  version = "2.16.0"
  region  = "us-east-1"
}
