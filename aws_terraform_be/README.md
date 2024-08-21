# Terraform Backend using AWS

This is a reusable Terraform module for setting up a terraform backend using AWS. It creates an S3 bucket for storing the `terraform.tfstate` file and, optionally, a DynamoDB table for state locking.

### Features

- **S3 Bucket**: Stores the Terraform state file.
- **DynamoDB Table** (optional): Provides state locking and consistency checks.

### Example Usage

```hcl
module "terraform_backend" {
  source        = "./path-to-your-module"

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
