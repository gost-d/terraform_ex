provider "aws" { 
    region = "us-east-1"
    access_key = "AKIA5S4TWFG2F3GGQPJI"
    secret_key = "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"
}

resource "aws_kms_key" "terraform-bucket-key" {
 description             = "This key is used to encrypt bucket objects"
 deletion_window_in_days = 10
 enable_key_rotation     = true
}

resource "aws_kms_alias" "key-alias" {
 name          = "alias/terraform-bucket-key"
 target_key_id = aws_kms_key.terraform-bucket-key.key_id
}


resource "aws_s3_bucket" "ec2bucket"{
    bucket = "bucketstate123456789" 
    acl = "private"
    tags = {
        Name = "Tfstate_bucket"
    }    

    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                kms_master_key_id = aws_kms_key.terraform-bucket-key.arn
                sse_algorithm     = "aws:kms"
        }
   }
 }
}

resource "aws_dynamodb_table" "terraform-state" {
 name           = "terraform-state"
 read_capacity  = 20
 write_capacity = 20
 hash_key       = "LockID"

 attribute {
   name = "LockID"
   type = "S"
 }
}

