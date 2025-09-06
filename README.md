# miniature-enigma - Proof of concept for Cross Account S3 Replication
Quick demo to show cross account S3 replication for all objects


# Instructions

- Edit the terraform.tfvars so that it looks as follows
```
source_account = "0123456789"
destination_account = "9876543210"
source_bucket_arn = "arn:aws:s3:::my-cool-source-bucket-2025-09-06"
destination_bucket_arn = "arn:aws:s3:::my-cool-destination-bucket-2025-09-06"
```
- Login to the source Account 0123456789
- init, plan and apply if you are happy
```
tofu init
tofu plan
tofu apply
```
- Login to the destination account 9876543210
- *Important*, move the state file 
```
mv terraform.tfstate terraform.tfstate.source-account
```
- init, plan and apply if you are happy
```
tofu init
tofu plan
tofu apply
cp terraform.tfstate terraform.tfstate.destination-account
```
- Login to the source Account 0123456789
- Copy a file to the S3 bucket in the source account
```
aws s3 cp /etc/issue s3://my-cool-source-bucket-2025-09-06
```
- Login to the destination account 9876543210 (using the console is easiest)
- Check that the file has arrived in the destination bucket.

