# AWS Mails Forwarder

### AWS Resources Generated


> Based On  
> https://github.com/arithmetric/aws-lambda-ses-forwarder  
> http://www.daniloaz.com/en/use-gmail-with-your-own-domain-for-free-thanks-to-amazon-ses-lambda/  

```bash
$ terraform init
```

### Prerequisites
  - Verify Amazon SES Domains (Adding to hosted zones)
  - Generating DKIM Setting on Route53

### Generate `terraform.tfvars` file
access_key         = "AK................6Q"
secret_key         = "vR..../yW..............................i"
domain_email_name  = "john@example.com"
bucket_name        = "example-com-mail-30-days"

```bash
$ terraform apply
```





 
