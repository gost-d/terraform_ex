variable "aws_region" {
    description = "AWS region"
    type = string 
    default = "us-east-1"
}

variable "instance_ami" {
    description = "AMI for instance"
    type = string
    default = "ami-08d4ac5b634553e16"
}

variable "instance_type" {
    description = "Instance type"
    type = string
    default = "t2.micro"
}

variable "instance_count" {
    description = "How many instances create"
    default = "1"
}

variable "ec2_ingress_ports" {
  description = "Allowed Ec2 ports"
  default     = {
    "22"  = ["0.0.0.0/0"]
    "80"  = ["0.0.0.0/0"]
    "443" = ["0.0.0.0/0"]
  }
}