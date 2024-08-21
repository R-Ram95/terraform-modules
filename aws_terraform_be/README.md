# Terraform Backend using AWS

This is a reusable Terraform module for setting up a terraform backend using AWS. It creates an S3 bucket for storing the `terraform.tfstate` file and, optionally, a DynamoDB table for state locking.

### Features

- **S3 Bucket**: Stores the Terraform state file.
- **DynamoDB Table** (optional): Provides state locking and consistency checks.

### Example Usage

```hcl
module "terraform_backend" {
  source        = "./path-to-aws_terraform_be-module"

  region        = "us-east-1"
  bucket_name   = "my-terraform-state-bucket"
  aws_profile   = "my-aws-profile"
  project_name  = "my-awesome-project"

  # Only required if you need state locking
  enable_state_locking = true
  dynamodb_name        = "my-terraform-locks"
}

output "s3_bucket_name" {
  value = module.terraform_backend.bucket_name
}

output "dynamodb_table_name" {
  value = module.terraform_backend.dynamodb_name
}
```

### Inputs

- `region`: (Required) The AWS region where resources will be created.
- `bucket_name`: (Required) The name of the S3 bucket that will store the Terraform state file.
- `aws_profile`: (Optional) The AWS CLI profile to use. Defaults to `"default"` if not specified.
- `project_name`: (Required) The name of the project. This value is applied to resource tags.
- `enable_state_locking`: (Optional) Whether to create the DynamoDB table for state locking. Defaults to `false`.
- `dynamodb_name`: (Optional) The name of the DynamoDB table used for state locking. This is required only if `enable_state_locking` is set to `true`. Defaults to `null`.

### Outputs

- `bucket_name`: The name of the S3 bucket created.
- `dynamodb_name`: The name of the DynamoDB table created (if state locking is enabled).

### Prerequisites:

- Ensure that your AWS CLI is configured with the appropriate credentials and profiles.
- The AWS region specified should be valid and available in your AWS account.

### Notes

- **`aws_profile`**:
  - Defaults to `"default"` if not specified.
  - This is the AWS account that will be used for resource creation.
- **`enable_state_locking`**:
  - Defaults to `false` if not specified.
  - Set to `true` if you want to enable state locking with DynamoDB.
- **`dynamodb_name`**:
  - Defaults to `null` if not specified.
  - This variable is only necessary if `enable_state_locking` is set to `true`.

### Bootstrapping steps:

These steps will guide you through setting up a remote Terraform backend in AWS. Initially, Terraform stores its state locally, but to improve state management and facilitate team collaboration, you’ll want to migrate this state to a remote backend. This process is often seen as a "chicken and egg" problem because you need the remote backend infrastructure (like an S3 bucket and DynamoDB table) to store your state, but Terraform manages infrastructure with a state file that doesn't yet exist in the remote backend.

The first three steps outline how to create the necessary infrastructure using a local state file, and the final two steps demonstrate how to migrate this state to the newly created remote backend for future deployments.

1. **Create entry file to create a BE module:**

   ```hcl
   terraform {
     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 4.67.0"
       }
     }
   }

   provider "aws" {
     region  = "aws-region"
     profile = "your-aws-profile"
   }

   module "terraform-be" {
     source               = "git::https://github.com/R-Ram95/terraform-modules//aws_terraform_be"
     region               = "aws-region"
     aws_profile          = "your-aws-profile"
     bucket_name          = "tf-bucket-name"
     project_name         = "my-project"
     # optional
     enable_state_locking = true
     dynamodb_name        = "tf-state-lock-name"
   }
   ```

2. **Initialize Terraform:**

   - Downloads the BE module from the remote source (this repo)
   - Downloads the provider

   ```bash
   terraform init
   ```

3. **Create the infrastructure:**

   Optionally run `terraform plan` to verify the resources that will be created:

   ```bash
   terraform apply
   ```

   - This creates the S3 bucket and DynamoDB table (if you specified `true` to enable state locking in step 1) in your AWS account.

4. **Comment out or delete the `terraform-be` module block:**

   Terraform will try to recreate the backend resources if you don't. Add an S3 backend block:

   - `bucket` = name of the bucket from step 1
   - `dynamodb_table` = name of the table from step 1

   ```hcl
   terraform {
     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 4.67.0"
       }
     }

     backend "s3" {
       bucket         = "tf-bucket-name"
       key            = "terraform.tfstate"
       region         = "aws-region"
       dynamodb_table = "tf-state-lock-name"
       encrypt        = true
       profile        = "your-aws-profile"
     }
   }

   provider "aws" {
     region  = "aws-region"
     profile = "your-aws-profile"
   }

   // COMMENT THIS OUT
   # module "terraform-be" {
   #   source               = "git::https://github.com/R-Ram95/terraform-modules//aws_terraform_be"
   #   region               = "aws-region"
   #   aws_profile          = "your-aws-profile"
   #   bucket_name          = "tf-bucket-name"
   #   project_name         = "project-name"
   #   enable_state_locking = true
   #   dynamodb_name        = "tf-state-lock-name"
   # }
   ```

5. **Migrate local Terraform BE to the new remote Terraform BE hosted on AWS:**

   ```bash
   terraform init
   ```

   - Enter "yes" when prompted with: "Do you want to copy existing state to the new backend?"
   - This step migrates the local `terraform.tfstate` file to the S3 bucket you created in step 3.

Your remote Terraform BE is now set up in AWS. Ensure that you do not push the `.terraform` directory to Git as it may contain sensitive authentication information.
