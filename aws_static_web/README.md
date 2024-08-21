# Static Website Hosting using Terraform and AWS

This is a reusable Terraform module for deploying static websites on AWS. It automates the creation of an S3 bucket for file storage and a CloudFront distribution to serve the content. It includes configurations for security, caching, and access control, making it suitable for hosting static web assets efficiently and securely.

### TODO

- [ ] add support for custom domains & SSL

### Features

- **S3 Bucket**: File storage for static website files.
- **CloudFront Distribution** To serve the website content.

### Example Usage

```hcl
module "static_website" {
  source = "./path-to-aws_static_web-module"

  // required
  project_name         = "my-project"
  region               = "us-east-1"
  bucket_name          = "my-static-website-bucket"
  cf_dist_name         = "my-cloudfront-distribution"
  path_to_bundle       = "./frontend/build"

  // optional
  aws_profile          = "default"
  env                  = "production"
  cf_price_class       = "PriceClass_100"
  default_root_object = "index.html"
  content_types = {
    ".html" = "text/html",
    ".css"  = "text/css",
    ".js"   = "application/javascript",
    ".jpg"  = "image/jpeg",
    ".png"  = "image/png",
    ".gif"  = "image/gif",
    ".svg"  = "image/svg+xml",
    ".pdf"  = "application/pdf",
    ".woff" = "font/woff",
    ".woff2" = "font/woff2"
  }
}
```

### Inputs

- **`project_name`** (Required): The name of the project to be applied to resource tags.
- **`region`** (Required): The AWS region where resources will be created.
- **`bucket_name`** (Required): The name of the S3 bucket that will store the static website files.
- **`cf_dist_name`** (Required): The name of the CloudFront distribution.
- **`path_to_bundle`** (Required): The file system path, relative to this module, to the frontend build files, which will be uploaded to S3 and served by CloudFront.
- **`aws_profile`** (Optional): The AWS CLI profile to use. Defaults to `"default"`.
- **`env`** (Optional): The environment to which the resources are deployed (e.g., "production", "staging"). Defaults to `"production"`.
- **`cf_price_class`** (Optional): The price class for the CloudFront distribution. Defaults to `"PriceClass_100"`.
- **`default_root_object`** (Optional): The default root object file name for CloudFront Distribution, including the extension (e.g., "index.html"). Defaults to `"index.html"`.
- **`content_types`** (Optional): A map of file extensions to content types. Defaults to a common set of file types (`.html`, `.css`, `.js`, `.jpg`, `.png`, `.gif`, `.svg`, `.pdf`).

### Outputs

### Outputs

- **`bucket_id`**: The ID of the S3 bucket that holds the website files.
- **`cloudfront_domain_name`**: The domain name of the CloudFront distribution.
- **`cloudfront_dist_id`**: The ID of the CloudFront distribution.

### Prerequisites:

- Ensure that your AWS CLI is configured with the appropriate credentials and profiles.
- The AWS region specified should be valid and available in your AWS account.

### Notes

- **S3 Bucket Configuration**: The S3 bucket created by this module is configured to be private. Ensure that you have appropriate IAM policies and permissions set up if you need to access or modify the contents of the bucket directly.
- **CloudFront Distribution**: The CloudFront distribution is set up with default caching behaviors. You may need to adjust the TTL settings or cache behaviors based on the specific requirements of your application, especially if dealing with dynamic content or frequent updates.
- **Default Root Object**: The `default_root_object` is set to `"index.html"` by default. Make sure that this file is included in your build files and correctly specified if you have a different default page.
- **Content Types Mapping**: The `content_types` variable provides a default mapping of file extensions to MIME types. You can customize this mapping to include additional file types that your application may use.
- **CORS Configuration**: The CORS policy is set to allow all origins (`*`) and methods (`GET`, `HEAD`). If you need more restrictive settings, adjust the `cors_rule` in the `aws_s3_bucket_cors_configuration` resource accordingly.
- **State Management**: If using this module in a larger project, ensure that your Terraform state is managed appropriately, especially if deploying multiple environments. Consider using remote state storage and state locking to prevent conflicts.
- **Error Handling**: Custom error responses are commented out. You can uncomment and customize these settings based on your application's error handling needs.
- **Content Type Detection**: The content type mapping for files is based on file extensions. If you have non-standard file types or need more precise control, you might need to enhance the `content_types` variable and content type determination logic.
- **HTTPS and Certificates**: The CloudFront distribution is configured to use the default CloudFront certificate. For custom domains, you will need to provide an ACM certificate ARN and update the `viewer_certificate` block accordingly.
- **Testing and Validation**: After deploying the module, test the deployment thoroughly to ensure that the S3 bucket and CloudFront distribution are correctly set up and serving your static content as expected.
