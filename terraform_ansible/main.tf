terraform {
 backend "s3" {
   bucket         = "bucketstate123456789"
   key            = "state/terraform.tfstate"
   region         = "us-east-1"
   encrypt        = true
   kms_key_id     = "alias/terraform-bucket-key"
   dynamodb_table = "terraform-state"
 }
}

provider "aws" { 
    region = var.aws_region
}

resource "aws_instance" "example" {
    ami = var.instance_ami
    instance_type = var.instance_type
    count = var.instance_count
    vpc_security_group_ids = [aws_security_group.instance.id]
    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name 
    associate_public_ip_address = true 
    
    tags = {
        
        Name  = "Terraform-${count.index + 1}"
    }

    depends_on = [
        aws_s3_bucket.ec2bucket,
        aws_s3_bucket_object.ansible_objects 
    ]

    user_data = "${file("ansible_configuration.sh")}"
}

resource "aws_security_group" "instance" {
    name = "terraform-instance-sg"

    dynamic ingress {
        for_each = var.ec2_ingress_ports
        content {
        from_port   = ingress.key
        to_port     = ingress.key
        cidr_blocks = ingress.value
        protocol    = "tcp"
        }
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    } 
}

resource "aws_s3_bucket" "ec2bucket"{
    bucket = "ec2bucket123456789" 
    acl = "public-read"
    tags = {
        Name = "My terraform bucket"
    }    
}

resource "aws_s3_bucket_object" "ansible_objects" {
    for_each = fileset("ansible/","*")
    bucket = aws_s3_bucket.ec2bucket.id
    key = each.value 
    source = "ansible/${ each.value }"
    etag = filemd5("ansible/${ each.value }")
}

resource "aws_iam_policy" "ec2_policy" {

    name = "ec2_policy"
    path = "/"
    description = "Policy to allow ec2 get objects from s3"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                "Effect":"Allow",
                "Action": [
                    "s3:GetObject"
                ],
                "Resource": [
                    "arn:aws:s3:::ec2bucket123456789/*"
                ]
            },
            {
                "Effect":"Allow",
                "Action": [
                    "s3:ListBucket"
                ],
                "Resource": [
                    "arn:aws:s3:::ec2bucket123456789"
                ]
            }
        ]
    })
}

resource "aws_iam_role" "ec2_role" {
    name = "ec2_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid = ""
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_policy_attachment" "ec2_policy_role" {
    name = "ec2_attachment"
    roles = [aws_iam_role.ec2_role.name]
    policy_arn = aws_iam_policy.ec2_policy.arn 
}

resource "aws_iam_instance_profile" "ec2_profile" {
    name = "ec2_profile"
    role = aws_iam_role.ec2_role.name 
}