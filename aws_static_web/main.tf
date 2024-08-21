terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}


// USAGE
module "react_app" {
  source              = "../../../common-infrastructure/static-web-module"
  env                 = terraform.workspace
  bucket_name         = "react-app-web-bucket-mfe-xsquad-${terraform.workspace}"
  cf_dist_name        = "react-app-cf-distribution-mfe-xsquad-${terraform.workspace}"
  default_root_object = "react-app-${terraform.workspace}.js"
  aws_profile         = "accolite-terraform-mfe-xsquad"
  region              = "us-east-1"
  path_to_build       = "${path.module}/../dist"
  project_name        = "X-Squad-mfe"
}
