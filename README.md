# AWS Mails using SES+Route53+Lambda+S3

> Based On  
> https://github.com/arithmetric/aws-lambda-ses-forwarder

### General Structure

* Prerequisites
  - Verify Amazon SES Domains
  - Genrating DKIM Setting on Route53
  - Bucket for code & cloudofmration stacks updates: 'aws-ses-code'
* Parameters
  - Ddomain name: mydomain.com
  - Hash String: auto generated
  - Mail Mapping
* Bucket name: mydomain.com-'hash'
* Infrastructure
  - File `aws-ses-infrastructure.yaml`
  - S3 bucket
  - Lambda Function
  - SES Rule sets



### Content
* `mail-forwarder-mydomain-com.js`    
  - Lambda function, processing each out or in email
  - Configuration
    * 128 MB
    * Timeout 10 secs (maybe less)
    
  